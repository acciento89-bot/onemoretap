package com.kamilunavo.onemoretap.game

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.kamilunavo.onemoretap.PlayerProfile
import kotlin.math.PI
import kotlin.random.Random

class ClassicGameSession(private val profile: PlayerProfile) {
    private var engine = ClassicGameEngine()
    private var runCommitted = false

    var score by mutableIntStateOf(0)
        private set
    var combo by mutableIntStateOf(0)
        private set
    var coinsEarned by mutableIntStateOf(0)
        private set
    var statusText by mutableStateOf<String?>(null)
        private set
    var isGameOver by mutableStateOf(false)
        private set
    var isPaused by mutableStateOf(false)
        private set
    var isNewBest by mutableStateOf(false)
        private set
    var hasUsedContinue by mutableStateOf(false)
        private set
    var currentAngle by mutableDoubleStateOf(0.0)
        private set
    var targetAngle by mutableDoubleStateOf(0.0)
        private set
    var direction by mutableDoubleStateOf(1.0)
        private set

    val difficulty: ClassicDifficulty
        get() = engine.difficulty()

    val canUseContinue: Boolean
        get() = isGameOver && !hasUsedContinue && !runCommitted

    init {
        startNewRun()
    }

    fun startNewRun() {
        if (isGameOver) commitRunIfNeeded()
        engine.reset()
        runCommitted = false
        score = 0
        combo = 0
        coinsEarned = 0
        statusText = null
        isGameOver = false
        isPaused = false
        isNewBest = false
        hasUsedContinue = false
        currentAngle = Random.nextDouble(0.0, 360.0)
        targetAngle = randomTargetAngle(currentAngle)
        direction = if (Random.nextBoolean()) 1.0 else -1.0
    }

    fun tick(deltaSeconds: Double) {
        if (engine.isGameOver || isPaused) return
        val bounded = deltaSeconds.coerceAtMost(1.0 / 20.0)
        val radiansPerSecond = engine.difficulty().angularSpeed
        currentAngle = ClassicGameEngine.normalizeDegrees(
            currentAngle + direction * radiansPerSecond * bounded * 180.0 / PI
        )
    }

    fun tap(): HitResult? {
        if (engine.isGameOver || isPaused) return null
        val result = engine.evaluateTap(currentAngle, targetAngle)
        syncFromEngine()
        when (result.quality) {
            HitQuality.PERFECT -> {
                statusText = "PERFECT"
                advanceAfterHit()
            }
            HitQuality.GOOD -> {
                statusText = null
                advanceAfterHit()
            }
            HitQuality.MISS -> {
                statusText = null
                isGameOver = true
                isPaused = false
                isNewBest = score > profile.bestScore
            }
        }
        return result
    }

    fun clearStatus(expected: String) {
        if (statusText == expected) statusText = null
    }

    fun continueAfterReward(): Boolean {
        if (!canUseContinue || !engine.reviveAfterMiss()) return false
        hasUsedContinue = true
        isGameOver = false
        isPaused = false
        isNewBest = false
        combo = 0
        statusText = "CONTINUE"
        currentAngle = Random.nextDouble(0.0, 360.0)
        targetAngle = randomTargetAngle(currentAngle)
        direction = if (Random.nextBoolean()) 1.0 else -1.0
        return true
    }

    fun togglePause() {
        if (isGameOver) return
        isPaused = !isPaused
    }

    fun pause() {
        if (!isGameOver) isPaused = true
    }

    fun resume() {
        if (!isGameOver) isPaused = false
    }

    fun commitRunIfNeeded() {
        if (runCommitted || !isGameOver) return
        runCommitted = true
        isNewBest = profile.completeRun(score, coinsEarned)
    }

    private fun syncFromEngine() {
        score = engine.score
        combo = engine.combo
        coinsEarned = engine.coinsEarned
    }

    private fun advanceAfterHit() {
        val difficulty = engine.difficulty()
        if (difficulty.reversesDirection && Random.nextDouble() < 0.30) {
            direction *= -1.0
        }
        targetAngle = randomTargetAngle(currentAngle)
    }

    private fun randomTargetAngle(avoiding: Double): Double {
        repeat(12) {
            val candidate = Random.nextDouble(0.0, 360.0)
            if (ClassicGameEngine.shortestAngularDistanceDegrees(candidate, avoiding) > 52.0) {
                return candidate
            }
        }
        return ClassicGameEngine.normalizeDegrees(avoiding + 120.0)
    }
}
