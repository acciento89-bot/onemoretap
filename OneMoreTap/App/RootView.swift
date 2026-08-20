import SwiftUI

enum AppRoute {
  case home
  case classic
  case shop
}

struct RootView: View {
  @EnvironmentObject private var profile: PlayerProfile
  @State private var route: AppRoute = .home

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [profile.selectedTheme.backgroundTop, profile.selectedTheme.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
      .animation(.easeInOut(duration: 0.3), value: profile.selectedTheme)

      switch route {
      case .home:
        HomeView(
          onPlayClassic: { navigate(to: .classic) },
          onOpenShop: { navigate(to: .shop) }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
      case .classic:
        ClassicGameView(onExit: { navigate(to: .home) })
          .transition(.opacity)
      case .shop:
        ShopView(onClose: { navigate(to: .home) })
          .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
    }
  }

  private func navigate(to newRoute: AppRoute) {
    withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
      route = newRoute
    }
  }
}
