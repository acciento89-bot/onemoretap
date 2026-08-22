package com.kamilunavo.onemoretap

import android.app.Activity
import android.content.Context
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

    private val billingClient = BillingClient.newBuilder(context.applicationContext)
        .setListener(this)
        .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
        .enableAutoServiceReconnection()
        .build()

    init { connect() }

    fun isThemeUnlocked(theme: GameTheme): Boolean {
        val id = theme.productId ?: return true
        return id in purchasedProductIds || MonetizationProducts.ALL_THEMES in purchasedProductIds
    }

    fun formattedPrice(productId: String): String? = productDetails[productId]
        ?.oneTimePurchaseOfferDetailsList
        ?.firstOrNull()
        ?.formattedPrice

    fun launchPurchase(activity: Activity, productId: String) {
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
        val result = billingClient.launchBillingFlow(
            activity,
            BillingFlowParams.newBuilder().setProductDetailsParamsList(listOf(productParams)).build()
        )
        if (result.responseCode != BillingClient.BillingResponseCode.OK) {
            statusMessage = result.debugMessage.ifBlank { "Purchase could not be started." }
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

    private fun connect() {
        if (billingClient.isReady) {
            billingReady = true
            queryProducts()
            refreshPurchases()
            return
        }
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                billingReady = result.responseCode == BillingClient.BillingResponseCode.OK
                if (billingReady) {
                    queryProducts()
                    refreshPurchases()
                } else {
                    statusMessage = "Google Play Billing unavailable (${result.responseCode})."
                }
            }

            override fun onBillingServiceDisconnected() {
                billingReady = false
            }
        })
    }

    private fun queryProducts() {
        if (!billingClient.isReady) return
        val products = MonetizationProducts.ALL.map { id ->
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(id)
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(products).build()
        billingClient.queryProductDetailsAsync(params) { result, detailsResult ->
            if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                statusMessage = result.debugMessage.ifBlank { "Store products are currently unavailable." }
                return@queryProductDetailsAsync
            }
            productDetails = detailsResult.productDetailsList.associateBy { it.productId }
        }
    }

    private fun refreshPurchases() {
        if (!billingClient.isReady) {
            connect()
            return
        }
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()
        billingClient.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                processPurchases(purchases)
            } else {
                statusMessage = result.debugMessage.ifBlank { "Purchases could not be restored." }
            }
        }
    }

    private fun processPurchases(purchases: List<Purchase>) {
        val owned = purchases.filter {
            it.purchaseState == Purchase.PurchaseState.PURCHASED &&
                it.products.any(MonetizationProducts.ALL::contains)
        }
        purchasedProductIds = owned.flatMap { it.products }.filter(MonetizationProducts.ALL::contains).toSet()

        owned.filterNot { it.isAcknowledged }.forEach { purchase ->
            val params = AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
            billingClient.acknowledgePurchase(params) { result ->
                if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                    statusMessage = result.debugMessage.ifBlank { "Purchase acknowledgement failed." }
                }
            }
        }
    }
}
