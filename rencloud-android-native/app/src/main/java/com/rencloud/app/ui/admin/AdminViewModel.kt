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

    init {
        loadUsers()
    }

    fun setSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
    }

    fun loadUsers(refresh: Boolean = false) {
        viewModelScope.launch(Dispatchers.IO) {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val resp = api.getAllUsers(refresh = refresh)
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
                        errorMessage = "Could not fetch users list from RenCloud Gateway."
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.message ?: "Network error connecting to gateway"
                )
            }
        }
    }
}
