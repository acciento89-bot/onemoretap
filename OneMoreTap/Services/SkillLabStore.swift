import Foundation
import Combine

@MainActor final class SkillLabStore: ObservableObject {
    @Published private(set) var progress = SkillLabProgress()
    @Published private(set) var loadFailed = false
    @Published private(set) var saveFailed = false
    private let archive: SkillLabArchive
    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        archive = SkillLabArchive(url: base.appendingPathComponent("NavoTap/skill-lab.json"))
        reload()
    }
    func reload() {
        do { progress = try archive.load(); loadFailed = false; saveFailed = false }
        catch { loadFailed = true }
    }
    @discardableResult func save(_ result: SkillLabSummary) -> Bool {
        guard !loadFailed else { return false }
        var next = progress
        _ = next.record(result)
        do { try archive.save(next); progress = next; saveFailed = false; return true }
        catch { saveFailed = true; return false }
    }
}
