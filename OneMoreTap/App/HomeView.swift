import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var profile: PlayerProfile
  let onPlayClassic: () -> Void
  let onOpenShop: () -> Void

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 0) {
          Spacer(minLength: max(28, proxy.safeAreaInsets.top + 16))

          logo
            .padding(.top, 18)

          Text("ONE MORE TAP")
            .font(.system(size: 38, weight: .black, design: .rounded))
            .tracking(2.2)
            .foregroundStyle(.white)
            .padding(.top, 24)

          Text("One tap. One chance. One more run.")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.55))
            .padding(.top, 8)

          HStack(spacing: 12) {
            StatCard(title: "BEST", value: "\(profile.bestScore)", symbol: "crown.fill")
            StatCard(title: "COINS", value: "\(profile.coins)", symbol: "sparkles")
          }
          .padding(.top, 38)

          VStack(spacing: 12) {
            Button(action: onPlayClassic) {
              HStack(spacing: 12) {
                Image(systemName: "play.fill")
                Text("CLASSIC")
              }
              .font(.system(size: 19, weight: .black, design: .rounded))
              .frame(maxWidth: .infinity)
              .frame(height: 62)
              .foregroundStyle(Color(red: 0.03, green: 0.025, blue: 0.06))
              .background(
                LinearGradient(
                  colors: [profile.selectedTheme.primary, profile.selectedTheme.secondary],
                  startPoint: .leading,
                  endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
              )
              .shadow(color: Color.cyan.opacity(0.22), radius: 24, y: 10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start Classic mode")

            Text("Tap when the orb reaches the target")
              .font(.system(size: 13, weight: .medium, design: .rounded))
              .foregroundStyle(.white.opacity(0.45))
          }
          .padding(.top, 30)

          HStack(spacing: 12) {
            TogglePill(symbol: "speaker.wave.2.fill", isOn: $profile.soundEnabled, label: "Sound")
            TogglePill(
              symbol: "iphone.radiowaves.left.and.right", isOn: $profile.hapticsEnabled,
              label: "Haptics")
          }
          .padding(.top, 34)

          Button(action: onOpenShop) {
            HStack(spacing: 9) {
              Image(systemName: "bag.fill")
              Text("SHOP & THEMES")
              Spacer()
              Text(profile.selectedTheme.title)
                .foregroundStyle(profile.selectedTheme.primary)
            }
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(.white.opacity(0.72))
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
              .white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.07), lineWidth: 1)
            }
          }
          .buttonStyle(.plain)
          .padding(.top, 12)

          Spacer(minLength: 34)
        }
        .padding(.horizontal, 24)
        .frame(minHeight: proxy.size.height)
      }
      .scrollIndicators(.hidden)
    }
  }

  private var logo: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.08), lineWidth: 2)
        .frame(width: 142, height: 142)
      Circle()
        .trim(from: 0.06, to: 0.70)
        .stroke(
          AngularGradient(
            colors: [
              profile.selectedTheme.primary, profile.selectedTheme.secondary,
              profile.selectedTheme.primary,
            ], center: .center),
          style: StrokeStyle(lineWidth: 12, lineCap: .round)
        )
        .rotationEffect(.degrees(-34))
        .frame(width: 118, height: 118)
      Circle()
        .fill(.white)
        .frame(width: 22, height: 22)
        .offset(x: 52)
        .shadow(color: profile.selectedTheme.primary, radius: 12)
      Circle()
        .fill(Color.white.opacity(0.05))
        .frame(width: 70, height: 70)
        .overlay {
          Image(systemName: "hand.tap.fill")
            .font(.system(size: 29, weight: .bold))
            .foregroundStyle(.white)
        }
    }
  }
}

private struct StatCard: View {
  let title: String
  let value: String
  let symbol: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: symbol)
        .font(.system(size: 17, weight: .bold))
        .foregroundStyle(.cyan)
        .frame(width: 38, height: 38)
        .background(.white.opacity(0.055), in: Circle())
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 10, weight: .bold, design: .rounded))
          .tracking(1.1)
          .foregroundStyle(.white.opacity(0.42))
        Text(value)
          .font(.system(size: 20, weight: .black, design: .rounded))
          .foregroundStyle(.white)
          .contentTransition(.numericText())
      }
      Spacer(minLength: 0)
    }
    .padding(14)
    .frame(maxWidth: .infinity)
    .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(.white.opacity(0.07), lineWidth: 1)
    }
  }
}

private struct TogglePill: View {
  let symbol: String
  @Binding var isOn: Bool
  let label: String

  var body: some View {
    Button {
      isOn.toggle()
    } label: {
      HStack(spacing: 9) {
        Image(systemName: symbol)
        Text(label)
      }
      .font(.system(size: 13, weight: .bold, design: .rounded))
      .foregroundStyle(isOn ? .white : .white.opacity(0.42))
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(isOn ? .white.opacity(0.09) : .white.opacity(0.035), in: Capsule())
      .overlay {
        Capsule().stroke(.white.opacity(isOn ? 0.12 : 0.05), lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(label) \(isOn ? "on" : "off")")
  }
}
