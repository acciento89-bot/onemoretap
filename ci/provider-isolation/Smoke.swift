import Foundation
import StoreKit
// Synthetic providers only: this executable never links the real StoreKit framework.
enum MonetizationProducts { static let removeAds="qa.remove"; static let allThemes="qa.themes"; static let all=[removeAds, allThemes] }
enum GameThemeID { case neon; var productID:String? { nil } }
@main struct ProviderIsolationSmoke {
 @MainActor static func main() async {
  let store=StoreService()
  try? await Task.sleep(nanoseconds:30_000_000)
  await store.reload()
  _ = await store.purchase(Product())
  await store.restorePurchases()
  if ProcessInfo.processInfo.environment["EXPECT_PROVIDER_CALLS"] == "1" {
   precondition(!ProviderProbe.calls.isEmpty, "Normal/Release provider behavior must remain intact")
   print("PASS normal/Release with synthetic provider")
   return
  }
  precondition(ProviderProbe.calls.isEmpty, "Unexpected provider calls: \(ProviderProbe.calls)")
  precondition(!store.adsRemoved && !store.isLoading && store.products.isEmpty)
  print("PASS isolated QA invokes zero providers and grants no purchase")
 }
}
