package com.rencloud.app.data.remote

import com.rencloud.app.data.model.LocationAttributes
import com.rencloud.app.data.model.NodeAttributes
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.PterodactylListResponse
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.*

interface PterodactylApi {

    @GET("api/application/users")
    suspend fun findUserByEmailFilter(
        @Header("Authorization") authHeader: String,
        @Query("filter[email]") email: String,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<PanelUserAttributes>>

    @GET("api/application/users")
    suspend fun findUserByUsernameFilter(
        @Header("Authorization") authHeader: String,
        @Query("filter[username]") username: String,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<PanelUserAttributes>>

    @POST("api/application/users")
    suspend fun createUser(
        @Header("Authorization") authHeader: String,
        @Body body: Map<String, @JvmSuppressWildcards Any>,
        @Header("Accept") acceptHeader: String = "application/json",
        @Header("Content-Type") contentType: String = "application/json"
    ): Response<ResponseBody>

    @GET("api/application/locations")
    suspend fun getLocations(
        @Header("Authorization") authHeader: String,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<LocationAttributes>>

    @GET("api/application/nodes")
    suspend fun getNodes(
        @Header("Authorization") authHeader: String,
        @Header("Accept") acceptHeader: String = "application/json"
    ): Response<PterodactylListResponse<NodeAttributes>>

    @GET("auth/login")
    suspend fun getLoginForm(
        @Header("User-Agent") userAgent: String = "Mozilla/5.0 (Linux; Android 10; Mobile)",
        @Header("Accept") accept: String = "text/html,application/xhtml+xml"
    ): Response<ResponseBody>

    @POST("auth/login")
    suspend fun submitLogin(
        @Header("X-CSRF-TOKEN") csrfToken: String,
        @Header("Cookie") cookie: String?,
        @Body body: Map<String, String>,
        @Header("User-Agent") userAgent: String = "Mozilla/5.0 (Linux; Android 10; Mobile)",
        @Header("X-Requested-With") requestedWith: String = "XMLHttpRequest",
        @Header("Accept") accept: String = "application/json",
        @Header("Content-Type") contentType: String = "application/json"
    ): Response<ResponseBody>
}
