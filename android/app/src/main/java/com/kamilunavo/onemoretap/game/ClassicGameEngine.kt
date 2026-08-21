package com.kamilunavo.onemoretap.game

import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

data class ClassicDifficulty(
    val angularSpeed: Double,
    val targetArcDegrees: Double,
    val perfectArcDegrees: Double,
    val reversesDirection: Boolean,
)

enum class HitQuality { PERFECT, GOOD, MISS }

data class HitResult(
    val quality: HitQuality,
    val scoreDelta: Int,
    val coinDelta: Int,
    val combo: Int,
    val newScore: Int,
)

object InterstitialCadence {
    fun shouldShow(onRestart: Int): Boolean {
        if (onRestart < 4) return false
        return (onRestart - 4) % 3 == 0
    }
}

class ClassicGameEngine {
    var score: Int = 0
        private set
    var combo: Int = 0
        private set
    var coinsEarned: Int = 0
        private set
    var isGameOver: Boolean = false
        private set
    var hasUsedRevive: Boolean = false
        private set

    fun reset() {
        score = 0
        combo = 0
        coinsEarned = 0
        isGameOver = false
        hasUsedRevive = false
    }

    fun reviveAfterMiss(): Boolean {
        if (!isGameOver || hasUsedRevive) return false
        hasUsedRevive = true
        isGameOver = false
        combo = 0
        return true
    }

    fun difficulty(forScore: Int = score): ClassicDifficulty {
        val value = max(0, forScore)
        val angularSpeed = min(4.2, 1.35 + value * 0.045)
        val targetArc = max(22.0, 72.0 - value * 0.72)
        val perfectArc = max(7.0, targetArc * 0.28)
        return ClassicDifficulty(
            angularSpeed = angularSpeed,
            targetArcDegrees = targetArc,
            perfectArcDegrees = perfectArc,
            reversesDirection = value >= 12,
        )
    }

    fun evaluateTap(markerAngle: Double, targetAngle: Double): HitResult {
        if (isGameOver) {
            return HitResult(HitQuality.MISS, 0, 0, combo, score)
        }

        val difficulty = difficulty()
        val delta = shortestAngularDistanceDegrees(markerAngle, targetAngle)
        val halfTarget = difficulty.targetArcDegrees / 2.0
        val halfPerfect = difficulty.perfectArcDegrees / 2.0

        if (delta <= halfPerfect) {
            combo += 1
            val bonus = 1 + combo / 5
            score += bonus
            val coins = 2 + combo / 10
            coinsEarned += coins
            return HitResult(HitQuality.PERFECT, bonus, coins, combo, score)
        }

        if (delta <= halfTarget) {
            combo += 1
            score += 1
            val coins = if (combo % 5 == 0) 1 else 0
            coinsEarned += coins
            return HitResult(HitQuality.GOOD, 1, coins, combo, score)
        }

        combo = 0
        isGameOver = true
        return HitResult(HitQuality.MISS, 0, 0, 0, score)
    }

    companion object {
        fun shortestAngularDistanceDegrees(a: Double, b: Double): Double {
            val normalizedA = normalizeDegrees(a)
            val normalizedB = normalizeDegrees(b)
            val raw = abs(normalizedA - normalizedB)
            return min(raw, 360.0 - raw)
        }

        fun normalizeDegrees(value: Double): Double {
            val result = value % 360.0
            return if (result >= 0) result else result + 360.0
        }
    }
}
