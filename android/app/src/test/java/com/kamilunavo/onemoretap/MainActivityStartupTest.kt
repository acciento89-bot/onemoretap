package com.kamilunavo.onemoretap

import android.os.Looper
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.util.concurrent.TimeUnit

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35])
class MainActivityStartupTest {
    @Test
    fun mainActivitySurvivesDelayedBillingAndAdsStartup() {
        val controller = Robolectric.buildActivity(MainActivity::class.java).setup()
        val activity = controller.get()

        // Prove the first visible Activity frame can be created before Google SDK startup.
        assertFalse(activity.isFinishing)
        assertFalse(activity.isDestroyed)
        assertNotNull(activity.window.decorView)

        // Billing and UMP/AdMob are deliberately delayed by 1.5 seconds. Advancing the
        // main looper beyond that boundary executes those startup paths inside Robolectric.
        shadowOf(Looper.getMainLooper()).idleFor(2, TimeUnit.SECONDS)

        // Any uncaught startup exception fails the test before these assertions are reached.
        assertFalse(activity.isFinishing)
        assertFalse(activity.isDestroyed)
        assertNotNull(activity.window.decorView)

        controller.pause().stop().destroy()
    }
}
