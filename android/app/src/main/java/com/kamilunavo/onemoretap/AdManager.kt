package com.kamilunavo.onemoretap

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform

enum class RewardedAvailability { LOADING, READY, UNAVAILABLE }

class AdManager(context: Context) {
    private val appContext = context.applicationContext
    private val consentInformation = UserMessagingPlatform.getConsentInformation(appContext)
    private val handler = Handler(Looper.getMainLooper())

    var rewardedAvailability by mutableStateOf(RewardedAvailability.LOADING)
        private set
    var interstitialReady by mutableStateOf(false)
        private set
    var privacyOptionsRequired by mutableStateOf(false)
        private set
    var consentErrorMessage by mutableStateOf<String?>(null)
        private set

    private var rewardedAd: RewardedAd? = null
    private var interstitialAd: InterstitialAd? = null
    private var mobileAdsStarted = false
    private var rewardedRetryScheduled = false

    fun requestConsentAndStart(activity: Activity) {
        val params = ConsentRequestParameters.Builder().build()
        consentInformation.requestConsentInfoUpdate(
            activity,
            params,
            {
                updatePrivacyOptionsRequirement()
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
                    consentErrorMessage = formError?.message
                    updatePrivacyOptionsRequirement()
                    startAdsIfAllowed()
                }
                // Consent may have been granted in a previous session. Avoid waiting for a form callback.
                startAdsIfAllowed()
            },
            { requestError ->
                consentErrorMessage = requestError.message
                updatePrivacyOptionsRequirement()
                // UMP can still allow ads based on the previous valid session state.
                startAdsIfAllowed()
            },
        )
    }

    fun showPrivacyOptions(activity: Activity) {
        if (!privacyOptionsRequired) return
        UserMessagingPlatform.showPrivacyOptionsForm(activity) { formError ->
            consentErrorMessage = formError?.message
            updatePrivacyOptionsRequirement()
            startAdsIfAllowed()
        }
    }

    fun retryRewarded() {
        rewardedRetryScheduled = false
        loadRewarded()
    }

    fun showRewarded(
        activity: Activity,
        onRewardEarned: () -> Unit,
        onUnavailable: () -> Unit,
    ) {
        val ad = rewardedAd
        if (ad == null) {
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            scheduleRewardedRetry()
            onUnavailable()
            return
        }

        rewardedAd = null
        rewardedAvailability = RewardedAvailability.LOADING
        var earned = false
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                loadRewarded()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedAvailability = RewardedAvailability.UNAVAILABLE
                scheduleRewardedRetry()
                if (!earned) onUnavailable()
            }
        }
        ad.setImmersiveMode(true)
        ad.show(activity) {
            if (!earned) {
                earned = true
                onRewardEarned()
            }
        }
    }

    fun showInterstitialIfReady(activity: Activity, onComplete: () -> Unit) {
        val ad = interstitialAd
        if (ad == null) {
            onComplete()
            loadInterstitial()
            return
        }

        interstitialAd = null
        interstitialReady = false
        var completed = false
        fun finishOnce() {
            if (!completed) {
                completed = true
                onComplete()
            }
        }

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                loadInterstitial()
                finishOnce()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                loadInterstitial()
                finishOnce()
            }
        }
        ad.setImmersiveMode(true)
        ad.show(activity)
    }

    private fun updatePrivacyOptionsRequirement() {
        privacyOptionsRequired =
            consentInformation.privacyOptionsRequirementStatus ==
                ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
    }

    private fun startAdsIfAllowed() {
        if (!consentInformation.canRequestAds()) return
        if (mobileAdsStarted) {
            if (rewardedAd == null) loadRewarded()
            if (interstitialAd == null) loadInterstitial()
            return
        }

        mobileAdsStarted = true
        MobileAds.initialize(appContext) {
            loadRewarded()
            loadInterstitial()
        }
    }

    private fun loadRewarded() {
        if (!consentInformation.canRequestAds()) {
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            return
        }
        rewardedAvailability = RewardedAvailability.LOADING
        RewardedAd.load(
            appContext,
            BuildConfig.REWARDED_AD_ID,
            AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    rewardedAvailability = RewardedAvailability.READY
                    rewardedRetryScheduled = false
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    rewardedAd = null
                    rewardedAvailability = RewardedAvailability.UNAVAILABLE
                    scheduleRewardedRetry()
                }
            },
        )
    }

    private fun loadInterstitial() {
        if (!consentInformation.canRequestAds()) {
            interstitialReady = false
            return
        }
        InterstitialAd.load(
            appContext,
            BuildConfig.INTERSTITIAL_AD_ID,
            AdRequest.Builder().build(),
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialAd = ad
                    interstitialReady = true
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    interstitialAd = null
                    interstitialReady = false
                }
            },
        )
    }

    private fun scheduleRewardedRetry() {
        if (rewardedRetryScheduled) return
        rewardedRetryScheduled = true
        handler.postDelayed({
            rewardedRetryScheduled = false
            loadRewarded()
        }, 15_000L)
    }
}
