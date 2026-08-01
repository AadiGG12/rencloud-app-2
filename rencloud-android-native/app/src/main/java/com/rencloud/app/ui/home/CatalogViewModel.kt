package com.rencloud.app.ui.home

import androidx.lifecycle.ViewModel
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.repository.CatalogRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

data class CatalogUiState(
    val plans: List<RenCloudPlan> = emptyList(),
    val selectedCategory: String = "All",
    val searchQuery: String = "",
    val currency: String = "INR" // "INR" or "USD"
)

@HiltViewModel
class CatalogViewModel @Inject constructor(
    private val catalogRepository: CatalogRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CatalogUiState())
    val uiState: StateFlow<CatalogUiState> = _uiState.asStateFlow()

    init {
        _uiState.value = _uiState.value.copy(plans = catalogRepository.getPlans())
    }

    fun selectCategory(category: String) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
    }

    fun setSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
    }

    fun toggleCurrency() {
        val next = if (_uiState.value.currency == "INR") "USD" else "INR"
        _uiState.value = _uiState.value.copy(currency = next)
    }

    fun getFilteredPlans(): List<RenCloudPlan> {
        val s = _uiState.value
        return s.plans.filter { plan ->
            val matchCat = when {
                s.selectedCategory == "All" -> true
                s.selectedCategory == "Minecraft" -> plan.categoryName.contains("Minecraft", ignoreCase = true)
                s.selectedCategory == "VPS Cloud" -> plan.categoryName.contains("VPS", ignoreCase = true)
                s.selectedCategory == "Game Servers" -> plan.categoryName.contains("Hytale", ignoreCase = true) || plan.categoryName.contains("ARK", ignoreCase = true)
                else -> plan.categoryName.equals(s.selectedCategory, ignoreCase = true)
            }
            val matchQuery = s.searchQuery.isEmpty() ||
                    plan.name.contains(s.searchQuery, ignoreCase = true) ||
                    plan.categoryName.contains(s.searchQuery, ignoreCase = true) ||
                    plan.ram.contains(s.searchQuery, ignoreCase = true) ||
                    plan.cpu.contains(s.searchQuery, ignoreCase = true) ||
                    plan.tagline.contains(s.searchQuery, ignoreCase = true)
            matchCat && matchQuery
        }
    }
}
