package com.rencloud.app.ui.admin

import android.util.Log
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
                    val body = resp.body()
                    val usersList = body?.dataList ?: emptyList()
                    val count = if (body?.count ?: 0 > 0) body!!.count else usersList.size
                    
                    Log.d("AdminViewModel", "Successfully loaded ${usersList.size} users (total count: $count)")
                    
                    _uiState.value = _uiState.value.copy(
                        users = usersList,
                        totalUsersCount = count,
                        isLoading = false,
                        errorMessage = if (usersList.isEmpty()) "No users found on panel.rencloud.online" else null
                    )
                } else {
                    val errStr = "HTTP ${resp.code()}: ${resp.message()}"
                    Log.e("AdminViewModel", "API Error fetching users: $errStr")
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = errStr
                    )
                }
            } catch (e: Exception) {
                Log.e("AdminViewModel", "Network exception fetching users: ${e.message}", e)
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.message ?: "Network error connecting to RenCloud Gateway"
                )
            }
        }
    }
}
