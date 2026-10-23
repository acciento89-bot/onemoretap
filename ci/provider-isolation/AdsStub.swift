@_exported import Foundation
import StoreKit
public protocol FullScreenContentDelegate: AnyObject {}
public protocol FullScreenPresentingAd {}
public final class Request { public init() {} }
public final class RewardedAd: FullScreenPresentingAd {
 public var fullScreenContentDelegate: (any FullScreenContentDelegate)?
 public static func load(with id:String, request:Request) async throws -> RewardedAd { ProviderProbe.calls.append("rewarded.load");return RewardedAd() }
 public func present(from:Any?,userDidEarnRewardHandler:()->Void) { ProviderProbe.calls.append("rewarded.present");userDidEarnRewardHandler() }
}
public final class InterstitialAd: FullScreenPresentingAd {
 public var fullScreenContentDelegate: (any FullScreenContentDelegate)?
 public static func load(with id:String,request:Request) async throws -> InterstitialAd { ProviderProbe.calls.append("interstitial.load");return InterstitialAd() }
 public func present(from:Any?) { ProviderProbe.calls.append("interstitial.present") }
}
public final class MobileAds {
 public static let shared=MobileAds()
 public func start(completionHandler:(Int)->Void) { ProviderProbe.calls.append("sdk.start");completionHandler(0) }
}
