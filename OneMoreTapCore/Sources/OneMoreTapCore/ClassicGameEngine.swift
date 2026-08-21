import Foundation

public struct ClassicDifficulty: Equatable, Sendable {
  public let angularSpeed: Double
  public let targetArcDegrees: Double
  public let perfectArcDegrees: Double
  public let reversesDirection: Bool

  public init(
    angularSpeed: Double, targetArcDegrees: Double, perfectArcDegrees: Double,
    reversesDirection: Bool
  ) {
    self.angularSpeed = angularSpeed
    self.targetArcDegrees = targetArcDegrees
    self.perfectArcDegrees = perfectArcDegrees
    self.reversesDirection = reversesDirection
  }
}

public enum HitQuality: Equatable, Sendable {
  case perfect
  case good
  case miss
}

public struct HitResult: Equatable, Sendable {
  public let quality: HitQuality
  public let scoreDelta: Int
  public let coinDelta: Int
  public let combo: Int
  public let newScore: Int

  public init(quality: HitQuality, scoreDelta: Int, coinDelta: Int, combo: Int, newScore: Int) {
    self.quality = quality
    self.scoreDelta = scoreDelta
    self.coinDelta = coinDelta
    self.combo = combo
    self.newScore = newScore
  }
}

public struct ClassicGameEngine: Sendable {
  public private(set) var score: Int = 0
  public private(set) var combo: Int = 0
  public private(set) var coinsEarned: Int = 0
  public private(set) var isGameOver: Bool = false
  public private(set) var hasUsedRevive: Bool = false

  public init() {}

  public mutating func reset() {
    score = 0
    combo = 0
    coinsEarned = 0
    isGameOver = false
    hasUsedRevive = false
  }

  @discardableResult
  public mutating func reviveAfterMiss() -> Bool {
    guard isGameOver, !hasUsedRevive else { return false }
    hasUsedRevive = true
    isGameOver = false
    combo = 0
    return true
  }

  public func difficulty(forScore score: Int? = nil) -> ClassicDifficulty {
    let value = max(0, score ?? self.score)
    let angularSpeed = min(4.2, 1.35 + Double(value) * 0.045)
    let targetArc = max(22.0, 72.0 - Double(value) * 0.72)
    let perfectArc = max(7.0, targetArc * 0.28)
    return ClassicDifficulty(
      angularSpeed: angularSpeed,
      targetArcDegrees: targetArc,
      perfectArcDegrees: perfectArc,
      reversesDirection: value >= 12
    )
  }

  public mutating func evaluateTap(markerAngle: Double, targetAngle: Double) -> HitResult {
    guard !isGameOver else {
      return HitResult(quality: .miss, scoreDelta: 0, coinDelta: 0, combo: combo, newScore: score)
    }

    let difficulty = difficulty()
    let delta = Self.shortestAngularDistanceDegrees(markerAngle, targetAngle)
    let halfTarget = difficulty.targetArcDegrees / 2.0
    let halfPerfect = difficulty.perfectArcDegrees / 2.0

    if delta <= halfPerfect {
      combo += 1
      let bonus = 1 + combo / 5
      score += bonus
      let coins = 2 + combo / 10
      coinsEarned += coins
      return HitResult(
        quality: .perfect, scoreDelta: bonus, coinDelta: coins, combo: combo, newScore: score)
    }

    if delta <= halfTarget {
      combo += 1
      score += 1
      let coins = combo % 5 == 0 ? 1 : 0
      coinsEarned += coins
      return HitResult(
        quality: .good, scoreDelta: 1, coinDelta: coins, combo: combo, newScore: score)
    }

    combo = 0
    isGameOver = true
    return HitResult(quality: .miss, scoreDelta: 0, coinDelta: 0, combo: 0, newScore: score)
  }

  public static func shortestAngularDistanceDegrees(_ a: Double, _ b: Double) -> Double {
    let normalizedA = normalizeDegrees(a)
    let normalizedB = normalizeDegrees(b)
    let raw = abs(normalizedA - normalizedB)
    return min(raw, 360.0 - raw)
  }

  public static func normalizeDegrees(_ value: Double) -> Double {
    let result = value.truncatingRemainder(dividingBy: 360.0)
    return result >= 0 ? result : result + 360.0
  }
}
