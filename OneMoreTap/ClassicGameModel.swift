import Foundation
import SwiftUI

@MainActor
final class ClassicGameModel: ObservableObject {
    enum Phase: Equatable { case menu, playing, gameOver }

    @Published private(set) var phase: Phase = .menu
    @Published private(set) var level = 1
    @Published private(set) var score = 0
    @Published private(set) var combo = 0
    @Published private(set) var targetCenter = 55.0
    @Published private(set) var targetWidth = 78.0
    @Published private(set) var degreesPerSecond = 105.0
    @Published private(set) var lastGrade: TapGrade?
    @Published private(set) var feedbackID = 0

    private var motionStart = Date()
    private var startAngle = 0.0
    private var pausedAngle: Double?

    func start() {
        level = 1
        score = 0
        combo = 0
        lastGrade = nil
        targetCenter = 62
        applyDifficulty()
        startAngle = 0
        motionStart = Date()
        pausedAngle = nil
        phase = .playing
    }

    func goHome() {
        phase = .menu
        lastGrade = nil
    }

    func pointerAngle(at date: Date) -> Double {
        if let pausedAngle { return pausedAngle }
        guard phase == .playing else { return startAngle }
        let elapsed = date.timeIntervalSince(motionStart)
        return ClassicRules.normalized(startAngle + elapsed * degreesPerSecond)
    }

    @discardableResult
    func tap(at date: Date = Date()) -> TapGrade {
        guard phase == .playing else { return .miss }
        let angle = pointerAngle(at: date)
        let grade = ClassicRules.grade(pointerAngle: angle, targetCenter: targetCenter, targetWidth: targetWidth)
        lastGrade = grade
        feedbackID &+= 1

        switch grade {
        case .miss:
            startAngle = angle
            phase = .gameOver
        case .hit, .perfect:
            combo = grade == .perfect ? combo + 1 : 0
            score += ClassicRules.points(for: grade, combo: combo)
            level += 1
            startAngle = angle
            motionStart = date
            applyDifficulty()
            targetCenter = nextTarget(excluding: angle)
        }
        return grade
    }

    func pause(at date: Date = Date()) {
        guard phase == .playing, pausedAngle == nil else { return }
        pausedAngle = pointerAngle(at: date)
    }

    func resume(at date: Date = Date()) {
        guard phase == .playing, let frozen = pausedAngle else { return }
        startAngle = frozen
        motionStart = date
        pausedAngle = nil
    }

    private func applyDifficulty() {
        let difficulty = ClassicRules.difficulty(level: level)
        targetWidth = difficulty.targetWidth
        degreesPerSecond = difficulty.degreesPerSecond * difficulty.direction
    }

    private func nextTarget(excluding pointer: Double) -> Double {
        for _ in 0..<12 {
            let candidate = Double.random(in: 0..<360)
            if ClassicRules.angularDistance(candidate, pointer) > max(72, targetWidth * 1.25) { return candidate }
        }
        return ClassicRules.normalized(pointer + 155)
    }
}
