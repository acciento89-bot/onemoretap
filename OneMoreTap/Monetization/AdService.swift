import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

@MainActor
final class AdService: NSObject, ObservableObject, FullScreenContentDelegate {
  @Published private(set) var rewardedReady = false
  @Published private(set) var privacyOptionsRequired = false
  @Published private(set) var adsInitialized = false

  private let rewardedUnitID = "ca-app-pub-8944085355624754/7162618768"
  private let interstitialUnitID = "ca-app-pub-8944085355624754/3694930864"

  private var rewardedAd: RewardedAd?
  private var interstitialAd: InterstitialAd?
  private var didEarnPendingReward = false
  private var rewardedCompletion: ((Bool) -> Void)?
  private var interstitialCompletion: (() -> Void)?
  private var restartCount = 0
  private var hasStartedSDK = false

  func configure() {
    Task { [weak self] in
      await self?.collectConsentAndStartAds()
    }
  }

  func presentPrivacyOptions() {
    Task { [weak self] in
      do {
        try await ConsentForm.presentPrivacyOptionsForm(from: nil)
      } catch {
        // The form is optional and may not exist for every region/configuration.
      }
      self?.privacyOptionsRequired =
        ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
  }

  func showRewardedContinue(completion: @escaping (Bool) -> Void) {
    guard let rewardedAd else {
      completion(false)
      Task { await loadRewarded() }
      return
    }

    self.rewardedAd = nil
    rewardedReady = false
    didEarnPendingReward = false
    rewardedCompletion = completion
    rewardedAd.fullScreenContentDelegate = self
    rewardedAd.present(from: nil) { [weak self] in
      self?.didEarnPendingReward = true
    }
  }

  func showInterstitialOnRestartIfEligible(adsRemoved: Bool, completion: @escaping () -> Void) {
    restartCount += 1

    guard !adsRemoved else {
      completion()
      return
    }

    let shouldShow = restartCount >= 4 && (restartCount - 4).isMultiple(of: 3)
    guard shouldShow, let interstitialAd else {
      completion()
      if shouldShow { Task { await loadInterstitial() } }
      return
    }

    self.interstitialAd = nil
    interstitialCompletion = completion
    interstitialAd.fullScreenContentDelegate = self
    interstitialAd.present(from: nil)
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    if let completion = rewardedCompletion {
      rewardedCompletion = nil
      let earned = didEarnPendingReward
      didEarnPendingReward = false
      completion(earned)
      Task { await loadRewarded() }
      return
    }

    if let completion = interstitialCompletion {
      interstitialCompletion = nil
      completion()
      Task { await loadInterstitial() }
    }
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    if let completion = rewardedCompletion {
      rewardedCompletion = nil
      didEarnPendingReward = false
      completion(false)
      Task { await loadRewarded() }
      return
    }

    if let completion = interstitialCompletion {
      interstitialCompletion = nil
      completion()
      Task { await loadInterstitial() }
    }
  }

  private func collectConsentAndStartAds() async {
    do {
      try await ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters())
      try await ConsentForm.loadAndPresentIfRequired(from: nil)
    } catch {
      // A previous valid consent state may still allow requests after a transient error.
    }

    privacyOptionsRequired =
      ConsentInformation.shared.privacyOptionsRequirementStatus == .required

    guard ConsentInformation.shared.canRequestAds else { return }
    startSDKIfNeeded()
  }

  private func startSDKIfNeeded() {
    guard !hasStartedSDK else { return }
    hasStartedSDK = true
    MobileAds.shared.start { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.adsInitialized = true
        await self.loadRewarded()
        await self.loadInterstitial()
      }
    }
  }

  private func loadRewarded() async {
    guard adsInitialized else { return }
    do {
      let ad = try await RewardedAd.load(with: rewardedUnitID, request: Request())
      ad.fullScreenContentDelegate = self
      rewardedAd = ad
      rewardedReady = true
    } catch {
      rewardedAd = nil
      rewardedReady = false
    }
  }

  private func loadInterstitial() async {
    guard adsInitialized else { return }
    do {
      let ad = try await InterstitialAd.load(with: interstitialUnitID, request: Request())
      ad.fullScreenContentDelegate = self
      interstitialAd = ad
    } catch {
      interstitialAd = nil
    }
  }
}
