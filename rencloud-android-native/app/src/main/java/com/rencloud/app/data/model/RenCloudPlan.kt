package com.rencloud.app.data.model

data class RenCloudPlan(
    val id: String,
    val name: String,
    val categoryName: String,
    val monthlyPriceInr: Int,
    val monthlyPriceUsd: Double,
    val ram: String,
    val cpu: String,
    val nvmeStorage: String,
    val bandwidth: String,
    val slots: String,
    val isFeatured: Boolean = false,
    val tagline: String = "",
    val location: String = "India"
)
