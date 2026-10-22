package com.kamilunavo.onemoretap

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.ViewModel
import com.kamilunavo.onemoretap.game.*
import java.io.File
import java.text.DateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

/** Survives Activity configuration recreation; incomplete drills are not persisted. */
class SkillLabSession : ViewModel() {
    var isVisible by mutableStateOf(false)
    var engine: SkillLabEngine? = null; private set
    var result by mutableStateOf<SkillLabSummary?>(null); private set
    var saved by mutableStateOf(false)
    var revision by mutableIntStateOf(0); private set
    var sessionID by mutableIntStateOf(0); private set
    fun start(drill: SkillDrill) { engine = SkillLabEngine(drill); result = null; saved = false; sessionID++; revision++ }
    fun tick(seconds: Double) {
        val current = engine ?: return
        if(current.isPaused || current.isComplete || current.lastFeedback != null) return
        current.tick(seconds); revision++
    }
    fun pause() { engine?.pause(); revision++ }
    fun resume() { engine?.resume(); revision++ }
    fun next() { engine?.nextTrial(); revision++ }
    fun tap(): SkillFeedback? {
        val value = engine?.tap() ?: return null
        if(engine?.isComplete == true) result = engine!!.summary(System.currentTimeMillis())
        revision++; return value
    }
    fun menu() { engine = null; result = null; saved = false; revision++ }
}
private class SkillLabStorage(file: File) {
    private val archive = SkillLabArchive(file)
    var progress by mutableStateOf(SkillLabProgress()); private set
    var loadFailed by mutableStateOf(false); private set
    var saveFailed by mutableStateOf(false); private set
    init { reload() }
    fun reload() {
        runCatching { archive.load() }.onSuccess { progress = it; loadFailed = false; saveFailed = false }.onFailure { loadFailed = true }
    }
    fun save(result: SkillLabSummary): Boolean {
        if(loadFailed) return false
        val next = progress.copy(); next.record(result)
        return runCatching { archive.save(next) }.fold({ progress = next; saveFailed = false; true },{ saveFailed = true; false })
    }
}
private data class SkillLabRenderSnapshot(
    val markerAngle: Double, val targetAngle: Double, val targetArc: Double,
    val perfectArc: Double, val paused: Boolean, val hasFeedback: Boolean,
)
private fun labText(de: Boolean,en: String,german: String) = if(de) german else en
private fun labTitle(de: Boolean,drill: SkillDrill) = when(drill) {
    SkillDrill.TIMING -> labText(de,"Steady timing","Gleichmäßiges Timing")
    SkillDrill.PRECISION -> labText(de,"Precision","Präzision")
    SkillDrill.DIRECTIONS -> labText(de,"Direction changes","Richtungswechsel")
}
private fun number(value: Double) = String.format(Locale.getDefault(),"%.1f",value)
private fun feedbackText(de: Boolean,feedback: SkillFeedback): String {
    val quality = when(feedback.quality) { HitQuality.PERFECT -> labText(de,"Perfect","Perfekt"); HitQuality.GOOD -> labText(de,"Hit","Treffer"); HitQuality.MISS -> labText(de,"Miss","Verfehlt") }
    val side = when(feedback.side) { TimingSide.EARLY -> labText(de,"early","früh"); TimingSide.LATE -> labText(de,"late","spät"); TimingSide.ON_TIME -> labText(de,"on time","genau") }
    return "$quality · $side · ${number(abs(feedback.signedError))}°"
}
private fun metrics(de: Boolean,result: SkillLabSummary) = "${result.hits}/12 ${labText(de,"hits","Treffer")} · ${result.perfects} ${labText(de,"perfect","perfekt")} · ${number(result.meanError)}° ${labText(de,"mean error","mittlerer Fehler") }"

@Composable fun SkillLabScreen(profile: PlayerProfile,session: SkillLabSession,onHome: () -> Unit) {
    val context = LocalContext.current
    val storage = remember { SkillLabStorage(File(context.filesDir,"NavoTap/skill-lab.json")) }
    val de = LocalConfiguration.current.locales[0].language == "de"
    val lifecycle = LocalLifecycleOwner.current
    val view = LocalView.current
    val current = remember(session.revision) { session.engine }
    val result = session.result
    DisposableEffect(lifecycle) {
        val observer = LifecycleEventObserver { _,event -> if(event == Lifecycle.Event.ON_PAUSE) session.pause() }
        lifecycle.lifecycle.addObserver(observer)
        onDispose { lifecycle.lifecycle.removeObserver(observer); session.pause() }
    }
    LaunchedEffect(session.sessionID) {
        var previous = 0L
        while(session.engine != null && session.result == null) {
            withFrameNanos { now ->
                if(previous != 0L) session.tick((now-previous) / 1_000_000_000.0)
                previous = now
            }
        }
    }
    BackHandler { if(current != null) { session.pause(); session.menu() } else onHome() }
    fun tap() {
        session.tap() ?: return
        if(profile.hapticsEnabled) view.performHapticFeedback(android.view.HapticFeedbackConstants.CLOCK_TICK)
        session.result?.let { session.saved = storage.save(it) }
    }
    Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().verticalScroll(rememberScrollState()).padding(22.dp),verticalArrangement = Arrangement.spacedBy(16.dp)) {
        TextButton(onClick = { session.pause(); onHome() }) { Text(labText(de,"Home","Startseite")) }
        Text("SKILL LAB",style = MaterialTheme.typography.headlineLarge)
        Text(labText(de,"Practice only. Classic records, coins and ad continues stay separate. Only completed results are saved on this device.","Nur zum Üben. Classic-Rekorde, Münzen und Werbe-Continues bleiben getrennt. Nur abgeschlossene Ergebnisse werden auf diesem Gerät gespeichert."),style = MaterialTheme.typography.bodySmall)
        if(storage.loadFailed) {
            Text(labText(de,"Practice data could not be loaded. Its file is preserved; saving is blocked.","Übungsdaten konnten nicht geladen werden. Die Datei bleibt erhalten; Speichern ist gesperrt."),color = MaterialTheme.colorScheme.error)
            OutlinedButton(onClick = storage::reload) { Text(labText(de,"Retry loading","Erneut laden")) }
        }
        if(storage.saveFailed) Text(labText(de,"Saving failed. Your result remains here; retry below.","Speichern fehlgeschlagen. Dein Ergebnis bleibt hier; versuche es unten erneut."),color = MaterialTheme.colorScheme.error)
        when {
            result != null -> {
                Text(labTitle(de,result.drill)+labText(de," complete"," abgeschlossen"),style = MaterialTheme.typography.headlineSmall)
                Text(metrics(de,result),style = MaterialTheme.typography.titleMedium)
                storage.progress.best(result.drill)?.let { Text(labText(de,"Personal best: ","Eigener Bestwert: ")+metrics(de,it)) }
                Text(labText(de,"Best ranks by hits, then perfects, then lower mean error.","Bestwerte zählen zuerst Treffer, dann perfekte Treffer und zuletzt den kleineren mittleren Fehler."),style = MaterialTheme.typography.bodySmall)
                Text(labText(de,"Late (+) / on time (0) / early (−)","Spät (+) / genau (0) / früh (−)"))
                ErrorChart(result,profile.selectedTheme.primary)
                result.attempts.forEachIndexed { index,feedback -> Text("${index+1}. "+feedbackText(de,feedback)) }
                Text(labText(de,"Offsets show the nearest target crossing, in degrees. The chart spans −180° to +180°.","Abweichungen zeigen die nächste Zielpassage in Grad. Das Diagramm reicht von −180° bis +180°."),style = MaterialTheme.typography.bodySmall)
                if(!session.saved) {
                    Button(enabled = !storage.loadFailed,onClick = { session.saved = storage.save(result) }) { Text(labText(de,"Save result","Ergebnis speichern")) }
                    OutlinedButton(onClick = session::menu) { Text(labText(de,"Discard result and choose a drill","Ergebnis verwerfen und Übung wählen")) }
                } else Text(labText(de,"Saved on this device","Auf diesem Gerät gespeichert"))
                Button(enabled = session.saved,onClick = { session.start(result.drill) }) { Text(labText(de,"Repeat drill","Übung wiederholen")) }
                OutlinedButton(enabled = session.saved,onClick = session::menu) { Text(labText(de,"Back to drills","Zur Übungsauswahl")) }
            }
            current != null -> {
                Text(labTitle(de,current.drill),style = MaterialTheme.typography.headlineSmall)
                val trial = (current.attempts.size+if(current.lastFeedback == null) 1 else 0).coerceAtMost(12)
                Text(labText(de,"Attempt","Versuch")+" $trial/12",style = MaterialTheme.typography.titleMedium)
                Text(if(current.direction == 1) labText(de,"Counterclockwise ↺","Gegen den Uhrzeigersinn ↺") else labText(de,"Clockwise ↻","Im Uhrzeigersinn ↻"))
                Text(labText(de,"Target width","Zielbreite")+" ${number(current.drill.difficulty.targetArcDegrees)}°",style = MaterialTheme.typography.bodySmall)
                PracticeRing(SkillLabRenderSnapshot(current.markerAngle,current.targetAngle,
                    current.drill.difficulty.targetArcDegrees,current.drill.difficulty.perfectArcDegrees,
                    current.isPaused,current.lastFeedback != null),profile.selectedTheme,de,::tap)
                when {
                    current.isPaused -> {
                        Text(labText(de,"Paused. Resume when ready.","Pausiert. Setze fort, wenn du bereit bist."))
                        Button(onClick = session::resume) { Text(labText(de,"Resume","Fortsetzen")) }
                    }
                    current.lastFeedback != null -> {
                        Text(feedbackText(de,current.lastFeedback!!),style = MaterialTheme.typography.titleLarge)
                        Button(onClick = session::next) { Text(labText(de,"Next attempt","Nächster Versuch")) }
                    }
                    else -> {
                        Button(onClick = ::tap,modifier = Modifier.fillMaxWidth().heightIn(min = 52.dp)) { Text(labText(de,"TAP","TIPPEN")) }
                        OutlinedButton(onClick = session::pause) { Text(labText(de,"Pause","Pause")) }
                    }
                }
                OutlinedButton(onClick = session::menu) { Text(labText(de,"Back to drills","Zur Übungsauswahl")) }
            }
            else -> {
                SkillDrill.entries.forEach { drill ->
                    Card(Modifier.fillMaxWidth()) {
                        Column(Modifier.padding(16.dp),verticalArrangement = Arrangement.spacedBy(12.dp)) {
                            Text(labTitle(de,drill),style = MaterialTheme.typography.headlineSmall)
                            Text(when(drill) {
                                SkillDrill.TIMING -> labText(de,"A wide target at a steady speed. Learn the center timing without ending on a miss.","Ein breites Ziel bei gleichmäßiger Geschwindigkeit. Übe die Mitte, ohne bei einem Fehltap auszuscheiden.")
                                SkillDrill.PRECISION -> labText(de,"A smaller, faster target calibrated to Classic difficulty 40.","Ein kleineres, schnelleres Ziel mit der Classic-Schwierigkeit 40.")
                                SkillDrill.DIRECTIONS -> labText(de,"Movement alternates after every attempt. Early and late follow the current direction.","Die Bewegung wechselt nach jedem Versuch die Richtung. Früh und spät beziehen sich auf die aktuelle Richtung.")
                            })
                            storage.progress.best(drill)?.let { Text(labText(de,"Personal best: ","Eigener Bestwert: ")+metrics(de,it)) }
                            Button(modifier = Modifier.semantics { contentDescription = labText(de,"Start 12 attempts","12 Versuche starten")+": "+labTitle(de,drill) },enabled = !storage.loadFailed,onClick = { session.start(drill) }) { Text(labText(de,"Start 12 attempts","12 Versuche starten")) }
                        }
                    }
                }
                if(storage.progress.recent.isNotEmpty()) Text(labText(de,"Recent practice","Letzte Übungen"),style = MaterialTheme.typography.headlineSmall)
                storage.progress.recent.forEach { item ->
                    Text(labTitle(de,item.drill)+" · "+DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(Date(item.finishedAt)))
                    Text(metrics(de,item))
                }
            }
        }
    }
}
@Composable private fun PracticeRing(snapshot: SkillLabRenderSnapshot,theme: GameTheme,de: Boolean,onTap: () -> Unit) {
    val enabled = !snapshot.paused && !snapshot.hasFeedback
    Box(Modifier.fillMaxWidth(),contentAlignment = Alignment.Center) {
        Canvas(Modifier.widthIn(max = 360.dp).fillMaxWidth().aspectRatio(1f).semantics { contentDescription = labText(de,"Tap the moving marker at the target","Tippe, wenn die Markierung das Ziel erreicht") }.clickable(enabled = enabled,role = Role.Button,onClick = onTap)) {
            val center = Offset(size.width/2,size.height/2); val radius = size.minDimension * 0.39f
            fun point(angle: Double) = Offset(center.x+radius*cos(angle*PI/180).toFloat(),center.y-radius*sin(angle*PI/180).toFloat())
            fun arc(width: Double) = Path().apply {
                for(index in 0..60) { val p = point(snapshot.targetAngle-width/2+width*index/60); if(index==0) moveTo(p.x,p.y) else lineTo(p.x,p.y) }
            }
            drawCircle(Color.White.copy(alpha = 0.18f),radius,center,style = Stroke(5.dp.toPx()))
            drawPath(arc(snapshot.targetArc),theme.primary.copy(alpha = 0.55f),style = Stroke(14.dp.toPx(),cap = StrokeCap.Round))
            drawPath(arc(snapshot.perfectArc),theme.secondary,style = Stroke(16.dp.toPx(),cap = StrokeCap.Round))
            drawCircle(Color.White,9.dp.toPx(),point(snapshot.markerAngle))
        }
        Text(if(snapshot.paused) labText(de,"PAUSED","PAUSE") else labText(de,"TAP","TIPPEN"),style = MaterialTheme.typography.titleMedium)
    }
}
@Composable private fun ErrorChart(summary: SkillLabSummary,color: Color) {
    Canvas(Modifier.fillMaxWidth().height(140.dp)) {
        val mid = size.height/2
        drawLine(Color.White.copy(alpha = 0.5f),Offset(0f,mid),Offset(size.width,mid),1.dp.toPx())
        summary.attempts.forEachIndexed { index,item ->
            val x = size.width*(index+0.5f)/12
            val y = mid-item.signedError.toFloat()/180*(mid-8.dp.toPx())
            drawCircle(if(item.quality == HitQuality.MISS) Color.Red else color,4.dp.toPx(),Offset(x,y))
        }
    }
}
