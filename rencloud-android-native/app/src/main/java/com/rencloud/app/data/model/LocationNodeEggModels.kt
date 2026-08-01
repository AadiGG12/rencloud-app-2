package com.rencloud.app.data.model

import com.google.gson.annotations.SerializedName

data class GatewayListResponse<T>(
    @SerializedName("success") val success: Boolean = false,
    @SerializedName("count") val count: Int = 0,
    @SerializedName("data") val dataList: List<T>? = emptyList()
)

data class PterodactylListResponse<T>(
    @SerializedName("data") val dataList: List<PterodactylItem<T>>? = emptyList()
)

data class PterodactylItem<T>(
    @SerializedName("attributes") val attributes: T
)

data class LocationAttributes(
    @SerializedName("id") val id: Int,
    @SerializedName("short") val shortCode: String,
    @SerializedName("long") val longName: String?
)

data class NodeAttributes(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("location_id") val locationId: Int
)

data class PanelUserAttributes(
    @SerializedName("id") val id: Int,
    @SerializedName("username") val username: String,
    @SerializedName("email") val email: String,
    @SerializedName("first_name") val firstName: String?,
    @SerializedName("last_name") val lastName: String?,
    @SerializedName("root_admin") val rootAdmin: Boolean = false
)
