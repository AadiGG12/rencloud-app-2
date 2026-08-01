package com.rencloud.app.data.model

import com.google.gson.annotations.SerializedName

data class RenCloudUser(
    @SerializedName("id") val id: String,
    @SerializedName("full_name") val fullName: String,
    @SerializedName("email") val email: String,
    @SerializedName("role") val role: String = "client",
    @SerializedName("avatar_url") val avatarUrl: String? = null,
    @SerializedName("created_at") val createdAt: String? = null
) {
    val isAdmin: Boolean
        get() = role.equals("admin", ignoreCase = true)
}
