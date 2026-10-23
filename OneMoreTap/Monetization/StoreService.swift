import StoreKit
import SwiftUI

@MainActor
final class StoreService: ObservableObject {
  @Published private(set) var products: [Product] = []
  @Published private(set) var purchasedProductIDs: Set<String> = []
  @Published private(set) var isLoading = false
  @Published var lastErrorMessage: String?

  // Explicit native QA isolation. This switch is absent from shipping Release builds.
  static var providerDisabledForQA: Bool {
    #if DEBUG
    ProcessInfo.processInfo.arguments.contains("--navoTapProviderDisabledQA")
    #else
    false
    #endif
  }

  private var transactionUpdatesTask: Task<Void, Never>?

  init() {
    guard !Self.providerDisabledForQA else { return }
    transactionUpdatesTask = Task { [weak self] in
      for await update in Transaction.updates {
        guard let self else { return }
        do {
          let transaction = try self.verified(update)
          await transaction.finish()
          await self.refreshEntitlements()
        } catch {
          self.lastErrorMessage = "Purchase verification failed."
        }
      }
    }

    Task { [weak self] in
      await self?.reload()
    }
  }

  var adsRemoved: Bool {
    purchasedProductIDs.contains(MonetizationProducts.removeAds)
  }

  func product(for id: String) -> Product? {
    products.first { $0.id == id }
  }

  func isThemeUnlocked(_ theme: GameThemeID) -> Bool {
    guard let productID = theme.productID else { return true }
    return purchasedProductIDs.contains(productID)
      || purchasedProductIDs.contains(MonetizationProducts.allThemes)
  }

  func reload() async {
    guard !Self.providerDisabledForQA else { return }
    isLoading = true
    defer { isLoading = false }

    do {
      products = try await Product.products(for: MonetizationProducts.all)
        .sorted { $0.price < $1.price }
      await refreshEntitlements()
    } catch {
      lastErrorMessage = "Store products are currently unavailable."
    }
  }

  @discardableResult
  func purchase(_ product: Product) async -> Bool {
    guard !Self.providerDisabledForQA else { return false }
    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        let transaction = try verified(verification)
        await transaction.finish()
        await refreshEntitlements()
        return true
      case .pending, .userCancelled:
        return false
      @unknown default:
        return false
      }
    } catch {
      lastErrorMessage = "Purchase could not be completed."
      return false
    }
  }

  func restorePurchases() async {
    guard !Self.providerDisabledForQA else { return }
    do {
      try await AppStore.sync()
      await refreshEntitlements()
    } catch {
      lastErrorMessage = "Purchases could not be restored."
    }
  }

  private func refreshEntitlements() async {
    guard !Self.providerDisabledForQA else { return }
    var ids = Set<String>()
    for await entitlement in Transaction.currentEntitlements {
      guard let transaction = try? verified(entitlement) else { continue }
      guard transaction.revocationDate == nil else { continue }
      ids.insert(transaction.productID)
    }
    purchasedProductIDs = ids
  }

  private func verified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let value):
      return value
    case .unverified:
      throw StoreError.failedVerification
    }
  }

  private enum StoreError: Error {
    case failedVerification
  }
}
