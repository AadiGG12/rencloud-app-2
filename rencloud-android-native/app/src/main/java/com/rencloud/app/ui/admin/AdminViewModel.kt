package com.rencloud.app.ui.admin

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.gson.Gson
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.remote.PterodactylApi
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit
import javax.inject.Inject

data class AdminUiState(
    val users: List<PanelUserAttributes> = emptyList(),
    val totalUsersCount: Int = 0,
    val isLoading: Boolean = false,
    val searchQuery: String = "",
    val errorMessage: String? = null
) {
    val filteredUsers: List<PanelUserAttributes>
        get() = if (searchQuery.isEmpty()) users
        else users.filter { u ->
            u.username.contains(searchQuery, ignoreCase = true) ||
            u.email.contains(searchQuery, ignoreCase = true) ||
            "${u.firstName} ${u.lastName}".contains(searchQuery, ignoreCase = true)
        }
}

@HiltViewModel
class AdminViewModel @Inject constructor(
    private val api: PterodactylApi,
    private val gson: Gson
) : ViewModel() {

    private val _uiState = MutableStateFlow(AdminUiState())
    val uiState: StateFlow<AdminUiState> = _uiState.asStateFlow()

    private val ptlaKey = "ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0"
    private val authHeader = "Bearer $ptlaKey"

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    init {
        loadUsers()
    }

    fun setSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        if (query.length >= 2) {
            viewModelScope.launch(Dispatchers.IO) {
                try {
                    _uiState.value = _uiState.value.copy(isLoading = true)
                    val emailResp = api.findUserByEmailFilter(authHeader, query)
                    val usernameResp = api.findUserByUsernameFilter(authHeader, query)

                    val list1 = emailResp.body()?.dataList?.map { it.attributes } ?: emptyList()
                    val list2 = usernameResp.body()?.dataList?.map { it.attributes } ?: emptyList()

                    val combined = (list1 + list2).distinctBy { it.id }
                    _uiState.value = _uiState.value.copy(users = combined, isLoading = false)
                } catch (e: Exception) {
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = e.message)
                }
            }
        }
    }

    fun loadUsers() {
        viewModelScope.launch(Dispatchers.IO) {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val resp = api.getAllUsers(authHeader)
                if (resp.isSuccessful) {
                    val usersList = resp.body()?.dataList?.map { it.attributes } ?: emptyList()
                    _uiState.value = _uiState.value.copy(
                        users = usersList,
                        totalUsersCount = usersList.size,
                        isLoading = false
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "Could not fetch users list from Pterodactyl Panel."
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.message ?: "Network error connecting to panel"
                )
            }
        }
    }
}
