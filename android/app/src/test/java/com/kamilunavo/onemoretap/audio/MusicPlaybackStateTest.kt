package com.kamilunavo.onemoretap.audio

import org.junit.Assert.*
import org.junit.Test

class MusicPlaybackStateTest {
    @Test fun playsOnlyWithVisibleEnabledFocusedActivity() {
        val state = MusicPlaybackState()
        assertFalse(state.shouldPlay)
        state.setForeground(true); assertTrue(state.wantsFocus); assertFalse(state.shouldPlay)
        state.focusGained(); assertTrue(state.shouldPlay)
        state.setEnabled(false); assertFalse(state.shouldPlay); assertFalse(state.wantsFocus)
        state.setEnabled(true); assertFalse(state.shouldPlay); assertTrue(state.wantsFocus)
        state.focusGained(); assertTrue(state.shouldPlay)
        state.setForeground(false); assertFalse(state.shouldPlay); assertFalse(state.wantsFocus)
        state.focusGained(); assertFalse(state.shouldPlay)
    }
    @Test fun transientLossDucksOrPausesAndNeverBypassesMute() {
        val state = MusicPlaybackState(); state.setForeground(true); state.focusGained()
        state.focusDucked(); assertTrue(state.shouldPlay); assertEquals(0.2f,state.volume,0.0001f)
        state.focusLost(false); assertFalse(state.shouldPlay)
        state.focusGained(); assertTrue(state.shouldPlay); assertEquals(1f,state.volume,0.0001f)
        state.setEnabled(false); state.focusGained(); assertFalse(state.shouldPlay)
    }
    @Test fun permanentLossDoesNotStealFocusUntilNewUserOrForegroundTransition() {
        val state = MusicPlaybackState(); state.setForeground(true); state.focusGained()
        state.focusLost(true); assertFalse(state.shouldPlay); assertFalse(state.wantsFocus)
        state.setForeground(true); state.setEnabled(true); assertFalse(state.wantsFocus)
        state.setForeground(false); state.setForeground(true); assertTrue(state.wantsFocus)
        state.focusGained(); assertTrue(state.shouldPlay)
    }
}
