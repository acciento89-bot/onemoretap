import Foundation

enum TapGrade: Equatable {
    case miss
    case hit
    case perfect
}

struct Difficulty: Equatable {
    let targetWidth: Double
    let degreesPerSecond: Double
    let direction: Double
}

enum ClassicRules {
    static let perfectFraction = 0.28

    static func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }

    static func angularDistance(_ a: Double, _ b: Double) -> Double {
        let d = abs(normalized(a) - normalized(b))
        return min(d, 360 - d)
    }

    static func grade(pointerAngle: Double, targetCenter: Double, targetWidth: Double) -> TapGrade {
        let distance = angularDistance(pointerAngle, targetCenter)
        let halfWidth = targetWidth / 2
        guard distance <= halfWidth else { return .miss }
        return distance <= halfWidth * perfectFraction ? .perfect : .hit
    }

    static func difficulty(level: Int) -> Difficulty {
        let safeLevel = max(1, level)
        let targetWidth = max(22.0, 78.0 - Double(safeLevel - 1) * 1.65)
        let speed = min(430.0, 105.0 + Double(safeLevel - 1) * 8.0)

        let direction: Double
        if safeLevel < 6 {
            direction = 1
        } else {
            direction = (safeLevel / 3).isMultiple(of: 2) ? -1 : 1
        }

        return Difficulty(targetWidth: targetWidth, degreesPerSecond: speed, direction: direction)
    }

    static func points(for grade: TapGrade, combo: Int) -> Int {
        switch grade {
        case .miss: return 0
        case .hit: return 10 + min(combo, 20)
        case .perfect: return 20 + min(combo * 2, 40)
        }
    }
}
