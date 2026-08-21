import Testing

@testable import OneMoreTapCore

@Test func perfectHitScoresAndBuildsCombo() {
  var engine = ClassicGameEngine()
  let result = engine.evaluateTap(markerAngle: 90, targetAngle: 90)
  #expect(result.quality == .perfect)
  #expect(result.newScore == 1)
  #expect(result.combo == 1)
  #expect(result.coinDelta == 2)
}

@Test func goodHitScoresOnePoint() {
  var engine = ClassicGameEngine()
  let result = engine.evaluateTap(markerAngle: 20, targetAngle: 0)
  #expect(result.quality == .good)
  #expect(result.newScore == 1)
  #expect(result.combo == 1)
}

@Test func missEndsRun() {
  var engine = ClassicGameEngine()
  let result = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  #expect(result.quality == .miss)
  #expect(engine.isGameOver)
  #expect(result.newScore == 0)
}

@Test func angularDistanceWrapsAroundZero() {
  #expect(ClassicGameEngine.shortestAngularDistanceDegrees(355, 5) == 10)
  #expect(ClassicGameEngine.shortestAngularDistanceDegrees(-5, 5) == 10)
}

@Test func difficultyGetsHarderButStaysPlayable() {
  let engine = ClassicGameEngine()
  let start = engine.difficulty(forScore: 0)
  let later = engine.difficulty(forScore: 80)
  #expect(later.angularSpeed > start.angularSpeed)
  #expect(later.targetArcDegrees < start.targetArcDegrees)
  #expect(later.targetArcDegrees >= 22)
  #expect(later.reversesDirection)
}

@Test func comboAddsPerfectScoreBonus() {
  var engine = ClassicGameEngine()
  for _ in 0..<5 {
    _ = engine.evaluateTap(markerAngle: 0, targetAngle: 0)
  }
  #expect(engine.score == 6)
  #expect(engine.combo == 5)
}

@Test func resetClearsRunState() {
  var engine = ClassicGameEngine()
  _ = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  engine.reset()
  #expect(engine.score == 0)
  #expect(engine.combo == 0)
  #expect(engine.coinsEarned == 0)
  #expect(!engine.isGameOver)
  #expect(!engine.hasUsedRevive)
}

@Test func interstitialCadenceStartsAtFourThenEveryThirdRestart() {
  let expected = Set([4, 7, 10, 13])

  for restart in 0...13 {
    #expect(InterstitialCadence.shouldShow(onRestart: restart) == expected.contains(restart))
  }
}

@Test func reviveKeepsProgressButReopensRun() {
  var engine = ClassicGameEngine()
  _ = engine.evaluateTap(markerAngle: 0, targetAngle: 0)
  let scoreBeforeMiss = engine.score
  let coinsBeforeMiss = engine.coinsEarned
  _ = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  #expect(engine.isGameOver)
  let revived = engine.reviveAfterMiss()
  #expect(revived)
  #expect(engine.hasUsedRevive)
  #expect(!engine.isGameOver)
  #expect(engine.combo == 0)
  #expect(engine.score == scoreBeforeMiss)
  #expect(engine.coinsEarned == coinsBeforeMiss)
}

@Test func reviveOnlyWorksAfterMiss() {
  var engine = ClassicGameEngine()
  let revived = engine.reviveAfterMiss()
  #expect(!revived)
}

@Test func reviveCanOnlyBeUsedOncePerRun() {
  var engine = ClassicGameEngine()

  _ = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  let firstRevive = engine.reviveAfterMiss()
  #expect(firstRevive)

  _ = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  #expect(engine.isGameOver)
  let secondRevive = engine.reviveAfterMiss()
  #expect(!secondRevive)
  #expect(engine.isGameOver)

  engine.reset()
  _ = engine.evaluateTap(markerAngle: 180, targetAngle: 0)
  let nextRunRevive = engine.reviveAfterMiss()
  #expect(nextRunRevive)
}
