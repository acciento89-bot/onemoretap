package com.kamilunavo.onemoretap.game

import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import java.io.File
import java.io.FileOutputStream
import java.nio.file.Files
import java.nio.file.StandardCopyOption
import java.util.UUID
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.PI

enum class SkillDrill {
    TIMING, PRECISION, DIRECTIONS;
    val difficulty: ClassicDifficulty get() = ClassicGameEngine().difficulty(when(this) { TIMING -> 0; PRECISION -> 40; DIRECTIONS -> 12 })
}
enum class TimingSide { EARLY, ON_TIME, LATE }
data class SkillFeedback(val signedError: Double,val drill: SkillDrill) {
    val side: TimingSide get() = if(signedError < 0) TimingSide.EARLY else if(signedError > 0) TimingSide.LATE else TimingSide.ON_TIME
    val quality: HitQuality get() = when {
        abs(signedError) <= drill.difficulty.perfectArcDegrees / 2 -> HitQuality.PERFECT
        abs(signedError) <= drill.difficulty.targetArcDegrees / 2 -> HitQuality.GOOD
        else -> HitQuality.MISS
    }
    internal fun valid() = signedError.isFinite() && signedError in -180.0..180.0
}
data class SkillLabSummary(val id: String,val drill: SkillDrill,val finishedAt: Long,val attempts: List<SkillFeedback>) {
    val hits: Int get() = attempts.count { it.quality != HitQuality.MISS }
    val perfects: Int get() = attempts.count { it.quality == HitQuality.PERFECT }
    val meanError: Double get() = attempts.sumOf { abs(it.signedError) } / attempts.size.coerceAtLeast(1)
    internal fun valid() = validId(id) && attempts.size == 12 && attempts.all { it.drill == drill && it.valid() }
    internal fun outranks(other: SkillLabSummary): Boolean = when {
        hits != other.hits -> hits > other.hits
        perfects != other.perfects -> perfects > other.perfects
        else -> meanError < other.meanError
    }
}

/** Practice never references the Classic profile, wallet, billing or ad APIs. */
class SkillLabEngine(val drill: SkillDrill) {
    private val id = UUID.randomUUID().toString()
    var markerAngle = 240.0; private set
    var targetAngle = 0.0; private set
    var direction = 1; private set
    var attempts: List<SkillFeedback> = emptyList(); private set
    var lastFeedback: SkillFeedback? = null; private set
    var isPaused = false; private set
    val isComplete: Boolean get() = attempts.size == 12
    fun tick(seconds: Double) {
        if(isPaused || isComplete || lastFeedback != null || !seconds.isFinite() || seconds <= 0) return
        markerAngle = ClassicGameEngine.normalizeDegrees(markerAngle + direction * drill.difficulty.angularSpeed * min(seconds,0.05) * 180 / PI)
    }
    fun tap(marker: Double = markerAngle): SkillFeedback? {
        if(isPaused || isComplete || lastFeedback != null) return null
        val result = feedback(marker,targetAngle,direction,drill)
        attempts = attempts + result; lastFeedback = result
        return result
    }
    fun nextTrial(): Boolean {
        if(isPaused || isComplete || lastFeedback == null) return false
        lastFeedback = null
        direction = if(drill == SkillDrill.DIRECTIONS && attempts.size % 2 != 0) -1 else 1
        targetAngle = ClassicGameEngine.normalizeDegrees(attempts.size * 137.5)
        markerAngle = ClassicGameEngine.normalizeDegrees(targetAngle - direction * 120)
        return true
    }
    fun pause() { if(!isComplete) isPaused = true }
    fun resume() { isPaused = false }
    fun summary(at: Long): SkillLabSummary {
        require(isComplete)
        return SkillLabSummary(id,drill,at,attempts.toList())
    }
    companion object {
        fun feedback(marker: Double,target: Double,direction: Int,drill: SkillDrill): SkillFeedback {
            require(marker.isFinite() && target.isFinite() && (direction == 1 || direction == -1))
            val delta = marker % 360.0 - target % 360.0
            var shortest = delta % 360.0
            if(shortest >= 180) shortest -= 360.0
            if(shortest < -180) shortest += 360.0
            return SkillFeedback(shortest * direction,drill)
        }
    }
}

class SkillLabProgress(recent: List<SkillLabSummary> = emptyList(),bests: Map<SkillDrill,SkillLabSummary> = emptyMap()) {
    var recent = recent.toList(); private set
    var bests = bests.toMap(); private set
    fun best(drill: SkillDrill): SkillLabSummary? = bests[drill]
    fun copy() = SkillLabProgress(recent,bests)
    fun record(summary: SkillLabSummary): Boolean {
        if(!summary.valid() || recent.any { it.id == summary.id } || bests.values.any { it.id == summary.id }) return false
        recent = (listOf(summary) + recent).take(30)
        if(best(summary.drill)?.let { summary.outranks(it) } != false) bests = bests + (summary.drill to summary)
        return true
    }
    internal fun validate() {
        require(recent.size <= 30 && recent.map { it.id }.toSet().size == recent.size && recent.all { it.valid() })
        require(bests.size <= SkillDrill.entries.size && bests.all { it.key == it.value.drill && it.value.valid() })
        recent.forEach { item ->
            val best = requireNotNull(best(item.drill))
            require(!item.outranks(best) && (best.id != item.id || best == item))
        }
    }
    override fun equals(other: Any?) = other is SkillLabProgress && recent == other.recent && bests == other.bests
    override fun hashCode() = 31 * recent.hashCode() + bests.hashCode()
}
private fun validId(value: String) = runCatching { UUID.fromString(value).toString().equals(value,ignoreCase = true) }.getOrDefault(false)

/** Explicit JSON tree codec keeps malformed/future data protected without reflective DTO decoding. */
class SkillLabArchive(val file: File) {
    fun load(): SkillLabProgress {
        if(!file.exists()) return SkillLabProgress()
        val document = JsonParser.parseString(file.readText()).asJsonObject
        require(document.long("schemaVersion") == 1L) { "Unsupported practice data version" }
        val data = document.getAsJsonObject("progress")
        val recent = data.getAsJsonArray("recent").map { decodeSummary(it.asJsonObject) }
        val bests = data.getAsJsonObject("bests").entrySet().associate { SkillDrill.valueOf(it.key) to decodeSummary(it.value.asJsonObject) }
        return SkillLabProgress(recent,bests).also { it.validate() }
    }
    fun save(progress: SkillLabProgress) {
        load(); progress.validate()
        val data = JsonObject().apply {
            addProperty("schemaVersion",1)
            add("progress",JsonObject().apply {
                add("recent",JsonArray().apply { progress.recent.forEach { add(encodeSummary(it)) } })
                add("bests",JsonObject().apply { progress.bests.forEach { (key,value) -> add(key.name,encodeSummary(value)) } })
            })
        }.toString().toByteArray(Charsets.UTF_8)
        val parent = file.absoluteFile.parentFile!!
        require(parent.isDirectory || parent.mkdirs())
        val temporary = File.createTempFile("skill-lab-",".tmp",parent)
        try {
            FileOutputStream(temporary).use { it.write(data); it.fd.sync() }
            Files.move(temporary.toPath(),file.toPath(),StandardCopyOption.ATOMIC_MOVE,StandardCopyOption.REPLACE_EXISTING)
        } finally { temporary.delete() }
    }
}
private fun JsonObject.text(key: String): String {
    val value = get(key); require(value != null && value.isJsonPrimitive && value.asJsonPrimitive.isString)
    return value.asString
}
private fun JsonObject.long(key: String): Long {
    val value = get(key); require(value != null && value.isJsonPrimitive && value.asJsonPrimitive.isNumber)
    return value.asBigDecimal.longValueExact()
}
private fun decodeSummary(value: JsonObject): SkillLabSummary {
    val drill = SkillDrill.valueOf(value.text("drill"))
    return SkillLabSummary(value.text("id"),drill,value.long("finishedAt"),value.getAsJsonArray("attempts").map {
        require(it.isJsonPrimitive && it.asJsonPrimitive.isNumber)
        SkillFeedback(it.asDouble,drill)
    }).also { require(it.valid()) }
}
private fun encodeSummary(value: SkillLabSummary) = JsonObject().apply {
    addProperty("id",value.id); addProperty("drill",value.drill.name); addProperty("finishedAt",value.finishedAt)
    add("attempts",JsonArray().apply { value.attempts.forEach { add(it.signedError) } })
}
