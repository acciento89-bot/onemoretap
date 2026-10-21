package com.kamilunavo.onemoretap.game

import org.junit.Assert.*
import org.junit.Test
import java.nio.file.Files
import java.io.File

class SkillLabTest {
    @Test fun signedFeedbackWrapsAndReversesWithMotion() {
        val early = SkillLabEngine.feedback(348.0,0.0,1,SkillDrill.TIMING)
        assertEquals(TimingSide.EARLY,early.side); assertEquals(-12.0,early.signedError,0.00001); assertEquals(HitQuality.GOOD,early.quality)
        assertEquals(15.0,SkillLabEngine.feedback(5.0,350.0,1,SkillDrill.TIMING).signedError,0.00001)
        assertEquals(TimingSide.EARLY,SkillLabEngine.feedback(10.0,0.0,-1,SkillDrill.TIMING).side)
        val boundary = SkillDrill.PRECISION.difficulty.targetArcDegrees / 2
        assertEquals(HitQuality.GOOD,SkillLabEngine.feedback(boundary,0.0,1,SkillDrill.PRECISION).quality)
        assertEquals(HitQuality.MISS,SkillLabEngine.feedback(boundary+0.01,0.0,1,SkillDrill.PRECISION).quality)
        assertThrows(IllegalArgumentException::class.java) { SkillLabEngine.feedback(Double.NaN,0.0,1,SkillDrill.TIMING) }
        assertThrows(IllegalArgumentException::class.java) { SkillLabEngine.feedback(0.0,0.0,0,SkillDrill.TIMING) }
    }
    @Test fun exactPerfectBoundaryMatchesCalibratedClassicWindow() {
        val boundary = SkillDrill.PRECISION.difficulty.perfectArcDegrees / 2
        assertEquals(HitQuality.PERFECT,SkillLabEngine.feedback(boundary,0.0,1,SkillDrill.PRECISION).quality)
        assertEquals(HitQuality.PERFECT,SkillLabEngine.feedback(-boundary,0.0,-1,SkillDrill.PRECISION).quality)
    }
    @Test fun trialLifecycleRejectsDuplicatePausedAndInvalidTaps() {
        val engine = SkillLabEngine(SkillDrill.DIRECTIONS)
        val before = engine.markerAngle; engine.tick(0.01); assertNotEquals(before,engine.markerAngle)
        engine.pause(); val paused = engine.markerAngle; engine.tick(1.0)
        assertEquals(paused,engine.markerAngle,0.0); assertNull(engine.tap(engine.targetAngle)); engine.resume()
        repeat(12) { index ->
            assertEquals(if(index % 2 == 0) 1 else -1,engine.direction)
            assertNotNull(engine.tap(engine.targetAngle)); assertNull(engine.tap(engine.targetAngle))
            val frozen = engine.markerAngle; engine.tick(1.0); assertEquals(frozen,engine.markerAngle,0.0)
            if(index < 11) assertTrue(engine.nextTrial())
        }
        assertTrue(engine.isComplete); assertEquals(12,engine.attempts.size); assertFalse(engine.nextTrial())
        val summary = engine.summary(100L)
        assertEquals(12,summary.hits); assertEquals(12,summary.perfects); assertEquals(0.0,summary.meanError,0.0)
        val invalid = SkillLabEngine(SkillDrill.TIMING)
        assertThrows(IllegalArgumentException::class.java) { invalid.tap(Double.POSITIVE_INFINITY) }
        assertThrows(IllegalArgumentException::class.java) { invalid.summary(100L) }
        val reference = SkillLabEngine(SkillDrill.TIMING)
        invalid.tick(9.0); reference.tick(0.05); assertEquals(reference.markerAngle,invalid.markerAngle,0.0)
    }
    private fun completed(drill: SkillDrill,error: Double): SkillLabSummary {
        val engine = SkillLabEngine(drill)
        repeat(12) { index -> engine.tap(engine.targetAngle+error); if(index<11) engine.nextTrial() }
        return engine.summary(100L)
    }
    @Test fun archiveSeparatesDrillBestsIdempotentlyAndProtectsLegacyData() {
        val dir = Files.createTempDirectory("navotap-lab").toFile()
        try {
            val legacy = File(dir,"navotap_profile.xml").apply { writeText("old bestscore/coins") }
            val bytes = legacy.readBytes(); val archive = SkillLabArchive(File(dir,"skill-lab.json"))
            val progress = archive.load()
            val good = completed(SkillDrill.TIMING,12.0); val perfect = completed(SkillDrill.TIMING,0.0); val other = completed(SkillDrill.PRECISION,0.0)
            assertTrue(progress.record(good)); assertTrue(progress.record(perfect)); assertFalse(progress.record(perfect)); assertTrue(progress.record(other))
            assertEquals(perfect.id,progress.best(SkillDrill.TIMING)?.id); assertEquals(other.id,progress.best(SkillDrill.PRECISION)?.id)
            archive.save(progress); assertEquals(progress,archive.load()); assertArrayEquals(bytes,legacy.readBytes())
            archive.file.writeText("{broken")
            assertThrows(Exception::class.java) { archive.save(progress) }; assertEquals("{broken",archive.file.readText())
            val future = "{\"schemaVersion\":999,\"recent\":[],\"bests\":[]}"
            archive.file.writeText(future); assertThrows(Exception::class.java) { archive.save(progress) }; assertEquals(future,archive.file.readText())
            assertArrayEquals(bytes,legacy.readBytes())
        } finally { dir.deleteRecursively() }
    }
}
