import Testing
@testable import OneMoreTapCore

@Test func musicRequiresForegroundAndUserSoundChoice() {
 var state=MusicPlaybackState()
 #expect(!state.shouldPlay)
 state.setForeground(true); #expect(state.shouldPlay)
 state.setEnabled(false); #expect(!state.shouldPlay)
 state.setForeground(false); state.setForeground(true); #expect(!state.shouldPlay)
 state.setEnabled(true); #expect(state.shouldPlay)
 state.setForeground(false); #expect(!state.shouldPlay)
}
@Test func interruptionCannotOverrideMuteOrResumeWithoutPermission() {
 var state=MusicPlaybackState(); state.setForeground(true)
 state.interruptionBegan(); #expect(!state.shouldPlay)
 state.interruptionEnded(shouldResume:false); #expect(!state.shouldPlay)
 // Repeated view updates must not reset an interruption hold.
 state.setForeground(true); state.setEnabled(true); #expect(!state.shouldPlay)
 state.setForeground(false); state.setForeground(true); #expect(!state.shouldPlay)
 state.setEnabled(false); state.setEnabled(true); #expect(state.shouldPlay)
 state.interruptionBegan(); state.setEnabled(false)
 state.interruptionEnded(shouldResume:true); #expect(!state.shouldPlay)
 state.setEnabled(true); #expect(state.shouldPlay)
 state.interruptionBegan(); state.interruptionEnded(shouldResume:true); #expect(state.shouldPlay)
}
@Test func unpluggedHeadphonesHoldUntilExplicitSoundReenable() {
 var state=MusicPlaybackState();state.setForeground(true)
 state.hold(); #expect(!state.shouldPlay)
 state.setForeground(true); #expect(!state.shouldPlay)
 state.setEnabled(false);state.setEnabled(true); #expect(state.shouldPlay)
 state.hold();state.setForeground(false);state.setForeground(true); #expect(!state.shouldPlay)
}
