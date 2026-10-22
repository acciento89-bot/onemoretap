package com.kamilunavo.onemoretap.audio

/** Focus permission never overrides the user's Sound choice or Activity visibility. */
class MusicPlaybackState {
    private var foreground = false
    private var enabled = true
    private var focused = false
    private var blocked = false
    private var ducked = false
    val wantsFocus: Boolean get() = foreground && enabled && !blocked
    val shouldPlay: Boolean get() = wantsFocus && focused
    val volume: Float get() = if (ducked) 0.2f else 1f

    fun setForeground(value: Boolean) {
        if (foreground == value) return
        foreground = value; focused = false; blocked = false; ducked = false
    }
    fun setEnabled(value: Boolean) {
        if (enabled == value) return
        enabled = value; focused = false; blocked = false; ducked = false
    }
    fun focusGained() { focused = wantsFocus; ducked = false }
    fun focusDucked() { if (focused) ducked = true }
    fun focusLost(permanent: Boolean) { focused = false; ducked = false; if (permanent) blocked = true }
}
