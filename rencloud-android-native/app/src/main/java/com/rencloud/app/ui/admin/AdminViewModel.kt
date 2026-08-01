package com.rencloud.app.ui.admin

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.remote.PterodactylApi
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
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
    private val api: PterodactylApi
) : ViewModel() {

    private val _uiState = MutableStateFlow(AdminUiState())
    val uiState: StateFlow<AdminUiState> = _uiState.asStateFlow()

    private val ptlaKey = "ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0"
    private val authHeader = "Bearer $ptlaKey"

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
        } else if (query.isEmpty()) {
            loadUsers()
        }
    }

    // Keep backward compat
    fun searchUsers(query: String) = setSearchQuery(query)

    fun loadUsers() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                _uiState.value = _uiState.value.copy(isLoading = true)
                val resp = api.findUserByEmailFilter(authHeader, "")
                if (resp.isSuccessful) {
                    val list = resp.body()?.dataList?.map { it.attributes } ?: emptyList()
                    _uiState.value = _uiState.value.copy(
                        users = list,
                        totalUsersCount = 354,
                        isLoading = false
                    )
                } else {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }
}
