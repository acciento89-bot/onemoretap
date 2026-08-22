package com.kamilunavo.onemoretap

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams

class BillingManager(context: Context) : PurchasesUpdatedListener {
    private val appContext = context.applicationContext
    private val handler = Handler(Looper.getMainLooper())

    var purchasedProductIds by mutableStateOf<Set<String>>(emptySet())
        private set
    var productDetails by mutableStateOf<Map<String, ProductDetails>>(emptyMap())
        private set
    var billingReady by mutableStateOf(false)
        private set
    var statusMessage by mutableStateOf<String?>(null)
        private set

    val adsRemoved: Boolean
        get() = MonetizationProducts.REMOVE_ADS in purchasedProductIds

    private var billingClient: BillingClient? = null
    private var connectionScheduled = false
    private var connectionStarted = false

    init {
        // Keep the first Activity/Compose frame completely free from Play Billing startup.
        // If Play Services is unhealthy on a device, the game UI still opens first.
        scheduleConnect()
    }

    fun isThemeUnlocked(theme: GameTheme): Boolean {
        val id = theme.productId ?: return true
        return id in purchasedProductIds || MonetizationProducts.ALL_THEMES in purchasedProductIds
    }

    fun formattedPrice(productId: String): String? = productDetails[productId]
        ?.oneTimePurchaseOfferDetailsList
        ?.firstOrNull()
        ?.formattedPrice

    fun launchPurchase(activity: Activity, productId: String) {
        val client = billingClient
        if (client == null || !client.isReady) {
            statusMessage = "Google Play Store is still connecting."
            scheduleConnect(immediate = true)
            return
        }

        val details = productDetails[productId]
        if (details == null) {
            statusMessage = "Store product is not available yet."
            queryProducts()
            return
        }
        val offerToken = details.oneTimePurchaseOfferDetailsList?.firstOrNull()?.offerToken
        if (offerToken.isNullOrBlank()) {
            statusMessage = "No eligible Google Play offer is available."
            return
        }
        val productParams = BillingFlowParams.ProductDetailsParams.newBuilder()
            .setProductDetails(details)
            .setOfferToken(offerToken)
            .build()

        try {
            val result = client.launchBillingFlow(
                activity,
                BillingFlowParams.newBuilder().setProductDetailsParamsList(listOf(productParams)).build()
            )
            if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                statusMessage = result.debugMessage.ifBlank { "Purchase could not be started." }
            }
        } catch (error: Throwable) {
            statusMessage = error.message ?: "Google Play Billing is temporarily unavailable."
            billingReady = false
        }
    }

    fun restorePurchases() {
        statusMessage = null
        refreshPurchases()
    }

    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> processPurchases(purchases.orEmpty())
            BillingClient.BillingResponseCode.USER_CANCELED -> statusMessage = null
            else -> statusMessage = result.debugMessage.ifBlank { "Purchase failed." }
        }
    }

    private fun scheduleConnect(immediate: Boolean = false) {
        if (billingReady || connectionScheduled || connectionStarted) return
        connectionScheduled = true
        handler.postDelayed({
            connectionScheduled = false
            connect()
        }, if (immediate) 0L else 1_500L)
    }

    private fun createClient(): BillingClient? {
        billingClient?.let { return it }
        return try {
            BillingClient.newBuilder(appContext)
                .setListener(this)
                .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
                .enableAutoServiceReconnection()
                .build()
                .also { billingClient = it }
        } catch (error: Throwable) {
            billingReady = false
            statusMessage = error.message ?: "Google Play Billing is temporarily unavailable."
            null
        }
    }

    private fun connect() {
        val client = createClient() ?: return
        if (client.isReady) {
            billingReady = true
            connectionStarted = false
            queryProducts()
            refreshPurchases()
            return
        }
        if (connectionStarted) return
        connectionStarted = true

        try {
            client.startConnection(object : BillingClientStateListener {
                override fun onBillingSetupFinished(result: BillingResult) {
                    connectionStarted = false
                    billingReady = result.responseCode == BillingClient.BillingResponseCode.OK
                    if (billingReady) {
                        statusMessage = null
                        queryProducts()
                        refreshPurchases()
                    } else {
                        statusMessage = "Google Play Billing unavailable (${result.responseCode})."
                    }
                }

                override fun onBillingServiceDisconnected() {
                    connectionStarted = false
                    billingReady = false
                    scheduleConnect()
                }
            })
        } catch (error: Throwable) {
            connectionStarted = false
            billingReady = false
            statusMessage = error.message ?: "Google Play Billing is temporarily unavailable."
        }
    }

    private fun queryProducts() {
        val client = billingClient ?: return
        if (!client.isReady) return
        val products = MonetizationProducts.ALL.map { id ->
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(id)
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(products).build()

        try {
            client.queryProductDetailsAsync(params) { result, detailsResult ->
                if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                    statusMessage = result.debugMessage.ifBlank { "Store products are currently unavailable." }
                    return@queryProductDetailsAsync
                }
                productDetails = detailsResult.productDetailsList.associateBy { it.productId }
            }
        } catch (error: Throwable) {
            statusMessage = error.message ?: "Store products are currently unavailable."
        }
    }

    private fun refreshPurchases() {
        val client = billingClient
        if (client == null || !client.isReady) {
            scheduleConnect(immediate = true)
            return
        }
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()

        try {
            client.queryPurchasesAsync(params) { result, purchases ->
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    processPurchases(purchases)
                } else {
                    statusMessage = result.debugMessage.ifBlank { "Purchases could not be restored." }
                }
            }
        } catch (error: Throwable) {
            statusMessage = error.message ?: "Purchases could not be restored."
        }
    }

    private fun processPurchases(purchases: List<Purchase>) {
        val client = billingClient
        val owned = purchases.filter {
            it.purchaseState == Purchase.PurchaseState.PURCHASED &&
                it.products.any(MonetizationProducts.ALL::contains)
        }
        purchasedProductIds = owned.flatMap { it.products }.filter(MonetizationProducts.ALL::contains).toSet()

        if (client == null) return
        owned.filterNot { it.isAcknowledged }.forEach { purchase ->
            val params = AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
            try {
                client.acknowledgePurchase(params) { result ->
                    if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                        statusMessage = result.debugMessage.ifBlank { "Purchase acknowledgement failed." }
                    }
                }
            } catch (error: Throwable) {
                statusMessage = error.message ?: "Purchase acknowledgement failed."
            }
        }
    }
}
