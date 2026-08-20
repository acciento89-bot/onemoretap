import SwiftUI

@main
struct OneMoreTapApp: App {
  @StateObject private var profile = PlayerProfile()
  @StateObject private var store = StoreService()
  @StateObject private var ads = AdService()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(profile)
        .environmentObject(store)
        .environmentObject(ads)
        .preferredColorScheme(.dark)
        .task { ads.configure() }
    }
  }
}
