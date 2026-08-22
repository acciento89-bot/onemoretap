package com.kamilunavo.onemoretap.game

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ClassicGameEngineTest {
    @Test
    fun perfectHitBuildsComboAndCoins() {
        val engine = ClassicGameEngine()
        val result = engine.evaluateTap(10.0, 10.0)
        assertEquals(HitQuality.PERFECT, result.quality)
        assertEquals(1, engine.score)
        assertEquals(1, engine.combo)
        assertEquals(2, engine.coinsEarned)
    }

    @Test
    fun fifthPerfectGetsScoreBonus() {
        val engine = ClassicGameEngine()
        repeat(4) { engine.evaluateTap(0.0, 0.0) }
        val result = engine.evaluateTap(0.0, 0.0)
        assertEquals(2, result.scoreDelta)
        assertEquals(5, result.combo)
    }

    @Test
    fun missEndsRunAndReviveWorksExactlyOnce() {
        val engine = ClassicGameEngine()
        engine.evaluateTap(180.0, 0.0)
        assertTrue(engine.isGameOver)
        assertTrue(engine.reviveAfterMiss())
        assertFalse(engine.isGameOver)
        engine.evaluateTap(180.0, 0.0)
        assertFalse(engine.reviveAfterMiss())
    }

    @Test
    fun difficultyMatchesIosThresholds() {
        val engine = ClassicGameEngine()
        val start = engine.difficulty(0)
        assertEquals(1.35, start.angularSpeed, 0.0001)
        assertEquals(72.0, start.targetArcDegrees, 0.0001)
        assertFalse(start.reversesDirection)
        assertTrue(engine.difficulty(12).reversesDirection)
        assertEquals(22.0, engine.difficulty(1000).targetArcDegrees, 0.0001)
        assertEquals(4.2, engine.difficulty(1000).angularSpeed, 0.0001)
    }

    @Test
    fun interstitialCadenceMatchesIos() {
        val expected = setOf(4, 7, 10, 13)
        for (restart in 1..14) {
            assertEquals(restart in expected, InterstitialCadence.shouldShow(restart))
        }
    }

    @Test
    fun angularDistanceWrapsAtZero() {
        assertEquals(2.0, ClassicGameEngine.shortestAngularDistanceDegrees(359.0, 1.0), 0.0001)
        assertEquals(355.0, ClassicGameEngine.normalizeDegrees(-5.0), 0.0001)
    }
}
