package com.rencloud.app.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.rencloud.app.data.model.RenCloudUser
import com.rencloud.app.data.repository.AuthRepository
import com.rencloud.app.data.repository.AuthResult
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AuthUiState(
    val user: RenCloudUser? = null,
    val isAuthenticated: Boolean = false,
    val isBiometricAuthenticated: Boolean = false,
    val isLoading: Boolean = false,
    val isRegisterMode: Boolean = false,
    val errorMessage: String? = null,
    val successMessage: String? = null
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        restoreSession()
    }

    private fun restoreSession() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            val user = authRepository.restoreSession()
            if (user != null) {
                _uiState.value = _uiState.value.copy(
                    user = user,
                    isAuthenticated = true,
                    isLoading = false
                )
            } else {
                _uiState.value = _uiState.value.copy(
                    user = null,
                    isAuthenticated = false,
                    isLoading = false
                )
            }
        }
    }

    fun setBiometricAuthenticated(success: Boolean) {
        viewModelScope.launch {
            if (success) {
                val existingUser = authRepository.restoreSession()
                if (existingUser != null) {
                    _uiState.value = _uiState.value.copy(
                        user = existingUser,
                        isAuthenticated = true,
                        isBiometricAuthenticated = true,
                        errorMessage = null
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        isBiometricAuthenticated = false,
                        errorMessage = "No active saved session found. Please sign in with email & password."
                    )
                }
            } else {
                _uiState.value = _uiState.value.copy(isBiometricAuthenticated = false)
            }
        }
    }

    fun toggleMode() {
        _uiState.value = _uiState.value.copy(
            isRegisterMode = !_uiState.value.isRegisterMode,
            errorMessage = null,
            successMessage = null
        )
    }

    fun login(emailInput: String, passwordInput: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            when (val result = authRepository.login(emailInput, passwordInput)) {
                is AuthResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        user = result.user,
                        isAuthenticated = true,
                        isLoading = false,
                        successMessage = result.message
                    )
                }
                is AuthResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
            }
        }
    }

    fun register(fullNameInput: String, emailInput: String, passwordInput: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            when (val result = authRepository.register(fullNameInput, emailInput, passwordInput)) {
                is AuthResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        user = result.user,
                        isAuthenticated = true,
                        isLoading = false,
                        successMessage = result.message
                    )
                }
                is AuthResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
            }
        }
    }

    fun logout() {
        authRepository.logout()
        _uiState.value = AuthUiState()
    }
}
