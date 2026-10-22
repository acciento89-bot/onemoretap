package com.kamilunavo.onemoretap.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import com.kamilunavo.onemoretap.R

/** One foreground-only original loop. Ads/other audio own focus whenever Android says so. */
class BackgroundMusic(context: Context) {
    private val context = context.applicationContext
    private val audio = this.context.getSystemService(AudioManager::class.java)
    private val state = MusicPlaybackState()
    private var player: MediaPlayer? = null
    private var requested = false
    private var closed = false
    private var unavailable = false
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()
    private val focus = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
        .setAudioAttributes(attributes)
        .setOnAudioFocusChangeListener({ change ->
            if (!closed) {
                when (change) {
                    AudioManager.AUDIOFOCUS_GAIN -> state.focusGained()
                    AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> state.focusDucked()
                    AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> state.focusLost(false)
                    AudioManager.AUDIOFOCUS_LOSS -> state.focusLost(true)
                }
                applyPlayback()
            }
        }, Handler(Looper.getMainLooper())).build()

    fun setForeground(value: Boolean) { if (!closed) { state.setForeground(value); reconcile() } }
    fun setEnabled(value: Boolean) { if (!closed) { state.setEnabled(value); reconcile() } }
    private fun reconcile() {
        if (!state.wantsFocus && requested) {
            audio.abandonAudioFocusRequest(focus); requested = false
        }
        if (state.wantsFocus && !requested && !unavailable) {
            requested = true
            val granted = try { audio.requestAudioFocus(focus) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED } catch (_: RuntimeException) { false }
            if (granted) state.focusGained() else state.focusLost(false)
        }
        applyPlayback()
    }
    private fun applyPlayback() {
        try {
            if (state.shouldPlay && !unavailable && !closed) {
                if (player == null) {
                    player = MediaPlayer.create(context,R.raw.pulse_garden,attributes,AudioManager.AUDIO_SESSION_ID_GENERATE)?.apply {
                        isLooping = true
                        setOnErrorListener { _,_,_ -> unavailable = true; releasePlayer(); true }
                    }
                    if (player == null) { unavailable = true; return }
                }
                player?.setVolume(state.volume * 0.38f,state.volume * 0.38f)
                if (player?.isPlaying == false) player?.start()
            } else if (player?.isPlaying == true) player?.pause()
        } catch (_: RuntimeException) { unavailable = true; releasePlayer() }
    }
    private fun releasePlayer() { val old = player; player = null; try { old?.release() } catch (_: RuntimeException) { } }
    fun close() {
        if (closed) return
        state.setForeground(false); closed = true
        if (requested) { audio.abandonAudioFocusRequest(focus); requested = false }
        releasePlayer()
    }
}
