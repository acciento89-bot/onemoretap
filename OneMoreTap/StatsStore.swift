import Foundation
import Combine

@MainActor
final class StatsStore: ObservableObject {
    private enum Key {
        static let bestScore = "classic.bestScore"
        static let bestLevel = "classic.bestLevel"
        static let runs = "classic.runs"
        static let perfects = "classic.perfects"
        static let totalScore = "classic.totalScore"
        static let haptics = "settings.haptics"
        static let onboarding = "onboarding.seen"
    }

    private let defaults: UserDefaults

    @Published private(set) var bestScore: Int
    @Published private(set) var bestLevel: Int
    @Published private(set) var runs: Int
    @Published private(set) var perfects: Int
    @Published private(set) var totalScore: Int
    @Published var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) } }
    @Published var hasSeenOnboarding: Bool { didSet { defaults.set(hasSeenOnboarding, forKey: Key.onboarding) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        bestScore = defaults.integer(forKey: Key.bestScore)
        bestLevel = max(1, defaults.integer(forKey: Key.bestLevel))
        runs = defaults.integer(forKey: Key.runs)
        perfects = defaults.integer(forKey: Key.perfects)
        totalScore = defaults.integer(forKey: Key.totalScore)
        hapticsEnabled = defaults.object(forKey: Key.haptics) == nil ? true : defaults.bool(forKey: Key.haptics)
        hasSeenOnboarding = defaults.bool(forKey: Key.onboarding)
    }

    func recordGame(score: Int, level: Int) -> Bool {
        let isNewBest = score > bestScore
        bestScore = max(bestScore, score)
        bestLevel = max(bestLevel, level)
        totalScore += score
        runs += 1
        persistStats()
        return isNewBest
    }

    func recordPerfect() {
        perfects += 1
        defaults.set(perfects, forKey: Key.perfects)
    }

    private func persistStats() {
        defaults.set(bestScore, forKey: Key.bestScore)
        defaults.set(bestLevel, forKey: Key.bestLevel)
        defaults.set(runs, forKey: Key.runs)
        defaults.set(totalScore, forKey: Key.totalScore)
    }
}
