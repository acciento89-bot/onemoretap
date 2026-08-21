package com.kamilunavo.onemoretap

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color

enum class GameTheme(
    val id: String,
    val title: String,
    val subtitle: String,
    val productId: String?,
    val primary: Color,
    val secondary: Color,
    val backgroundTop: Color,
    val backgroundBottom: Color,
) {
    NEON(
        id = "neon",
        title = "NEON",
        subtitle = "Original cyan energy",
        productId = null,
        primary = Color.Cyan,
        secondary = Color(0xFF9E61FF),
        backgroundTop = Color(0xFF05060D),
        backgroundBottom = Color(0xFF0E0616),
    ),
    FIRE(
        id = "fire",
        title = "FIRE",
        subtitle = "Hot orange and red",
        productId = MonetizationProducts.THEME_FIRE,
        primary = Color(0xFFFF591F),
        secondary = Color(0xFFFF1F2E),
        backgroundTop = Color(0xFF110505),
        backgroundBottom = Color(0xFF180703),
    ),
    GALAXY(
        id = "galaxy",
        title = "GALAXY",
        subtitle = "Deep violet starlight",
        productId = MonetizationProducts.THEME_GALAXY,
        primary = Color(0xFFA861FF),
        secondary = Color(0xFF2EAFFF),
        backgroundTop = Color(0xFF060512),
        backgroundBottom = Color(0xFF0E061C),
    ),
    RETRO(
        id = "retro",
        title = "RETRO",
        subtitle = "Arcade green and amber",
        productId = MonetizationProducts.THEME_RETRO,
        primary = Color(0xFF52FF8C),
        secondary = Color(0xFFFFAD29),
        backgroundTop = Color(0xFF050B09),
        backgroundBottom = Color(0xFF110C03),
    );

    companion object {
        fun fromId(id: String?): GameTheme = entries.firstOrNull { it.id == id } ?: NEON
    }
}

object MonetizationProducts {
    const val REMOVE_ADS = "com.kamilunavo.onemoretap.removeads"
    // Intentionally mirrors the already-live legacy iOS product identifier.
    const val THEME_FIRE = "om.kamilunavo.onemoretap.theme.fire"
    const val THEME_GALAXY = "com.kamilunavo.onemoretap.theme.galaxy"
    const val THEME_RETRO = "com.kamilunavo.onemoretap.theme.retro"
    const val ALL_THEMES = "com.kamilunavo.onemoretap.theme.all"

    val ALL = listOf(REMOVE_ADS, THEME_FIRE, THEME_GALAXY, THEME_RETRO, ALL_THEMES)
}

class PlayerProfile(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences("navotap_profile", Context.MODE_PRIVATE)

    var bestScore by mutableIntStateOf(prefs.getInt("classic.bestScore", 0))
        private set
    var coins by mutableIntStateOf(prefs.getInt("wallet.coins", 0))
        private set
    var soundEnabled by mutableStateOf(prefs.getBoolean("settings.soundEnabled", true))
        private set
    var hapticsEnabled by mutableStateOf(prefs.getBoolean("settings.hapticsEnabled", true))
        private set
    var selectedTheme by mutableStateOf(GameTheme.fromId(prefs.getString("cosmetics.selectedTheme", null)))
        private set
    var restartCount by mutableIntStateOf(prefs.getInt("ads.restartCount", 0))
        private set

    fun completeRun(score: Int, coinsEarned: Int): Boolean {
        val isNewBest = score > bestScore
        if (isNewBest) bestScore = score
        if (coinsEarned > 0) coins += coinsEarned
        prefs.edit()
            .putInt("classic.bestScore", bestScore)
            .putInt("wallet.coins", coins)
            .apply()
        return isNewBest
    }

    fun setSound(enabled: Boolean) {
        soundEnabled = enabled
        prefs.edit().putBoolean("settings.soundEnabled", enabled).apply()
    }

    fun setHaptics(enabled: Boolean) {
        hapticsEnabled = enabled
        prefs.edit().putBoolean("settings.hapticsEnabled", enabled).apply()
    }

    fun selectTheme(theme: GameTheme) {
        selectedTheme = theme
        prefs.edit().putString("cosmetics.selectedTheme", theme.id).apply()
    }

    fun recordRestart(): Int {
        restartCount += 1
        prefs.edit().putInt("ads.restartCount", restartCount).apply()
        return restartCount
    }
}
