package com.rencloud.app.data.remote

import com.rencloud.app.data.model.GatewayListResponse
import com.rencloud.app.data.model.LocationAttributes
import com.rencloud.app.data.model.NodeAttributes
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.ui.components.AnnouncementItem
import com.rencloud.app.ui.showcase.FaqItem
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.*

data class CategoryItem(
    val id: String,
    val name: String,
    val slug: String,
    val display_order: Int = 0,
    val is_active: Boolean = true
)

data class ReleaseNoteItem(
    val id: String,
    val version_code: Int,
    val version_name: String,
    val changelog: String,
    val is_mandatory: Boolean = false,
    val created_at: String = ""
)

data class ActivityLogItem(
    val id: String,
    val admin_user_id: String,
    val admin_username: String,
    val action_type: String,
    val target_type: String,
    val target_id: String,
    val details: String,
    val timestamp: String
)

data class StaffRoleItem(
    val id: String,
    val name: String,
    val description: String = "",
    val permissions: List<String> = emptyList(),
    val is_active: Boolean = true
)

data class InfraNodeTelemetry(
    val id: Int,
    val name: String,
    val location_id: Int,
    val memory_total_mb: Int,
    val memory_used_mb: Int,
    val disk_total_mb: Int,
    val disk_used_mb: Int,
    val server_count: Int
)

data class InfraTelemetryData(
    val nodes: List<InfraNodeTelemetry> = emptyList(),
    val total_locations: Int = 0,
    val total_nests: Int = 0,
    val total_servers: Int = 0
)

data class InfraTelemetryResponse(
    val success: Boolean = false,
    val telemetry: InfraTelemetryData? = null
)

interface PterodactylApi {

    // ── PUBLIC ENDPOINTS ──
    @GET("api/plans")
    suspend fun getPublicPlans(): Response<GatewayListResponse<RenCloudPlan>>

    @GET("api/faqs")
    suspend fun getPublicFaqs(): Response<GatewayListResponse<FaqItem>>

    @GET("api/announcements/active")
    suspend fun getActiveAnnouncements(): Response<GatewayListResponse<AnnouncementItem>>

    @GET("api/categories")
    suspend fun getPublicCategories(): Response<GatewayListResponse<CategoryItem>>

    @GET("api/release-notes/latest")
    suspend fun getLatestReleaseNotes(): Response<Map<String, Any>>

    // ── ADMIN PLAN CRUD ──
    @GET("api/admin/plans")
    suspend fun getAdminPlans(@Header("Authorization") token: String): Response<GatewayListResponse<RenCloudPlan>>

    @POST("api/admin/plans")
    suspend fun createPlan(@Header("Authorization") token: String, @Body plan: RenCloudPlan): Response<ResponseBody>

    @PUT("api/admin/plans/{id}")
    suspend fun updatePlan(@Header("Authorization") token: String, @Path("id") id: String, @Body plan: RenCloudPlan): Response<ResponseBody>

    @DELETE("api/admin/plans/{id}")
    suspend fun deletePlan(@Header("Authorization") token: String, @Path("id") id: String): Response<ResponseBody>

    @PATCH("api/admin/plans/{id}/toggle")
    suspend fun togglePlan(@Header("Authorization") token: String, @Path("id") id: String): Response<ResponseBody>

    // ── ADMIN FAQ CRUD ──
    @GET("api/admin/faqs")
    suspend fun getAdminFaqs(@Header("Authorization") token: String): Response<GatewayListResponse<FaqItem>>

    @POST("api/admin/faqs")
    suspend fun createFaq(@Header("Authorization") token: String, @Body faq: FaqItem): Response<ResponseBody>

    @PUT("api/admin/faqs/{id}")
    suspend fun updateFaq(@Header("Authorization") token: String, @Path("id") id: String, @Body faq: FaqItem): Response<ResponseBody>

    @DELETE("api/admin/faqs/{id}")
    suspend fun deleteFaq(@Header("Authorization") token: String, @Path("id") id: String): Response<ResponseBody>

    // ── ADMIN ANNOUNCEMENTS CRUD ──
    @GET("api/admin/announcements")
    suspend fun getAdminAnnouncements(@Header("Authorization") token: String): Response<GatewayListResponse<AnnouncementItem>>

    @POST("api/admin/announcements")
    suspend fun createAnnouncement(@Header("Authorization") token: String, @Body ann: AnnouncementItem): Response<ResponseBody>

    @PUT("api/admin/announcements/{id}")
    suspend fun updateAnnouncement(@Header("Authorization") token: String, @Path("id") id: String, @Body ann: AnnouncementItem): Response<ResponseBody>

    @DELETE("api/admin/announcements/{id}")
    suspend fun deleteAnnouncement(@Header("Authorization") token: String, @Path("id") id: String): Response<ResponseBody>

    // ── ADMIN CATEGORIES CRUD ──
    @GET("api/admin/categories")
    suspend fun getAdminCategories(@Header("Authorization") token: String): Response<GatewayListResponse<CategoryItem>>

    @POST("api/admin/categories")
    suspend fun createCategory(@Header("Authorization") token: String, @Body cat: CategoryItem): Response<ResponseBody>

    @DELETE("api/admin/categories/{id}")
    suspend fun deleteCategory(@Header("Authorization") token: String, @Path("id") id: String): Response<ResponseBody>

    // ── ADMIN RELEASE NOTES ──
    @GET("api/admin/release-notes")
    suspend fun getAdminReleaseNotes(@Header("Authorization") token: String): Response<GatewayListResponse<ReleaseNoteItem>>

    @POST("api/admin/release-notes")
    suspend fun createReleaseNote(@Header("Authorization") token: String, @Body note: ReleaseNoteItem): Response<ResponseBody>

    // ── ADMIN INFRASTRUCTURE TELEMETRY ──
    @GET("api/admin/infrastructure")
    suspend fun getInfraTelemetry(@Header("Authorization") token: String): Response<InfraTelemetryResponse>

    // ── ADMIN ACTIVITY LOGS ──
    @GET("api/admin/activity-log")
    suspend fun getActivityLog(@Header("Authorization") token: String): Response<GatewayListResponse<ActivityLogItem>>

    // ── ADMIN STAFF ROLES ──
    @GET("api/admin/roles")
    suspend fun getStaffRoles(@Header("Authorization") token: String): Response<GatewayListResponse<StaffRoleItem>>

    @POST("api/admin/roles")
    suspend fun createStaffRole(@Header("Authorization") token: String, @Body role: StaffRoleItem): Response<ResponseBody>

    @POST("api/admin/users/{id}/role")
    suspend fun assignUserRole(@Header("Authorization") token: String, @Path("id") userId: Int, @Body body: Map<String, String>): Response<ResponseBody>

    // ── PTERODACTYL USERS ──
    @GET("api/pterodactyl/users")
    suspend fun getAllUsers(
        @Query("refresh") refresh: Boolean = false,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<GatewayListResponse<PanelUserAttributes>>

    @PATCH("api/pterodactyl/users/{id}/admin")
    suspend fun toggleUserAdmin(
        @Header("Authorization") token: String,
        @Path("id") id: Int,
        @Body body: Map<String, Boolean>,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<ResponseBody>

    @GET("api/pterodactyl/locations")
    suspend fun getLocations(@Header("Accept") acceptHeader: String = "application/json"): Response<GatewayListResponse<LocationAttributes>>

    @GET("api/pterodactyl/nodes")
    suspend fun getNodes(@Header("Accept") acceptHeader: String = "application/json"): Response<GatewayListResponse<NodeAttributes>>
}
