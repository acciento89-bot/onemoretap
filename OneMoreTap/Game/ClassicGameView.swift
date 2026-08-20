import SpriteKit
import SwiftUI

struct ClassicGameView: View {
  @EnvironmentObject private var profile: PlayerProfile
  @EnvironmentObject private var store: StoreService
  @EnvironmentObject private var ads: AdService
  @Environment(\.scenePhase) private var scenePhase
  let onExit: () -> Void

  @StateObject private var controller = ClassicGameController()
  @State private var isPresentingAd = false

  init(onExit: @escaping () -> Void) {
    self.onExit = onExit
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [profile.selectedTheme.backgroundTop, profile.selectedTheme.backgroundBottom],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      SpriteView(scene: controller.scene, options: [.allowsTransparency])
        .ignoresSafeArea()

      VStack(spacing: 0) {
        topBar
          .padding(.horizontal, 18)
          .padding(.top, 8)

        scoreHUD
          .padding(.top, 34)

        Spacer()

        if !controller.isGameOver && !controller.isPaused {
          Text("TAP ANYWHERE")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(.white.opacity(controller.score == 0 ? 0.28 : 0.12))
            .padding(.bottom, 24)
        }
      }

      if controller.isPaused {
        pauseOverlay
      }

      if controller.isGameOver {
        gameOverOverlay
      }
    }
    .onAppear {
      controller.attach(profile: profile)
      controller.start()
    }
    .onChange(of: profile.soundEnabled) { _, _ in controller.syncSettings() }
    .onChange(of: profile.hapticsEnabled) { _, _ in controller.syncSettings() }
    .onChange(of: profile.selectedTheme) { _, _ in controller.syncSettings() }
    .onChange(of: scenePhase) { _, phase in
      if phase != .active {
        if controller.isGameOver {
          controller.finishRunIfNeeded()
        } else if !controller.isPaused {
          controller.togglePause()
        }
      }
    }
    .statusBarHidden()
  }

  private var topBar: some View {
    HStack {
      Button {
        controller.togglePause()
      } label: {
        Image(systemName: "pause.fill")
          .font(.system(size: 14, weight: .black))
          .frame(width: 42, height: 42)
          .background(.white.opacity(0.07), in: Circle())
          .overlay { Circle().stroke(.white.opacity(0.08), lineWidth: 1) }
      }
      .buttonStyle(.plain)
      .foregroundStyle(.white.opacity(0.78))
      .disabled(controller.isGameOver)

      Spacer()

      HStack(spacing: 7) {
        Image(systemName: "sparkles")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(profile.selectedTheme.primary)
        Text("+\(controller.coinsEarned)")
          .font(.system(size: 14, weight: .black, design: .rounded))
          .foregroundStyle(.white.opacity(0.82))
          .contentTransition(.numericText())
      }
      .padding(.horizontal, 14)
      .frame(height: 38)
      .background(.white.opacity(0.055), in: Capsule())
    }
  }

  private var scoreHUD: some View {
    VStack(spacing: 6) {
      Text("\(controller.score)")
        .font(.system(size: 58, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .contentTransition(.numericText(value: Double(controller.score)))
        .monospacedDigit()

      if controller.combo >= 2 {
        Text("x\(controller.combo) COMBO")
          .font(.system(size: 12, weight: .black, design: .rounded))
          .tracking(1.2)
          .foregroundStyle(profile.selectedTheme.primary)
          .transition(.scale.combined(with: .opacity))
      } else {
        Text("BEST  \(profile.bestScore)")
          .font(.system(size: 11, weight: .bold, design: .rounded))
          .tracking(1.1)
          .foregroundStyle(.white.opacity(0.34))
      }

      if let status = controller.statusText {
        Text(status)
          .font(.system(size: 13, weight: .black, design: .rounded))
          .tracking(1.4)
          .foregroundStyle(.white)
          .padding(.top, 3)
          .transition(.scale.combined(with: .opacity))
      }
    }
    .animation(.spring(response: 0.24, dampingFraction: 0.72), value: controller.score)
    .animation(.spring(response: 0.24, dampingFraction: 0.72), value: controller.combo)
  }

  private var pauseOverlay: some View {
    ZStack {
      Rectangle()
        .fill(.black.opacity(0.52))
        .ignoresSafeArea()
        .background(.ultraThinMaterial)

      VStack(spacing: 16) {
        Text("PAUSED")
          .font(.system(size: 28, weight: .black, design: .rounded))
          .tracking(2)

        Button("RESUME") {
          controller.resume()
        }
        .buttonStyle(PrimaryGameButtonStyle(theme: profile.selectedTheme))

        Button("HOME") {
          controller.resume()
          onExit()
        }
        .buttonStyle(SecondaryGameButtonStyle())
      }
      .padding(24)
      .frame(maxWidth: 340)
    }
    .transition(.opacity)
  }

  private var gameOverOverlay: some View {
    ZStack {
      Rectangle()
        .fill(.black.opacity(0.54))
        .ignoresSafeArea()
        .background(.ultraThinMaterial)

      VStack(spacing: 0) {
        if controller.isNewBest {
          Text("NEW BEST")
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.8)
            .foregroundStyle(profile.selectedTheme.primary)
            .padding(.bottom, 8)
        }

        Text("\(controller.score)")
          .font(.system(size: 72, weight: .black, design: .rounded))
          .monospacedDigit()

        Text("SCORE")
          .font(.system(size: 11, weight: .bold, design: .rounded))
          .tracking(2)
          .foregroundStyle(.white.opacity(0.38))

        HStack(spacing: 28) {
          ResultStat(title: "BEST", value: "\(max(profile.bestScore, controller.score))")
          ResultStat(title: "COINS", value: "+\(controller.coinsEarned)")
        }
        .padding(.vertical, 24)

        if controller.canUseContinue {
          Button {
            isPresentingAd = true
            ads.showRewardedContinue { rewarded in
              isPresentingAd = false
              if rewarded { controller.continueAfterReward() }
            }
          } label: {
            HStack(spacing: 9) {
              Image(systemName: "play.rectangle.fill")
              Text(ads.rewardedReady ? "WATCH AD · CONTINUE" : "CONTINUE LOADING")
            }
          }
          .buttonStyle(RewardGameButtonStyle(theme: profile.selectedTheme))
          .disabled(!ads.rewardedReady || isPresentingAd)
          .opacity(ads.rewardedReady ? 1 : 0.5)
          .padding(.bottom, 10)
        }

        Button("ONE MORE TAP") {
          controller.finishRunIfNeeded()
          isPresentingAd = true
          ads.showInterstitialOnRestartIfEligible(adsRemoved: store.adsRemoved) {
            isPresentingAd = false
            controller.start()
          }
        }
        .buttonStyle(PrimaryGameButtonStyle(theme: profile.selectedTheme))
        .disabled(isPresentingAd)

        Button("HOME") {
          controller.finishRunIfNeeded()
          onExit()
        }
        .buttonStyle(SecondaryGameButtonStyle())
        .disabled(isPresentingAd)
        .padding(.top, 10)
      }
      .padding(26)
      .frame(maxWidth: 350)
      .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
          .stroke(.white.opacity(0.095), lineWidth: 1)
      }
      .shadow(color: .black.opacity(0.28), radius: 30, y: 18)
      .padding(.horizontal, 22)
    }
    .transition(.opacity.combined(with: .scale(scale: 0.96)))
    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: controller.isGameOver)
  }
}

private struct ResultStat: View {
  let title: String
  let value: String

  var body: some View {
    VStack(spacing: 5) {
      Text(value)
        .font(.system(size: 21, weight: .black, design: .rounded))
      Text(title)
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .tracking(1.3)
        .foregroundStyle(.white.opacity(0.38))
    }
    .frame(minWidth: 76)
  }
}

private struct PrimaryGameButtonStyle: ButtonStyle {
  let theme: GameThemeID

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 16, weight: .black, design: .rounded))
      .tracking(0.7)
      .foregroundStyle(Color(red: 0.03, green: 0.025, blue: 0.06))
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(
        LinearGradient(
          colors: [theme.primary, theme.secondary], startPoint: .leading, endPoint: .trailing),
        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
  }
}

private struct RewardGameButtonStyle: ButtonStyle {
  let theme: GameThemeID

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .black, design: .rounded))
      .tracking(0.5)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(
        theme.primary.opacity(0.13), in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(theme.primary.opacity(0.55), lineWidth: 1)
      }
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
  }
}

private struct SecondaryGameButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .bold, design: .rounded))
      .tracking(0.7)
      .foregroundStyle(.white.opacity(0.52))
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
  }
}
