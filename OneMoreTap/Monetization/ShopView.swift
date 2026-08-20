import StoreKit
import SwiftUI

struct ShopView: View {
  @EnvironmentObject private var profile: PlayerProfile
  @EnvironmentObject private var store: StoreService
  @EnvironmentObject private var ads: AdService
  let onClose: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 22) {
        header
        removeAdsCard
        themesSection
        footer
      }
      .padding(.horizontal, 20)
      .padding(.top, 14)
      .padding(.bottom, 34)
    }
    .scrollIndicators(.hidden)
    .alert(
      "Store",
      isPresented: Binding(
        get: { store.lastErrorMessage != nil },
        set: { if !$0 { store.lastErrorMessage = nil } }
      )
    ) {
      Button("OK", role: .cancel) { store.lastErrorMessage = nil }
    } message: {
      Text(store.lastErrorMessage ?? "")
    }
  }

  private var header: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("SHOP")
          .font(.system(size: 30, weight: .black, design: .rounded))
          .tracking(1.5)
        Text("Cosmetics only. Classic stays fair.")
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .foregroundStyle(.white.opacity(0.48))
      }
      Spacer()
      Button(action: onClose) {
        Image(systemName: "xmark")
          .font(.system(size: 14, weight: .black))
          .frame(width: 42, height: 42)
          .background(.white.opacity(0.07), in: Circle())
      }
      .buttonStyle(.plain)
      .foregroundStyle(.white.opacity(0.82))
    }
  }

  private var removeAdsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 14) {
        Image(systemName: store.adsRemoved ? "checkmark.shield.fill" : "rectangle.slash.fill")
          .font(.system(size: 23, weight: .bold))
          .foregroundStyle(.cyan)
          .frame(width: 48, height: 48)
          .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))

        VStack(alignment: .leading, spacing: 3) {
          Text("REMOVE ADS")
            .font(.system(size: 16, weight: .black, design: .rounded))
          Text("Removes automatic interstitial ads. Rewarded continue stays optional.")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.45))
        }
      }

      if store.adsRemoved {
        ownedPill("OWNED")
      } else if let product = store.product(for: MonetizationProducts.removeAds) {
        purchaseButton(title: "REMOVE ADS · \(product.displayPrice)") {
          _ = await store.purchase(product)
        }
      } else {
        unavailablePill
      }
    }
    .cardStyle()
  }

  private var themesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("THEMES")
        .font(.system(size: 12, weight: .black, design: .rounded))
        .tracking(1.5)
        .foregroundStyle(.white.opacity(0.5))

      ForEach(GameThemeID.allCases) { theme in
        themeCard(theme)
      }

      if let allThemes = store.product(for: MonetizationProducts.allThemes),
        !GameThemeID.allCases.dropFirst().allSatisfy({ store.isThemeUnlocked($0) })
      {
        purchaseButton(title: "UNLOCK ALL THEMES · \(allThemes.displayPrice)") {
          _ = await store.purchase(allThemes)
        }
      }
    }
  }

  private func themeCard(_ theme: GameThemeID) -> some View {
    let unlocked = store.isThemeUnlocked(theme)
    let selected = profile.selectedTheme == theme

    return HStack(spacing: 14) {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(
          LinearGradient(
            colors: [theme.primary, theme.secondary], startPoint: .topLeading,
            endPoint: .bottomTrailing)
        )
        .frame(width: 58, height: 58)
        .overlay {
          Circle()
            .stroke(.white.opacity(0.75), lineWidth: 3)
            .frame(width: 27, height: 27)
        }

      VStack(alignment: .leading, spacing: 3) {
        Text(theme.title)
          .font(.system(size: 15, weight: .black, design: .rounded))
        Text(theme.subtitle)
          .font(.system(size: 12, weight: .medium, design: .rounded))
          .foregroundStyle(.white.opacity(0.42))
      }

      Spacer()

      if selected {
        ownedPill("ACTIVE")
      } else if unlocked {
        Button("USE") { profile.selectedTheme = theme }
          .font(.system(size: 11, weight: .black, design: .rounded))
          .buttonStyle(.plain)
          .foregroundStyle(.white)
          .padding(.horizontal, 14)
          .frame(height: 34)
          .background(.white.opacity(0.10), in: Capsule())
      } else if let id = theme.productID, let product = store.product(for: id) {
        Button(product.displayPrice) {
          Task {
            if await store.purchase(product) { profile.selectedTheme = theme }
          }
        }
        .font(.system(size: 11, weight: .black, design: .rounded))
        .buttonStyle(.plain)
        .foregroundStyle(Color(red: 0.03, green: 0.025, blue: 0.06))
        .padding(.horizontal, 14)
        .frame(height: 34)
        .background(theme.primary, in: Capsule())
      } else {
        unavailablePill
      }
    }
    .padding(14)
    .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(selected ? theme.primary.opacity(0.5) : .white.opacity(0.07), lineWidth: 1)
    }
  }

  private var footer: some View {
    VStack(spacing: 8) {
      Button("RESTORE PURCHASES") {
        Task { await store.restorePurchases() }
      }
      .font(.system(size: 12, weight: .bold, design: .rounded))
      .buttonStyle(.plain)
      .foregroundStyle(.white.opacity(0.6))
      .frame(height: 40)

      if ads.privacyOptionsRequired {
        Button("PRIVACY OPTIONS") { ads.presentPrivacyOptions() }
          .font(.system(size: 12, weight: .bold, design: .rounded))
          .buttonStyle(.plain)
          .foregroundStyle(.white.opacity(0.6))
          .frame(height: 40)
      }

      Text("Theme purchases are cosmetic and never change hitboxes, scoring or difficulty.")
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .multilineTextAlignment(.center)
        .foregroundStyle(.white.opacity(0.3))
        .padding(.top, 2)
    }
  }

  private func purchaseButton(title: String, action: @escaping () async -> Void) -> some View {
    Button {
      Task { await action() }
    } label: {
      Text(title)
        .font(.system(size: 13, weight: .black, design: .rounded))
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .foregroundStyle(Color(red: 0.03, green: 0.025, blue: 0.06))
        .background(
          LinearGradient(
            colors: [.cyan, Color(red: 0.63, green: 0.38, blue: 1)], startPoint: .leading,
            endPoint: .trailing),
          in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
    .buttonStyle(.plain)
  }

  private func ownedPill(_ text: String) -> some View {
    Text(text)
      .font(.system(size: 10, weight: .black, design: .rounded))
      .tracking(0.8)
      .foregroundStyle(.cyan)
      .padding(.horizontal, 11)
      .frame(height: 30)
      .background(.cyan.opacity(0.1), in: Capsule())
  }

  private var unavailablePill: some View {
    Text("LOADING")
      .font(.system(size: 9, weight: .black, design: .rounded))
      .tracking(0.6)
      .foregroundStyle(.white.opacity(0.36))
      .padding(.horizontal, 10)
      .frame(height: 30)
      .background(.white.opacity(0.05), in: Capsule())
  }
}

extension View {
  fileprivate func cardStyle() -> some View {
    padding(18)
      .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .stroke(.white.opacity(0.07), lineWidth: 1)
      }
  }
}
