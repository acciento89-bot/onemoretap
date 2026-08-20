import SwiftUI

@main
struct OneMoreTapApp: App {
  @StateObject private var profile = PlayerProfile()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(profile)
        .preferredColorScheme(.dark)
    }
  }
}
