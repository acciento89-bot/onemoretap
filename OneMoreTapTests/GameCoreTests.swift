import XCTest
#if canImport(OneMoreTap)
@testable import OneMoreTap
#else
@testable import OneMoreTapCore
#endif

final class GameCoreTests: XCTestCase {
    func testNormalizeWrapsAngles() {
        XCTAssertEqual(ClassicRules.normalized(370), 10, accuracy: 0.0001)
        XCTAssertEqual(ClassicRules.normalized(-10), 350, accuracy: 0.0001)
    }

    func testAngularDistanceAcrossZero() {
        XCTAssertEqual(ClassicRules.angularDistance(355, 5), 10, accuracy: 0.0001)
    }

    func testGradeHitPerfectAndMiss() {
        XCTAssertEqual(ClassicRules.grade(pointerAngle: 100, targetCenter: 100, targetWidth: 40), .perfect)
        XCTAssertEqual(ClassicRules.grade(pointerAngle: 115, targetCenter: 100, targetWidth: 40), .hit)
        XCTAssertEqual(ClassicRules.grade(pointerAngle: 125, targetCenter: 100, targetWidth: 40), .miss)
    }

    func testDifficultyTightensAndSpeedsUp() {
        let first = ClassicRules.difficulty(level: 1)
        let later = ClassicRules.difficulty(level: 20)
        XCTAssertGreaterThan(first.targetWidth, later.targetWidth)
        XCTAssertLessThan(abs(first.degreesPerSecond), abs(later.degreesPerSecond))
    }

    func testDifficultyHasFloorsAndCaps() {
        let extreme = ClassicRules.difficulty(level: 1000)
        XCTAssertEqual(extreme.targetWidth, 22, accuracy: 0.0001)
        XCTAssertEqual(extreme.degreesPerSecond, 430, accuracy: 0.0001)
    }

    func testPerfectScoresMoreThanHit() {
        XCTAssertGreaterThan(
            ClassicRules.points(for: .perfect, combo: 4),
            ClassicRules.points(for: .hit, combo: 4)
        )
    }
}
