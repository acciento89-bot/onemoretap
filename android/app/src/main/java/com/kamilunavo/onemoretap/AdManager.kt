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
    private val handler = Handler(Looper.getMainLooper())

    var rewardedAvailability by mutableStateOf(RewardedAvailability.UNAVAILABLE)
        private set
    var interstitialReady by mutableStateOf(false)
        private set
    var privacyOptionsRequired by mutableStateOf(false)
        private set
    var consentErrorMessage by mutableStateOf<String?>(null)
        private set

    private var consentInformation: ConsentInformation? = null
    private var rewardedAd: RewardedAd? = null
    private var interstitialAd: InterstitialAd? = null
    private var mobileAdsStarted = false
    private var rewardedRetryScheduled = false
    private var consentInitScheduled = false
    private var consentInitStarted = false

    fun requestConsentAndStart(activity: Activity) {
        if (consentInitScheduled || consentInitStarted || mobileAdsStarted) return
        consentInitScheduled = true

        // Keep UMP and Google Mobile Ads completely out of the first UI frame.
        // The game must render even if Google Play services or the ads SDK is unhealthy.
        handler.postDelayed({
            consentInitScheduled = false
            initializeConsentAndAds(activity)
        }, 1_500L)
    }

    private fun initializeConsentAndAds(activity: Activity) {
        if (consentInitStarted || mobileAdsStarted) return
        consentInitStarted = true
        rewardedAvailability = RewardedAvailability.LOADING

        val consent = try {
            UserMessagingPlatform.getConsentInformation(appContext)
        } catch (error: Throwable) {
            consentErrorMessage = error.message ?: "Ads are temporarily unavailable."
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            consentInitStarted = false
            return
        }
        consentInformation = consent

        val params = ConsentRequestParameters.Builder().build()
        try {
            consent.requestConsentInfoUpdate(
                activity,
                params,
                {
                    updatePrivacyOptionsRequirement()
                    try {
                        UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
                            consentErrorMessage = formError?.message
                            updatePrivacyOptionsRequirement()
                            startAdsIfAllowed()
                        }
                    } catch (error: Throwable) {
                        consentErrorMessage = error.message ?: "Privacy options are temporarily unavailable."
                    }
                    // Consent may already exist from a previous session.
                    startAdsIfAllowed()
                },
                { requestError ->
                    consentErrorMessage = requestError.message
                    updatePrivacyOptionsRequirement()
                    // UMP can still allow ads based on previous valid consent state.
                    startAdsIfAllowed()
                },
            )
        } catch (error: Throwable) {
            consentErrorMessage = error.message ?: "Ads are temporarily unavailable."
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            interstitialReady = false
            consentInitStarted = false
        }
    }

    fun showPrivacyOptions(activity: Activity) {
        if (!privacyOptionsRequired || consentInformation == null) return
        try {
            UserMessagingPlatform.showPrivacyOptionsForm(activity) { formError ->
                consentErrorMessage = formError?.message
                updatePrivacyOptionsRequirement()
                startAdsIfAllowed()
            }
        } catch (error: Throwable) {
            consentErrorMessage = error.message ?: "Privacy options are temporarily unavailable."
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
        try {
            ad.setImmersiveMode(true)
            ad.show(activity) {
                if (!earned) {
                    earned = true
                    onRewardEarned()
                }
            }
        } catch (_: Throwable) {
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            scheduleRewardedRetry()
            if (!earned) onUnavailable()
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
        try {
            ad.setImmersiveMode(true)
            ad.show(activity)
        } catch (_: Throwable) {
            loadInterstitial()
            finishOnce()
        }
    }

    private fun updatePrivacyOptionsRequirement() {
        val consent = consentInformation ?: run {
            privacyOptionsRequired = false
            return
        }
        privacyOptionsRequired =
            consent.privacyOptionsRequirementStatus ==
                ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
    }

    private fun startAdsIfAllowed() {
        val consent = consentInformation ?: return
        if (!consent.canRequestAds()) {
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            consentInitStarted = false
            return
        }
        if (mobileAdsStarted) {
            if (rewardedAd == null) loadRewarded()
            if (interstitialAd == null) loadInterstitial()
            return
        }

        try {
            mobileAdsStarted = true
            MobileAds.initialize(appContext) {
                loadRewarded()
                loadInterstitial()
            }
        } catch (error: Throwable) {
            mobileAdsStarted = false
            consentInitStarted = false
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            interstitialReady = false
            consentErrorMessage = error.message ?: "Ads are temporarily unavailable."
        }
    }

    private fun loadRewarded() {
        val consent = consentInformation
        if (consent == null || !consent.canRequestAds() || !mobileAdsStarted) {
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            return
        }
        rewardedAvailability = RewardedAvailability.LOADING
        try {
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
        } catch (_: Throwable) {
            rewardedAd = null
            rewardedAvailability = RewardedAvailability.UNAVAILABLE
            scheduleRewardedRetry()
        }
    }

    private fun loadInterstitial() {
        val consent = consentInformation
        if (consent == null || !consent.canRequestAds() || !mobileAdsStarted) {
            interstitialReady = false
            return
        }
        try {
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
        } catch (_: Throwable) {
            interstitialAd = null
            interstitialReady = false
        }
    }

    private fun scheduleRewardedRetry() {
        if (rewardedRetryScheduled || consentInformation == null || !mobileAdsStarted) return
        rewardedRetryScheduled = true
        handler.postDelayed({
            rewardedRetryScheduled = false
            loadRewarded()
        }, 15_000L)
    }
}
