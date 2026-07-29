package com.rencloud.app.data

enum class BillingCycle { MONTHLY, ANNUAL }

enum class AppCurrency(val symbol: String, val rate: Double) {
    INR("₹", 1.0),
    USD("$", 0.012),
    EUR("€", 0.011),
    AED("Dh ", 0.044);

    fun format(priceInr: Int): String {
        return when (this) {
            INR -> "$symbol$priceInr"
            USD -> "$symbol${String.format("%.2f", priceInr * rate)}"
            EUR -> "$symbol${String.format("%.2f", priceInr * rate)}"
            AED -> "$symbol${String.format("%.1f", priceInr * rate)}"
        }
    }
}

data class RenCloudPlan(
    val id: String,
    val name: String,
    val categoryId: String,
    val categoryName: String,
    val ram: String,
    val nvmeStorage: String,
    val cpu: String,
    val monthlyPriceInr: Int,
    val isPopular: Boolean = false,
    val tierType: String? = null,
    val databases: Int? = null,
    val backups: Int? = null,
    val isOneTime: Boolean = false,
    val extraInfo: String? = null
) {
    fun getPriceForCycle(cycle: BillingCycle): Int {
        if (isOneTime) return monthlyPriceInr
        return if (cycle == BillingCycle.ANNUAL) {
            (monthlyPriceInr * 0.85).toInt()
        } else {
            monthlyPriceInr
        }
    }
}
