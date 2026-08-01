package com.rencloud.app.data.model

import com.google.gson.annotations.SerializedName

data class RenCloudPlan(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("category", alternate = ["categoryName"]) val categoryName: String,
    @SerializedName("monthlyPriceInr") val monthlyPriceInr: Int,
    @SerializedName("monthlyPriceUsd") val monthlyPriceUsd: Double,
    @SerializedName("ram") val ram: String,
    @SerializedName("cpu") val cpu: String,
    @SerializedName("storage", alternate = ["nvmeStorage"]) val nvmeStorage: String,
    @SerializedName("bandwidth") val bandwidth: String = "Unmetered",
    @SerializedName("databases", alternate = ["slots"]) val slots: String = "Unlimited",
    @SerializedName("isFeatured") val isFeatured: Boolean = false,
    @SerializedName("tagline") val tagline: String = "",
    @SerializedName("location") val location: String = "India",
    @SerializedName("display_order") val displayOrder: Int = 0,
    @SerializedName("is_active") val isActive: Boolean = true
)
