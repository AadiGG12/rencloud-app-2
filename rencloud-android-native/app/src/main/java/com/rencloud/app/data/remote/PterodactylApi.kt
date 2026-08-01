package com.rencloud.app.data.remote

import com.rencloud.app.data.model.LocationAttributes
import com.rencloud.app.data.model.NodeAttributes
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.PterodactylListResponse
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.*

interface PterodactylApi {

    @GET("api/pterodactyl/users")
    suspend fun getAllUsers(
        @Query("refresh") refresh: Boolean = false,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<PanelUserAttributes>>

    @GET("api/pterodactyl/locations")
    suspend fun getLocations(
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<LocationAttributes>>

    @GET("api/pterodactyl/nodes")
    suspend fun getNodes(
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<NodeAttributes>>

    @GET("api/pterodactyl/eggs")
    suspend fun getEggs(
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<ResponseBody>

    @GET("api/pterodactyl/servers")
    suspend fun getServers(
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<ResponseBody>

    @POST("api/auth/login")
    suspend fun loginUser(
        @Body credentials: Map<String, String>,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<ResponseBody>
}
