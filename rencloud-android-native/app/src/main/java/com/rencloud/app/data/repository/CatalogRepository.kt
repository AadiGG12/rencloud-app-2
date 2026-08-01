package com.rencloud.app.data.repository

import android.util.Log
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.remote.PterodactylApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CatalogRepository @Inject constructor(
    private val api: PterodactylApi
) {
    private var cachedPlans: List<RenCloudPlan> = emptyList()

    suspend fun fetchPlans(refresh: Boolean = false): List<RenCloudPlan> = withContext(Dispatchers.IO) {
        if (!refresh && cachedPlans.isNotEmpty()) {
            return@withContext cachedPlans
        }

        try {
            val resp = api.getPublicPlans()
            if (resp.isSuccessful && resp.body()?.dataList != null) {
                val livePlans = resp.body()!!.dataList!!
                if (livePlans.isNotEmpty()) {
                    cachedPlans = livePlans
                    Log.d("CatalogRepository", "Fetched ${livePlans.size} live plans from gateway /api/plans")
                    return@withContext livePlans
                }
            }
        } catch (e: Exception) {
            Log.e("CatalogRepository", "Failed to fetch live plans from gateway: ${e.message}", e)
        }

        if (cachedPlans.isNotEmpty()) cachedPlans else getFallbackPlans()
    }

    fun getPlans(): List<RenCloudPlan> {
        return if (cachedPlans.isNotEmpty()) cachedPlans else getFallbackPlans()
    }

    private fun getFallbackPlans(): List<RenCloudPlan> {
        return listOf(
            RenCloudPlan("mc_b_dirt", "Dirt", "Minecraft Budget", 20, 0.25, "2 GB DDR4", "1 Core (100%)", "10 GB NVMe", "Unmetered", "Unlimited", false, "Budget Minecraft Hosting", "India"),
            RenCloudPlan("mc_b_stone", "Stone", "Minecraft Budget", 40, 0.50, "4 GB DDR4", "2 Cores (200%)", "20 GB NVMe", "Unmetered", "Unlimited", false, "Budget Minecraft Hosting", "India"),
            RenCloudPlan("mc_b_iron", "Iron", "Minecraft Budget", 80, 1.00, "8 GB DDR4", "3 Cores (300%)", "30 GB NVMe", "Unmetered", "Unlimited", true, "Popular Budget Choice", "India"),
            RenCloudPlan("mc_b_redstone", "Redstone", "Minecraft Budget", 160, 2.00, "16 GB DDR4", "4 Cores (400%)", "40 GB NVMe", "Unmetered", "Unlimited", false, "High Performance Budget", "India"),
            RenCloudPlan("mc_p_iron", "Premium Iron", "Minecraft Premium", 160, 2.00, "8 GB DDR5", "3 Cores (300%)", "30 GB NVMe", "Unmetered", "Unlimited", true, "Popular Premium Server", "India / Singapore"),
            RenCloudPlan("vps_ryzen_16", "Ryzen 16", "VPS AMD Ryzen", 1849, 23.00, "16 GB DDR4", "4 vCores 5.7GHz", "150 GB NVMe", "Unmetered", "1 IPv4", true, "Top Recommended Gaming VPS", "India / Singapore")
        )
    }
}
