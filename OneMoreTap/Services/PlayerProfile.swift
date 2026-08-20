import Combine
import Foundation

@MainActor
final class PlayerProfile: ObservableObject {
  private enum Key {
    static let bestScore = "classic.bestScore"
    static let coins = "wallet.coins"
    static let soundEnabled = "settings.soundEnabled"
    static let hapticsEnabled = "settings.hapticsEnabled"
    static let hasLaunched = "app.hasLaunched"
  }

  private let defaults: UserDefaults

  @Published private(set) var bestScore: Int
  @Published private(set) var coins: Int
  @Published var soundEnabled: Bool {
    didSet { defaults.set(soundEnabled, forKey: Key.soundEnabled) }
  }
  @Published var hapticsEnabled: Bool {
    didSet { defaults.set(hapticsEnabled, forKey: Key.hapticsEnabled) }
  }

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    self.bestScore = defaults.integer(forKey: Key.bestScore)
    self.coins = defaults.integer(forKey: Key.coins)

    if defaults.bool(forKey: Key.hasLaunched) {
      self.soundEnabled = defaults.bool(forKey: Key.soundEnabled)
      self.hapticsEnabled = defaults.bool(forKey: Key.hapticsEnabled)
    } else {
      self.soundEnabled = true
      self.hapticsEnabled = true
      defaults.set(true, forKey: Key.soundEnabled)
      defaults.set(true, forKey: Key.hapticsEnabled)
      defaults.set(true, forKey: Key.hasLaunched)
    }
  }

  @discardableResult
  func completeRun(score: Int, coinsEarned: Int) -> Bool {
    let isNewBest = score > bestScore
    if isNewBest {
      bestScore = score
      defaults.set(score, forKey: Key.bestScore)
    }

    if coinsEarned > 0 {
      coins += coinsEarned
      defaults.set(coins, forKey: Key.coins)
    }
    return isNewBest
  }
}
