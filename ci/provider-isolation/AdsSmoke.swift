import Foundation
import StoreKit
@MainActor enum StoreService { static var providerDisabledForQA:Bool {
 #if DEBUG
 ProcessInfo.processInfo.arguments.contains("--navoTapProviderDisabledQA")
 #else
 false
 #endif
}}
enum InterstitialCadence {static func shouldShow(onRestart:Int)->Bool {true}}
@main struct AdsIsolationSmoke {
 @MainActor static func main() async {
 let ads=AdService();ads.configure();ads.presentPrivacyOptions();ads.retryRewarded()
 try? await Task.sleep(nanoseconds:50_000_000)
 var earned:Bool?;var restarted=false
 ads.showRewardedContinue {earned=$0};ads.showInterstitialOnRestartIfEligible(adsRemoved:false){restarted=true}
 if ProcessInfo.processInfo.environment["EXPECT_PROVIDER_CALLS"] == "1" {
 precondition(!ProviderProbe.calls.isEmpty);print("PASS ordinary/Release ad-provider behavior using synthetic SDKs");return
 }
 precondition(ProviderProbe.calls.isEmpty,"Unexpected ads provider calls: \(ProviderProbe.calls)")
 precondition(earned==false && restarted && !ads.adsInitialized && !ads.rewardedReady)
 print("PASS zero consent/ad calls; no reward granted; restart completes")
 }
}
