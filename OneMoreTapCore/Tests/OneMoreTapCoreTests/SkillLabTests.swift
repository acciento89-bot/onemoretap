import Foundation
import Testing
@testable import OneMoreTapCore

@Test func practiceFeedbackWrapsAndRespectsMotionDirection() throws {
    let early = try SkillLabEngine.feedback(marker: 348, target: 0, direction: 1, drill: .timing)
    #expect(early.side == .early && early.signedError == -12 && early.quality == .good)
    let late = try SkillLabEngine.feedback(marker: 5, target: 350, direction: 1, drill: .timing)
    #expect(late.side == .late && late.signedError == 15)
    let reverse = try SkillLabEngine.feedback(marker: 10, target: 0, direction: -1, drill: .timing)
    #expect(reverse.side == .early && reverse.signedError == -10)
    #expect(try SkillLabEngine.feedback(marker: 0, target: 0, direction: 1, drill: .precision).quality == .perfect)
    #expect(throws: (any Error).self) { try SkillLabEngine.feedback(marker: .nan, target: 0, direction: 1, drill: .timing) }
    #expect(throws: (any Error).self) { try SkillLabEngine.feedback(marker: 0, target: 0, direction: 0, drill: .timing) }
    let boundary = SkillDrill.precision.difficulty.targetArcDegrees / 2
    #expect(try SkillLabEngine.feedback(marker: boundary, target: 0, direction: 1, drill: .precision).quality == .good)
    #expect(try SkillLabEngine.feedback(marker: boundary + 0.01, target: 0, direction: 1, drill: .precision).quality == .miss)
}
@Test func practiceTrialsFreezePauseAndFinishExactlyTwelveTimes() throws {
    var engine = SkillLabEngine(drill: .directions)
    let initial = engine.markerAngle
    engine.tick(seconds: 0.01)
    #expect(engine.markerAngle != initial)
    engine.pause(); let paused = engine.markerAngle
    engine.tick(seconds: 1); #expect(engine.markerAngle == paused)
    #expect(try engine.tap(marker: engine.targetAngle) == nil)
    engine.resume()
    for index in 0..<12 {
        #expect(engine.direction == (index.isMultiple(of: 2) ? 1 : -1))
        #expect(try engine.tap(marker: engine.targetAngle) != nil)
        #expect(try engine.tap(marker: engine.targetAngle) == nil)
        let frozen = engine.markerAngle; engine.tick(seconds: 1)
        #expect(engine.markerAngle == frozen)
        if index < 11 { let advanced = engine.nextTrial(); #expect(advanced) }
    }
    let advancedAfterCompletion = engine.nextTrial()
    #expect(engine.isComplete && engine.attempts.count == 12 && !advancedAfterCompletion)
    let summary = try engine.summary(at: Date(timeIntervalSince1970: 100))
    #expect(summary.hits == 12 && summary.perfects == 12 && summary.meanError == 0)
    var invalid = SkillLabEngine(drill: .timing)
    invalid.tick(seconds: -.infinity); #expect(invalid.attempts.isEmpty)
    #expect(throws: (any Error).self) { try invalid.tap(marker: .infinity) }
    #expect(throws: (any Error).self) { try invalid.summary(at: .now) }
    var bounded = SkillLabEngine(drill: .timing), reference = SkillLabEngine(drill: .timing)
    bounded.tick(seconds: 9); reference.tick(seconds: 0.05)
    #expect(bounded.markerAngle == reference.markerAngle)
}
private func completed(_ drill: SkillDrill, error: Double) throws -> SkillLabSummary {
    var engine = SkillLabEngine(drill: drill)
    for index in 0..<12 {
        _ = try engine.tap(marker: engine.targetAngle + error)
        if index < 11 { _ = engine.nextTrial() }
    }
    return try engine.summary(at: Date(timeIntervalSince1970: 100))
}
@Test func practiceArchiveRanksPerDrillAndProtectsExistingBytes() throws {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: folder) }
    let legacy = folder.appendingPathComponent("profile.plist"), bytes = Data("old bestscore/coins".utf8)
    try bytes.write(to: legacy)
    let archive = SkillLabArchive(url: folder.appendingPathComponent("skill-lab.json"))
    var progress = try archive.load()
    let good = try completed(.timing,error: 12), perfect = try completed(.timing,error: 0), other = try completed(.precision,error: 0)
    let recordedGood = progress.record(good), recordedPerfect = progress.record(perfect)
    let duplicate = progress.record(perfect), recordedOther = progress.record(other)
    #expect(recordedGood && recordedPerfect && !duplicate && recordedOther)
    #expect(progress.best(for: .timing)?.id == perfect.id && progress.best(for: .precision)?.id == other.id)
    try archive.save(progress)
    #expect(try archive.load() == progress)
    #expect(try Data(contentsOf: legacy) == bytes)
    let corrupt = Data("{broken".utf8); try corrupt.write(to: archive.url)
    #expect(throws: (any Error).self) { try archive.save(progress) }
    #expect(try Data(contentsOf: archive.url) == corrupt)
    let future = Data("{\"schemaVersion\":999,\"recent\":[],\"bests\":[]}".utf8); try future.write(to: archive.url)
    #expect(throws: (any Error).self) { try archive.save(progress) }
    #expect(try Data(contentsOf: archive.url) == future)
}

@Test func practicePerfectBoundaryMatchesOriginalClassicWindowExactly() throws {
    let boundary = SkillDrill.precision.difficulty.perfectArcDegrees / 2
    #expect(try SkillLabEngine.feedback(marker: boundary, target: 0, direction: 1, drill: .precision).quality == .perfect)
    #expect(try SkillLabEngine.feedback(marker: -boundary, target: 0, direction: -1, drill: .precision).quality == .perfect)
}
