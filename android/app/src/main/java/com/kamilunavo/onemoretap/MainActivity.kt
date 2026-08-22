package com.kamilunavo.onemoretap

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Bundle
import android.view.HapticFeedbackConstants
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.kamilunavo.onemoretap.game.ClassicGameSession
import com.kamilunavo.onemoretap.game.HitQuality
import com.kamilunavo.onemoretap.game.InterstitialCadence
import kotlinx.coroutines.delay
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val profile = remember { PlayerProfile(applicationContext) }
            val billing = remember { BillingManager(applicationContext) }
            val ads = remember { AdManager(applicationContext) }
            val session = remember { ClassicGameSession(profile) }

            LaunchedEffect(Unit) {
                ads.requestConsentAndStart(this@MainActivity)
            }

            NavoTapApp(
                activity = this@MainActivity,
                profile = profile,
                billing = billing,
                ads = ads,
                session = session,
            )
        }
    }
}

private enum class AppScreen { HOME, GAME, SHOP, SETTINGS }

@Composable
private fun NavoTapApp(
    activity: MainActivity,
    profile: PlayerProfile,
    billing: BillingManager,
    ads: AdManager,
    session: ClassicGameSession,
) {
    var screen by remember { mutableStateOf(AppScreen.HOME) }
    val theme = profile.selectedTheme

    BackHandler(enabled = screen != AppScreen.HOME) {
        when (screen) {
            AppScreen.GAME -> {
                if (session.isGameOver) session.commitRunIfNeeded() else session.pause()
                screen = AppScreen.HOME
            }
            else -> screen = AppScreen.HOME
        }
    }

    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = theme.primary,
            onPrimary = Color(0xFF041014),
            secondary = theme.secondary,
            onSecondary = Color.White,
            background = theme.backgroundTop,
            onBackground = Color.White,
            surface = Color(0xFF15141F),
            onSurface = Color.White,
            surfaceVariant = Color(0xFF211F2C),
            onSurfaceVariant = Color.White.copy(alpha = 0.72f),
        )
    ) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = Color.Transparent,
            contentColor = Color.White,
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.verticalGradient(listOf(theme.backgroundTop, theme.backgroundBottom)))
            ) {
                when (screen) {
                    AppScreen.HOME -> HomeScreen(
                        profile = profile,
                        billing = billing,
                        onPlay = {
                            session.startNewRun()
                            screen = AppScreen.GAME
                        },
                        onShop = { screen = AppScreen.SHOP },
                        onSettings = { screen = AppScreen.SETTINGS },
                    )
                    AppScreen.GAME -> GameScreen(
                        activity = activity,
                        profile = profile,
                        billing = billing,
                        ads = ads,
                        session = session,
                        onHome = {
                            session.commitRunIfNeeded()
                            screen = AppScreen.HOME
                        },
                    )
                    AppScreen.SHOP -> ShopScreen(
                        activity = activity,
                        profile = profile,
                        billing = billing,
                        onBack = { screen = AppScreen.HOME },
                    )
                    AppScreen.SETTINGS -> SettingsScreen(
                        activity = activity,
                        profile = profile,
                        billing = billing,
                        ads = ads,
                        onBack = { screen = AppScreen.HOME },
                    )
                }
            }
        }
    }
}

@Composable
private fun HomeScreen(
    profile: PlayerProfile,
    billing: BillingManager,
    onPlay: () -> Unit,
    onShop: () -> Unit,
    onSettings: () -> Unit,
) {
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(54.dp))
        NavoMark(profile.selectedTheme)
        Spacer(Modifier.height(18.dp))
        Text(
            "NAVOTAP",
            color = Color.White,
            fontSize = 40.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = 3.sp,
        )
        Text(
            "ONE TAP. ONE CHANCE.",
            color = Color.White.copy(alpha = 0.62f),
            fontSize = 12.sp,
            letterSpacing = 1.5.sp,
        )
        if (BuildConfig.USES_TEST_ADS) {
            Spacer(Modifier.height(8.dp))
            Text("ANDROID QA · TEST ADS", color = MaterialTheme.colorScheme.primary, fontSize = 11.sp)
        }

        Spacer(Modifier.height(34.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            StatCard("BEST", profile.bestScore.toString(), Modifier.weight(1f))
            StatCard("COINS", profile.coins.toString(), Modifier.weight(1f))
        }

        Spacer(Modifier.height(26.dp))
        Text(
            "CLASSIC MODE",
            modifier = Modifier.fillMaxWidth(),
            color = Color.White.copy(alpha = 0.52f),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.4.sp,
        )
        Spacer(Modifier.height(8.dp))
        Button(
            onClick = onPlay,
            modifier = Modifier.fillMaxWidth().height(68.dp),
            shape = RoundedCornerShape(24.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary,
            ),
        ) {
            Text("PLAY CLASSIC", fontWeight = FontWeight.Black, fontSize = 18.sp, letterSpacing = 0.8.sp)
        }
        Spacer(Modifier.height(12.dp))
        OutlinedButton(
            onClick = onShop,
            modifier = Modifier.fillMaxWidth().height(56.dp),
            shape = RoundedCornerShape(22.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        ) {
            Text("SHOP", fontWeight = FontWeight.Bold)
        }
        TextButton(
            onClick = onSettings,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.primary),
        ) {
            Text("SETTINGS", fontWeight = FontWeight.Bold)
        }

        Spacer(Modifier.weight(1f))
        Text(
            if (billing.adsRemoved) "AD-FREE MODE ACTIVE" else "Hit the highlighted arc. One miss ends the run.",
            textAlign = TextAlign.Center,
            color = Color.White.copy(alpha = 0.44f),
            fontSize = 12.sp,
        )
    }
}

@Composable
private fun NavoMark(theme: GameTheme) {
    Canvas(modifier = Modifier.size(76.dp)) {
        val center = Offset(size.width / 2f, size.height / 2f)
        val radius = size.minDimension * 0.28f
        val diameter = radius * 2f
        val topLeft = Offset(center.x - radius, center.y - radius)
        val arcSize = Size(diameter, diameter)

        drawCircle(theme.primary.copy(alpha = 0.12f), radius = radius * 1.55f, center = center)
        drawCircle(
            Color.White.copy(alpha = 0.18f),
            radius = radius,
            center = center,
            style = Stroke(width = 3f),
        )
        drawArc(
            color = theme.primary,
            startAngle = -58f,
            sweepAngle = 112f,
            useCenter = false,
            topLeft = topLeft,
            size = arcSize,
            style = Stroke(width = 8f, cap = StrokeCap.Round),
        )
        val markerAngle = -4.0 / 180.0 * PI
        val marker = Offset(
            center.x + cos(markerAngle).toFloat() * radius,
            center.y + sin(markerAngle).toFloat() * radius,
        )
        drawCircle(Color.White, radius = 5.5f, center = marker)
        drawCircle(theme.primary, radius = 5.5f, center = marker, style = Stroke(width = 2f))
    }
}

@Composable
private fun StatCard(label: String, value: String, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.075f),
            contentColor = Color.White,
        ),
        shape = RoundedCornerShape(22.dp),
    ) {
        Column(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 18.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                label,
                color = Color.White.copy(alpha = 0.48f),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.2.sp,
            )
            Spacer(Modifier.height(4.dp))
            Text(value, color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.Black)
        }
    }
}

@Composable
private fun GameScreen(
    activity: MainActivity,
    profile: PlayerProfile,
    billing: BillingManager,
    ads: AdManager,
    session: ClassicGameSession,
    onHome: () -> Unit,
) {
    val view = LocalView.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val tone = remember { ToneGenerator(AudioManager.STREAM_MUSIC, 30) }

    DisposableEffect(Unit) {
        onDispose { tone.release() }
    }

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_STOP) session.pause()
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    LaunchedEffect(session) {
        var lastFrame = 0L
        while (true) {
            withFrameNanos { now ->
                if (lastFrame != 0L) {
                    session.tick((now - lastFrame).toDouble() / 1_000_000_000.0)
                }
                lastFrame = now
            }
        }
    }

    LaunchedEffect(session.statusText) {
        when (val status = session.statusText) {
            "PERFECT" -> {
                delay(420)
                session.clearStatus(status)
            }
            "CONTINUE" -> {
                delay(700)
                session.clearStatus(status)
            }
        }
    }

    Column(Modifier.fillMaxSize().padding(horizontal = 18.dp, vertical = 20.dp)) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onClick = {
                if (session.isGameOver) onHome() else session.togglePause()
            }) {
                Text(if (session.isGameOver) "HOME" else if (session.isPaused) "RESUME" else "PAUSE")
            }
            Spacer(Modifier.weight(1f))
            Column(horizontalAlignment = Alignment.End) {
                Text("${session.score}", color = Color.White, fontSize = 30.sp, fontWeight = FontWeight.Black)
                Text("COMBO ${session.combo}", color = Color.White.copy(alpha = 0.5f), fontSize = 11.sp)
            }
        }

        Box(modifier = Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            TapArena(
                session = session,
                theme = profile.selectedTheme,
                onTapResult = { quality ->
                    if (profile.hapticsEnabled) {
                        val constant = when (quality) {
                            HitQuality.PERFECT -> HapticFeedbackConstants.LONG_PRESS
                            HitQuality.GOOD -> HapticFeedbackConstants.VIRTUAL_KEY
                            HitQuality.MISS -> HapticFeedbackConstants.KEYBOARD_TAP
                        }
                        view.performHapticFeedback(constant)
                    }
                    if (profile.soundEnabled) {
                        val toneType = when (quality) {
                            HitQuality.PERFECT -> ToneGenerator.TONE_PROP_ACK
                            HitQuality.GOOD -> ToneGenerator.TONE_PROP_BEEP
                            HitQuality.MISS -> ToneGenerator.TONE_PROP_NACK
                        }
                        tone.startTone(toneType, 90)
                    }
                }
            )

            session.statusText?.let {
                Text(
                    it,
                    fontWeight = FontWeight.Black,
                    fontSize = 22.sp,
                    color = if (it == "PERFECT") Color.White else MaterialTheme.colorScheme.primary,
                )
            }

            if (session.isPaused && !session.isGameOver) {
                OverlayCard {
                    Text("PAUSED", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Black)
                    Button(onClick = session::resume, modifier = Modifier.fillMaxWidth()) { Text("RESUME") }
                    OutlinedButton(onClick = onHome, modifier = Modifier.fillMaxWidth()) { Text("HOME") }
                }
            }

            if (session.isGameOver) {
                GameOverCard(
                    profile = profile,
                    billing = billing,
                    ads = ads,
                    session = session,
                    activity = activity,
                    onHome = onHome,
                )
            }
        }

        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("+${session.coinsEarned} COINS", color = Color.White.copy(alpha = 0.5f), fontSize = 12.sp)
            Text(
                "TARGET ${session.difficulty.targetArcDegrees.toInt()}°",
                color = Color.White.copy(alpha = 0.35f),
                fontSize = 11.sp,
            )
        }
    }
}

@Composable
private fun TapArena(
    session: ClassicGameSession,
    theme: GameTheme,
    onTapResult: (HitQuality) -> Unit,
) {
    Canvas(
        modifier = Modifier
            .fillMaxWidth()
            .height(470.dp)
            .pointerInput(session.isGameOver, session.isPaused) {
                detectTapGestures {
                    session.tap()?.let { onTapResult(it.quality) }
                }
            }
    ) {
        val center = Offset(size.width / 2f, size.height / 2f)
        val radius = min(size.width * 0.34f, size.height * 0.31f)
        val diameter = radius * 2f
        val topLeft = Offset(center.x - radius, center.y - radius)
        val arcSize = Size(diameter, diameter)

        repeat(26) { index ->
            val theta = index.toDouble() / 26.0 * PI * 2.0 + (index % 3) * 0.07
            val dotRadius = radius * (1.35f + (index % 5) * 0.08f)
            drawCircle(
                color = Color.White.copy(alpha = 0.05f + (index % 4) * 0.02f),
                radius = 1.2f + (index % 3) * 0.45f,
                center = Offset(
                    center.x + cos(theta).toFloat() * dotRadius,
                    center.y + sin(theta).toFloat() * dotRadius,
                ),
            )
        }

        drawCircle(
            color = Color.White.copy(alpha = 0.12f),
            radius = radius,
            center = center,
            style = Stroke(width = 2.5f),
        )

        val difficulty = session.difficulty
        drawArc(
            color = theme.primary,
            startAngle = (session.targetAngle - difficulty.targetArcDegrees / 2.0).toFloat(),
            sweepAngle = difficulty.targetArcDegrees.toFloat(),
            useCenter = false,
            topLeft = topLeft,
            size = arcSize,
            style = Stroke(width = 14f, cap = StrokeCap.Round),
        )
        drawArc(
            color = Color.White.copy(alpha = 0.95f),
            startAngle = (session.targetAngle - difficulty.perfectArcDegrees / 2.0).toFloat(),
            sweepAngle = difficulty.perfectArcDegrees.toFloat(),
            useCenter = false,
            topLeft = topLeft,
            size = arcSize,
            style = Stroke(width = 4f, cap = StrokeCap.Round),
        )

        drawCircle(Color.White.copy(alpha = 0.025f), radius = radius * 0.40f, center = center)
        drawCircle(
            Color.White.copy(alpha = 0.055f),
            radius = radius * 0.40f,
            center = center,
            style = Stroke(width = 1f),
        )

        val radians = session.currentAngle / 180.0 * PI
        val marker = Offset(
            center.x + cos(radians).toFloat() * radius,
            center.y + sin(radians).toFloat() * radius,
        )
        drawCircle(theme.primary.copy(alpha = 0.20f), radius = 19f, center = marker)
        drawCircle(Color.White, radius = 11f, center = marker)
        drawCircle(theme.primary, radius = 11f, center = marker, style = Stroke(width = 3f))
    }
}

@Composable
private fun GameOverCard(
    profile: PlayerProfile,
    billing: BillingManager,
    ads: AdManager,
    session: ClassicGameSession,
    activity: MainActivity,
    onHome: () -> Unit,
) {
    OverlayCard {
        Text("RUN OVER", color = Color.White, fontSize = 25.sp, fontWeight = FontWeight.Black)
        Text("${session.score}", fontSize = 46.sp, fontWeight = FontWeight.Black, color = MaterialTheme.colorScheme.primary)
        if (session.isNewBest) Text("NEW BEST", color = Color.White, fontWeight = FontWeight.Bold)
        Text("+${session.coinsEarned} coins", color = Color.White.copy(alpha = 0.55f))

        if (session.canUseContinue) {
            when (ads.rewardedAvailability) {
                RewardedAvailability.READY -> Button(
                    onClick = {
                        ads.showRewarded(
                            activity = activity,
                            onRewardEarned = { session.continueAfterReward() },
                            onUnavailable = {},
                        )
                    },
                    modifier = Modifier.fillMaxWidth(),
                ) { Text("CONTINUE · WATCH AD") }
                RewardedAvailability.LOADING -> OutlinedButton(
                    onClick = {}, enabled = false, modifier = Modifier.fillMaxWidth()
                ) { Text("AD LOADING") }
                RewardedAvailability.UNAVAILABLE -> OutlinedButton(
                    onClick = { ads.retryRewarded(activity) }, modifier = Modifier.fillMaxWidth()
                ) { Text("AD UNAVAILABLE · RETRY") }
            }
        }

        Button(
            onClick = {
                session.commitRunIfNeeded()
                val restart = profile.recordRestart()
                val restartAction = { session.startNewRun() }
                if (!billing.adsRemoved && InterstitialCadence.shouldShow(restart)) {
                    ads.showInterstitialIfReady(activity, restartAction)
                } else {
                    restartAction()
                }
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black),
        ) { Text("RETRY", fontWeight = FontWeight.Black) }

        TextButton(onClick = onHome, modifier = Modifier.fillMaxWidth()) { Text("HOME") }
    }
}

@Composable
private fun OverlayCard(content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(0.84f),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xF0151420),
            contentColor = Color.White,
        ),
        shape = RoundedCornerShape(26.dp),
    ) {
        Column(
            Modifier.fillMaxWidth().padding(22.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            content()
        }
    }
}

@Composable
private fun ShopScreen(
    activity: MainActivity,
    profile: PlayerProfile,
    billing: BillingManager,
    onBack: () -> Unit,
) {
    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 20.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Spacer(Modifier.height(22.dp))
        ScreenHeader(title = "SHOP", onBack = onBack)
        Text(
            "Make the run yours. Themes are cosmetic and never change gameplay.",
            color = Color.White.copy(alpha = 0.50f),
            fontSize = 12.sp,
        )

        Spacer(Modifier.height(4.dp))
        GameTheme.entries.forEach { theme ->
            val unlocked = billing.isThemeUnlocked(theme)
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = Color.White.copy(alpha = 0.075f),
                    contentColor = Color.White,
                ),
                shape = RoundedCornerShape(22.dp),
            ) {
                Row(
                    Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    Box(
                        Modifier.size(50.dp).background(
                            Brush.linearGradient(listOf(theme.primary, theme.secondary)),
                            RoundedCornerShape(16.dp),
                        )
                    )
                    Column(Modifier.weight(1f)) {
                        Text(theme.title, color = Color.White, fontWeight = FontWeight.Black, fontSize = 16.sp)
                        Spacer(Modifier.height(2.dp))
                        Text(theme.subtitle, color = Color.White.copy(alpha = 0.52f), fontSize = 12.sp)
                    }
                    when {
                        profile.selectedTheme == theme -> Text(
                            "ACTIVE",
                            color = theme.primary,
                            fontWeight = FontWeight.Black,
                            fontSize = 12.sp,
                        )
                        unlocked -> OutlinedButton(
                            onClick = { profile.selectTheme(theme) },
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                        ) { Text("SELECT") }
                        else -> {
                            val id = requireNotNull(theme.productId)
                            Button(
                                onClick = { billing.launchPurchase(activity, id) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = MaterialTheme.colorScheme.primary,
                                    contentColor = MaterialTheme.colorScheme.onPrimary,
                                ),
                            ) {
                                Text(billing.formattedPrice(id) ?: "BUY", fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }

        ProductCard(
            title = "ALL THEMES",
            subtitle = "Unlock Fire, Galaxy and Retro",
            owned = MonetizationProducts.ALL_THEMES in billing.purchasedProductIds,
            price = billing.formattedPrice(MonetizationProducts.ALL_THEMES),
            onBuy = { billing.launchPurchase(activity, MonetizationProducts.ALL_THEMES) },
        )
        ProductCard(
            title = "REMOVE ADS",
            subtitle = "Stops automatic interstitials. Rewarded Continue stays optional.",
            owned = billing.adsRemoved,
            price = billing.formattedPrice(MonetizationProducts.REMOVE_ADS),
            onBuy = { billing.launchPurchase(activity, MonetizationProducts.REMOVE_ADS) },
        )

        OutlinedButton(
            onClick = billing::restorePurchases,
            modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(20.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        ) {
            Text("RESTORE PURCHASES", fontWeight = FontWeight.Bold)
        }
        billing.statusMessage?.let {
            Text(it, color = MaterialTheme.colorScheme.error, fontSize = 12.sp)
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun ProductCard(
    title: String,
    subtitle: String,
    owned: Boolean,
    price: String?,
    onBuy: () -> Unit,
) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.075f),
            contentColor = Color.White,
        ),
        shape = RoundedCornerShape(22.dp),
    ) {
        Column(
            Modifier.fillMaxWidth().padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(9.dp),
        ) {
            Text(title, color = Color.White, fontWeight = FontWeight.Black, fontSize = 16.sp)
            Text(subtitle, color = Color.White.copy(alpha = 0.52f), fontSize = 12.sp)
            if (owned) {
                Text("OWNED", color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Black)
            } else {
                Button(
                    onClick = onBuy,
                    modifier = Modifier.fillMaxWidth().height(50.dp),
                    shape = RoundedCornerShape(18.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        contentColor = MaterialTheme.colorScheme.onPrimary,
                    ),
                ) {
                    Text(price ?: "BUY", fontWeight = FontWeight.Black)
                }
            }
        }
    }
}

@Composable
private fun SettingsScreen(
    activity: MainActivity,
    profile: PlayerProfile,
    billing: BillingManager,
    ads: AdManager,
    onBack: () -> Unit,
) {
    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 20.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Spacer(Modifier.height(22.dp))
        ScreenHeader(title = "SETTINGS", onBack = onBack)
        Text(
            "Tune feedback and manage your purchases.",
            color = Color.White.copy(alpha = 0.50f),
            fontSize = 12.sp,
        )

        Spacer(Modifier.height(4.dp))
        SettingToggle("Sound", "Audio feedback on every hit", profile.soundEnabled, profile::setSound)
        SettingToggle("Haptics", "Tactile feedback for timing", profile.hapticsEnabled, profile::setHaptics)

        OutlinedButton(
            onClick = billing::restorePurchases,
            modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(20.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        ) {
            Text("RESTORE PURCHASES", fontWeight = FontWeight.Bold)
        }
        if (ads.privacyOptionsRequired) {
            OutlinedButton(
                onClick = { ads.showPrivacyOptions(activity) },
                modifier = Modifier.fillMaxWidth().height(54.dp),
                shape = RoundedCornerShape(20.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
            ) {
                Text("PRIVACY OPTIONS", fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(10.dp))
        Text(
            "NAVOTAP ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
            color = Color.White.copy(alpha = 0.46f),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 0.7.sp,
        )
        Text(
            "Themes are cosmetic only. Remove Ads disables automatic interstitials; optional rewarded Continue remains available.",
            color = Color.White.copy(alpha = 0.42f),
            fontSize = 12.sp,
        )
        if (BuildConfig.DEBUG) {
            ads.consentErrorMessage?.let {
                Text("Debug consent status: $it", color = Color.White.copy(alpha = 0.32f), fontSize = 10.sp)
            }
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun ScreenHeader(title: String, onBack: () -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        TextButton(
            onClick = onBack,
            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.primary),
        ) {
            Text("BACK", fontWeight = FontWeight.Bold)
        }
        Spacer(Modifier.weight(1f))
        Text(
            title,
            color = Color.White,
            fontSize = 27.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = 1.2.sp,
        )
    }
}

@Composable
private fun SettingToggle(
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.075f),
            contentColor = Color.White,
        ),
        shape = RoundedCornerShape(22.dp),
    ) {
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 18.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(Modifier.weight(1f)) {
                Text(title, color = Color.White, fontWeight = FontWeight.Black, fontSize = 16.sp)
                Spacer(Modifier.height(2.dp))
                Text(subtitle, color = Color.White.copy(alpha = 0.48f), fontSize = 11.sp)
            }
            Switch(checked = checked, onCheckedChange = onCheckedChange)
        }
    }
}
