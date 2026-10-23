/// Playback permission never overrides the saved Sound choice or background state.
public struct MusicPlaybackState: Sendable {
    private var foreground = false
    private var enabled = true
    private var interrupted = false
    private var held = false
    public init() {}
    public var shouldPlay: Bool { foreground && enabled && !interrupted && !held }
    public mutating func setForeground(_ value: Bool) {
        guard foreground != value else { return }
        foreground = value
        // Scene reactivation alone must not override a no-resume or route hold.
    }
    public mutating func setEnabled(_ value: Bool) {
        guard enabled != value else { return }
        enabled = value
        if value { held = false }
    }
    public mutating func interruptionBegan() { interrupted = true }
    public mutating func interruptionEnded(shouldResume: Bool) {
        interrupted = false
        held = !shouldResume
    }
    public mutating func hold() { held = true }
}
