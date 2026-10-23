import SwiftUI

@main
struct NavoTapApp: App {
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var music = BackgroundMusic()
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
        .task {
          ads.configure()
          music.update(foreground: scenePhase == .active, enabled: profile.soundEnabled)
        }
        .onChange(of: scenePhase) { _, phase in music.update(foreground: phase == .active, enabled: profile.soundEnabled) }
        .onChange(of: profile.soundEnabled) { _, enabled in music.update(foreground: scenePhase == .active, enabled: enabled) }
    }
  }
}
