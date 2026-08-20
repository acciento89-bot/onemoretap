import SwiftUI

enum AppRoute {
  case home
  case classic
}

struct RootView: View {
  @State private var route: AppRoute = .home

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.025, green: 0.03, blue: 0.055), Color(red: 0.055, green: 0.025, blue: 0.09),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      switch route {
      case .home:
        HomeView(onPlayClassic: {
          withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            route = .classic
          }
        })
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
      case .classic:
        ClassicGameView(onExit: {
          withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            route = .home
          }
        })
        .transition(.opacity)
      }
    }
  }
}
