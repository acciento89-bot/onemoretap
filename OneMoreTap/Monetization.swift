import Foundation
import StoreKit
import SwiftUI

enum OneMoreTapProductID: String, CaseIterable {
    case removeAds = "com.kamilunavo.onemoretap.removeads"
    case infernoTheme = "com.kamilunavo.onemoretap.theme.inferno"
    case galaxyTheme = "com.kamilunavo.onemoretap.theme.galaxy"
    case matrixTheme = "com.kamilunavo.onemoretap.theme.matrix"
    case completePack = "com.kamilunavo.onemoretap.pack.complete"
}

enum GameTheme: String, CaseIterable, Identifiable {
    case neon
    case inferno
    case galaxy
    case matrix

    var id: String { rawValue }

    var name: String {
        switch self {
        case .neon: "Neon"
        case .inferno: "Inferno"
        case .galaxy: "Galaxy"
        case .matrix: "Matrix"
        }
    }

    var icon: String {
        switch self {
        case .neon: "bolt.fill"
        case .inferno: "flame.fill"
        case .galaxy: "sparkles"
        case .matrix: "terminal.fill"
        }
    }

    var productID: OneMoreTapProductID? {
        switch self {
        case .neon: nil
        case .inferno: .infernoTheme
        case .galaxy: .galaxyTheme
        case .matrix: .matrixTheme
        }
    }

    var primary: Color {
        switch self {
        case .neon: .cyan
        case .inferno: .orange
        case .galaxy: .purple
        case .matrix: .green
        }
    }

    var secondary: Color {
        switch self {
        case .neon: .purple
        case .inferno: .red
        case .galaxy: .indigo
        case .matrix: .mint
        }
    }

    var backgroundTop: Color {
        switch self {
        case .neon: Color(red: 0.025, green: 0.03, blue: 0.07)
        case .inferno: Color(red: 0.09, green: 0.02, blue: 0.015)
        case .galaxy: Color(red: 0.035, green: 0.018, blue: 0.085)
        case .matrix: Color(red: 0.008, green: 0.055, blue: 0.025)
        }
    }

    var backgroundMid: Color {
        switch self {
        case .neon: Color(red: 0.06, green: 0.025, blue: 0.11)
        case .inferno: Color(red: 0.13, green: 0.035, blue: 0.01)
        case .galaxy: Color(red: 0.035, green: 0.035, blue: 0.13)
        case .matrix: Color(red: 0.01, green: 0.09, blue: 0.045)
        }
    }
}

@MainActor
final class MonetizationStore: ObservableObject {
    private enum Key {
        static let selectedTheme = "appearance.selectedTheme"
    }

    private let defaults: UserDefaults
    private var updatesTask: Task<Void, Never>?
    private var hasStarted = false

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var statusMessage: String?
    @Published var selectedTheme: GameTheme {
        didSet { defaults.set(selectedTheme.rawValue, forKey: Key.selectedTheme) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: Key.selectedTheme),
           let theme = GameTheme(rawValue: raw) {
            selectedTheme = theme
        } else {
            selectedTheme = .neon
        }

        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verified(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    self.statusMessage = "A purchase could not be verified."
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var adsRemoved: Bool {
        purchasedProductIDs.contains(OneMoreTapProductID.removeAds.rawValue) ||
        purchasedProductIDs.contains(OneMoreTapProductID.completePack.rawValue)
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        await refreshProducts()
        await refreshEntitlements()
    }

    func product(for id: OneMoreTapProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    func owns(_ id: OneMoreTapProductID) -> Bool {
        purchasedProductIDs.contains(id.rawValue)
    }

    func isUnlocked(_ theme: GameTheme) -> Bool {
        guard let productID = theme.productID else { return true }
        return owns(productID) || owns(.completePack)
    }

    func select(_ theme: GameTheme) {
        guard isUnlocked(theme) else { return }
        selectedTheme = theme
    }

    func refreshProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: OneMoreTapProductID.allCases.map(\.rawValue))
                .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        } catch {
            statusMessage = "The store is temporarily unavailable."
        }
    }

    func purchase(_ id: OneMoreTapProductID) async {
        guard let product = product(for: id) else {
            statusMessage = "This pack is not available yet."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()

                if let theme = GameTheme.allCases.first(where: { $0.productID == id }) {
                    select(theme)
                }
                statusMessage = "Purchase unlocked."
            case .pending:
                statusMessage = "Purchase pending approval."
            case .userCancelled:
                break
            @unknown default:
                statusMessage = "The purchase could not be completed."
            }
        } catch {
            statusMessage = "The purchase could not be completed."
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = "Purchases restored."
        } catch {
            statusMessage = "Restore failed. Please try again."
        }
    }

    func refreshEntitlements() async {
        var owned = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result) else { continue }
            guard transaction.revocationDate == nil else { continue }
            owned.insert(transaction.productID)
        }

        purchasedProductIDs = owned

        if !isUnlocked(selectedTheme) {
            selectedTheme = .neon
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw VerificationError.failed
        }
    }

    private enum VerificationError: Error {
        case failed
    }
}

struct AdConfiguration: Equatable {
    let rewardedUnitID: String?
    let interstitialUnitID: String?

    static var current: AdConfiguration {
        AdConfiguration(
            rewardedUnitID: value(for: "OMTRewardedAdUnitID"),
            interstitialUnitID: value(for: "OMTInterstitialAdUnitID")
        )
    }

    var rewardedConfigured: Bool { rewardedUnitID != nil }
    var interstitialConfigured: Bool { interstitialUnitID != nil }

    private static func value(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum AdPolicy {
    static let interstitialRunInterval = 4

    static func canOfferRewardedContinue(adsRemoved: Bool, configuration: AdConfiguration = .current) -> Bool {
        !adsRemoved && configuration.rewardedConfigured
    }

    static func shouldShowInterstitial(
        completedRuns: Int,
        adsRemoved: Bool,
        configuration: AdConfiguration = .current
    ) -> Bool {
        guard !adsRemoved, configuration.interstitialConfigured, completedRuns > 0 else { return false }
        return completedRuns.isMultiple(of: interstitialRunInterval)
    }
}

struct OneMoreTapStoreView: View {
    @ObservedObject var store: MonetizationStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    themePicker
                    purchaseCard(
                        id: .completePack,
                        title: "Complete Pack",
                        subtitle: "All themes + remove regular ads.",
                        icon: "crown.fill",
                        accent: .yellow
                    )
                    purchaseCard(
                        id: .removeAds,
                        title: "Remove Ads",
                        subtitle: "Keep rewarded ads optional, remove regular ads.",
                        icon: "nosign",
                        accent: .cyan
                    )

                    HStack(spacing: 12) {
                        themePurchaseCard(.inferno)
                        themePurchaseCard(.galaxy)
                        themePurchaseCard(.matrix)
                    }

                    Button {
                        Task { await store.restore() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white.opacity(0.07), in: Capsule())
                    }
                    .disabled(store.isLoading)

                    Text("Prices and product names are loaded directly from the App Store.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.38))
                        .padding(.horizontal, 18)
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Packs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert(
                "One More Tap",
                isPresented: Binding(
                    get: { store.statusMessage != nil },
                    set: { if !$0 { store.statusMessage = nil } }
                )
            ) {
                Button("OK") { store.statusMessage = nil }
            } message: {
                Text(store.statusMessage ?? "")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(store.selectedTheme.primary)
                .shadow(color: store.selectedTheme.primary.opacity(0.5), radius: 18)

            Text("MAKE IT YOURS")
                .font(.system(size: 22, weight: .black, design: .rounded))

            Text("Classic stays identical. Packs only change the look or remove regular ads.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.52))
        }
        .padding(.vertical, 8)
    }

    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THEME")
                .font(.caption2.weight(.black))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.42))

            HStack(spacing: 10) {
                ForEach(GameTheme.allCases) { theme in
                    let unlocked = store.isUnlocked(theme)
                    Button {
                        if unlocked { store.select(theme) }
                    } label: {
                        VStack(spacing: 7) {
                            Image(systemName: unlocked ? theme.icon : "lock.fill")
                                .font(.system(size: 17, weight: .bold))
                            Text(theme.name.uppercased())
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(store.selectedTheme == theme ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 68)
                        .background(
                            store.selectedTheme == theme ? theme.primary : Color.white.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }
                    .disabled(!unlocked)
                    .opacity(unlocked ? 1 : 0.55)
                }
            }
        }
    }

    private func purchaseCard(
        id: OneMoreTapProductID,
        title: String,
        subtitle: String,
        icon: String,
        accent: Color
    ) -> some View {
        let product = store.product(for: id)
        let owned = store.owns(id)

        return HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button {
                Task { await store.purchase(id) }
            } label: {
                Text(owned ? "OWNED" : (product?.displayPrice ?? "—"))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(owned ? .black : .white)
                    .padding(.horizontal, 13)
                    .frame(height: 38)
                    .background(owned ? accent : Color.white.opacity(0.1), in: Capsule())
            }
            .disabled(owned || product == nil || store.isLoading)
        }
        .padding(14)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func themePurchaseCard(_ theme: GameTheme) -> some View {
        guard let id = theme.productID else { return AnyView(EmptyView()) }
        let product = store.product(for: id)
        let unlocked = store.isUnlocked(theme)

        return AnyView(
            VStack(spacing: 9) {
                Image(systemName: theme.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.primary)
                Text(theme.name.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                Button {
                    if unlocked {
                        store.select(theme)
                    } else {
                        Task { await store.purchase(id) }
                    }
                } label: {
                    Text(unlocked ? (store.selectedTheme == theme ? "ACTIVE" : "USE") : (product?.displayPrice ?? "—"))
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(unlocked ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(unlocked ? theme.primary : Color.white.opacity(0.09), in: Capsule())
                }
                .disabled((!unlocked && product == nil) || store.isLoading)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
    }
}
