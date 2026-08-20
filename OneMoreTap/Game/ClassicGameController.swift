import Combine
import Foundation
import SpriteKit

@MainActor
final class ClassicGameController: ObservableObject {
  @Published private(set) var score = 0
  @Published private(set) var combo = 0
  @Published private(set) var coinsEarned = 0
  @Published private(set) var statusText: String? = nil
  @Published private(set) var isGameOver = false
  @Published private(set) var isPaused = false
  @Published private(set) var isNewBest = false

  let scene: ClassicScene
  private weak var profile: PlayerProfile?
  private var runCommitted = false

  init() {
    self.scene = ClassicScene(size: CGSize(width: 430, height: 760))
    configureCallbacks()
  }

  func attach(profile: PlayerProfile) {
    self.profile = profile
    applySettings(from: profile)
  }

  func start() {
    runCommitted = false
    isGameOver = false
    isPaused = false
    isNewBest = false
    score = 0
    combo = 0
    coinsEarned = 0
    statusText = nil
    scene.startNewRun()
  }

  func retry() {
    start()
  }

  func togglePause() {
    guard !isGameOver else { return }
    isPaused.toggle()
    scene.setPaused(isPaused)
  }

  func resume() {
    isPaused = false
    scene.setPaused(false)
  }

  func syncSettings() {
    guard let profile else { return }
    applySettings(from: profile)
  }

  private func configureCallbacks() {
    scene.onScore = { [weak self] score, combo, coins, quality in
      guard let self else { return }
      self.score = score
      self.combo = combo
      self.coinsEarned = coins
      self.statusText = quality == .perfect ? "PERFECT" : nil
      if quality == .perfect {
        Task { @MainActor [weak self] in
          try? await Task.sleep(for: .milliseconds(420))
          self?.statusText = nil
        }
      }
    }

    scene.onGameOver = { [weak self] score, coins in
      guard let self, !self.runCommitted else { return }
      self.runCommitted = true
      self.score = score
      self.coinsEarned = coins
      self.isGameOver = true
      self.isPaused = false
      if let profile = self.profile {
        self.isNewBest = profile.completeRun(score: score, coinsEarned: coins)
      }
    }
  }

  private func applySettings(from profile: PlayerProfile) {
    scene.soundEnabled = profile.soundEnabled
    scene.hapticsEnabled = profile.hapticsEnabled
  }
}
