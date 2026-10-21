import Foundation

public enum SkillDrill: String, CaseIterable, Codable, Sendable {
    case timing, precision, directions
    public var difficulty: ClassicDifficulty {
        ClassicGameEngine().difficulty(forScore: self == .timing ? 0 : self == .precision ? 40 : 12)
    }
}
public enum TimingSide: String, Sendable { case early, onTime, late }
public enum SkillLabError: Error { case invalidInput, incomplete, invalidArchive, futureVersion }

public struct SkillFeedback: Codable, Equatable, Sendable {
    public let signedError: Double
    public let drill: SkillDrill
    public var side: TimingSide { signedError < 0 ? .early : signedError > 0 ? .late : .onTime }
    public var quality: HitQuality {
        let distance = abs(signedError)
        if distance <= drill.difficulty.perfectArcDegrees / 2 { return .perfect }
        return distance <= drill.difficulty.targetArcDegrees / 2 ? .good : .miss
    }
    fileprivate var isValid: Bool { signedError.isFinite && signedError >= -180 && signedError <= 180 }
}

public struct SkillLabSummary: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let drill: SkillDrill
    public let finishedAt: Date
    public let attempts: [SkillFeedback]
    public var hits: Int { attempts.filter { $0.quality != .miss }.count }
    public var perfects: Int { attempts.filter { $0.quality == .perfect }.count }
    public var meanError: Double { attempts.reduce(0) { $0 + abs($1.signedError) } / Double(max(attempts.count, 1)) }
    fileprivate var isValid: Bool {
        UUID(uuidString: id) != nil && finishedAt.timeIntervalSince1970.isFinite && attempts.count == 12 && attempts.allSatisfy { $0.isValid && $0.drill == drill }
    }
    fileprivate func outranks(_ other: SkillLabSummary) -> Bool {
        if hits != other.hits { return hits > other.hits }
        if perfects != other.perfects { return perfects > other.perfects }
        return meanError < other.meanError
    }
}

/// Practice is intentionally independent of Classic scores, wallet and ads.
public struct SkillLabEngine: Sendable {
    public let drill: SkillDrill
    private let id = UUID().uuidString
    public private(set) var markerAngle = 240.0
    public private(set) var targetAngle = 0.0
    public private(set) var direction = 1
    public private(set) var attempts: [SkillFeedback] = []
    public private(set) var lastFeedback: SkillFeedback?
    public private(set) var isPaused = false
    public var isComplete: Bool { attempts.count == 12 }
    public init(drill: SkillDrill) { self.drill = drill }

    public static func feedback(marker: Double, target: Double, direction: Int, drill: SkillDrill) throws -> SkillFeedback {
        guard marker.isFinite, target.isFinite, direction == 1 || direction == -1 else { throw SkillLabError.invalidInput }
        // Normalize first to avoid overflow from subtracting huge finite inputs.
        let delta = marker.truncatingRemainder(dividingBy: 360) - target.truncatingRemainder(dividingBy: 360)
        var shortest = delta.truncatingRemainder(dividingBy: 360)
        if shortest >= 180 { shortest -= 360 }
        if shortest < -180 { shortest += 360 }
        return SkillFeedback(signedError: shortest * Double(direction), drill: drill)
    }
    public mutating func tick(seconds: Double) {
        guard !isPaused, !isComplete, lastFeedback == nil, seconds.isFinite, seconds > 0 else { return }
        markerAngle = ClassicGameEngine.normalizeDegrees(markerAngle + Double(direction) * drill.difficulty.angularSpeed * min(seconds, 0.05) * 180 / .pi)
    }
    @discardableResult public mutating func tap(marker: Double? = nil) throws -> SkillFeedback? {
        guard !isPaused, !isComplete, lastFeedback == nil else { return nil }
        let result = try Self.feedback(marker: marker ?? markerAngle, target: targetAngle, direction: direction, drill: drill)
        attempts.append(result); lastFeedback = result
        return result
    }
    @discardableResult public mutating func nextTrial() -> Bool {
        guard !isPaused, !isComplete, lastFeedback != nil else { return false }
        lastFeedback = nil
        direction = drill == .directions && !attempts.count.isMultiple(of: 2) ? -1 : 1
        targetAngle = ClassicGameEngine.normalizeDegrees(Double(attempts.count) * 137.5)
        markerAngle = ClassicGameEngine.normalizeDegrees(targetAngle - Double(direction) * 120)
        return true
    }
    public mutating func pause() { if !isComplete { isPaused = true } }
    public mutating func resume() { isPaused = false }
    public func summary(at date: Date) throws -> SkillLabSummary {
        guard isComplete else { throw SkillLabError.incomplete }
        guard date.timeIntervalSince1970.isFinite else { throw SkillLabError.invalidInput }
        return SkillLabSummary(id: id, drill: drill, finishedAt: date, attempts: attempts)
    }
}

public struct SkillLabProgress: Codable, Equatable, Sendable {
    public private(set) var recent: [SkillLabSummary] = []
    public private(set) var bests: [String: SkillLabSummary] = [:]
    public init() {}
    public func best(for drill: SkillDrill) -> SkillLabSummary? { bests[drill.rawValue] }
    @discardableResult public mutating func record(_ summary: SkillLabSummary) -> Bool {
        guard summary.isValid, !recent.contains(where: { $0.id == summary.id }), !bests.values.contains(where: { $0.id == summary.id }) else { return false }
        recent.insert(summary, at: 0); recent = Array(recent.prefix(30))
        if best(for: summary.drill).map({ summary.outranks($0) }) ?? true { bests[summary.drill.rawValue] = summary }
        return true
    }
    fileprivate func validate() throws {
        guard recent.count <= 30, Set(recent.map(\.id)).count == recent.count,
              recent.allSatisfy(\.isValid), bests.count <= SkillDrill.allCases.count,
              bests.allSatisfy({ $0.key == $0.value.drill.rawValue && $0.value.isValid }) else { throw SkillLabError.invalidArchive }
        for item in recent {
            guard let best = best(for: item.drill), !item.outranks(best),
                  best.id != item.id || best == item else { throw SkillLabError.invalidArchive }
        }
    }
}

public struct SkillLabArchive {
    public let url: URL
    private struct Document: Codable { let schemaVersion: Int; let progress: SkillLabProgress }
    public init(url: URL) { self.url = url }
    public func load() throws -> SkillLabProgress {
        guard FileManager.default.fileExists(atPath: url.path) else { return SkillLabProgress() }
        let data = try Data(contentsOf: url)
        struct Header: Decodable { let schemaVersion: Int }
        guard try JSONDecoder().decode(Header.self, from: data).schemaVersion == 1 else { throw SkillLabError.futureVersion }
        let value = try JSONDecoder().decode(Document.self, from: data).progress
        try value.validate(); return value
    }
    public func save(_ value: SkillLabProgress) throws {
        _ = try load(); try value.validate()
        let data = try JSONEncoder().encode(Document(schemaVersion: 1, progress: value))
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}
