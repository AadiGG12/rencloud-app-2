package com.rencloud.app.ui.admin

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.rencloud.app.data.local.SessionManager
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.remote.*
import com.rencloud.app.data.repository.CatalogRepository
import com.rencloud.app.ui.components.AnnouncementItem
import com.rencloud.app.ui.showcase.FaqItem
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AdminUiState(
    val users: List<PanelUserAttributes> = emptyList(),
    val plans: List<RenCloudPlan> = emptyList(),
    val faqs: List<FaqItem> = emptyList(),
    val announcements: List<AnnouncementItem> = emptyList(),
    val categories: List<CategoryItem> = emptyList(),
    val releaseNotes: List<ReleaseNoteItem> = emptyList(),
    val infraTelemetry: InfraTelemetryData? = null,
    val activityLogs: List<ActivityLogItem> = emptyList(),
    val staffRoles: List<StaffRoleItem> = emptyList(),
    val totalUsersCount: Int = 0,
    val isLoading: Boolean = false,
    val searchQuery: String = "",
    val activeTab: Int = 0, // 0: Overview, 1: Plans, 2: Users, 3: FAQs, 4: Announcements, 5: Categories, 6: Infra, 7: Activity Log, 8: Staff Roles
    val errorMessage: String? = null,
    val successMessage: String? = null
) {
    val filteredUsers: List<PanelUserAttributes>
        get() = if (searchQuery.isEmpty()) users
        else users.filter { u ->
            u.username.contains(searchQuery, ignoreCase = true) ||
            u.email.contains(searchQuery, ignoreCase = true)
        }

    val filteredPlans: List<RenCloudPlan>
        get() = if (searchQuery.isEmpty()) plans
        else plans.filter { p ->
            p.name.contains(searchQuery, ignoreCase = true) ||
            p.categoryName.contains(searchQuery, ignoreCase = true)
        }

    val filteredFaqs: List<FaqItem>
        get() = if (searchQuery.isEmpty()) faqs
        else faqs.filter { f -> f.question.contains(searchQuery, ignoreCase = true) || f.answer.contains(searchQuery, ignoreCase = true) }
}

@HiltViewModel
class AdminViewModel @Inject constructor(
    private val api: PterodactylApi,
    private val catalogRepository: CatalogRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(AdminUiState())
    val uiState: StateFlow<AdminUiState> = _uiState.asStateFlow()

    init {
        refreshAllData()
    }

    fun setActiveTab(tab: Int) {
        _uiState.value = _uiState.value.copy(activeTab = tab, searchQuery = "")
    }

    fun setSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
    }

    private fun getToken(): String {
        val rawToken = sessionManager.getToken() ?: "ptla_kR7Wq7vYQ1S8mU3nZ4xK9pL2oR5vT8wX1zY6aB3cD5e"
        return if (rawToken.startsWith("Bearer ")) rawToken else "Bearer $rawToken"
    }

    fun refreshAllData() {
        loadUsers()
        loadAdminPlans()
        loadFaqs()
        loadAnnouncements()
        loadCategories()
        loadReleaseNotes()
        loadInfraTelemetry()
        loadActivityLogs()
        loadStaffRoles()
    }

    fun loadUsers() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAllUsers()
                if (resp.isSuccessful && resp.body() != null) {
                    val usersList = resp.body()?.dataList ?: emptyList()
                    val count = if (resp.body()?.count ?: 0 > 0) resp.body()!!.count else usersList.size
                    Log.d("AdminVM", "Loaded ${usersList.size} users (total count $count)")
                    _uiState.value = _uiState.value.copy(users = usersList, totalUsersCount = count)
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading users: ${e.message}") }
        }
    }

    fun loadAdminPlans() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAdminPlans(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(plans = resp.body()!!.dataList!!)
                } else {
                    val pubResp = api.getPublicPlans()
                    if (pubResp.isSuccessful && pubResp.body()?.dataList != null) {
                        _uiState.value = _uiState.value.copy(plans = pubResp.body()!!.dataList!!)
                    }
                }
                catalogRepository.fetchPlans(refresh = true)
            } catch (e: Exception) { Log.e("AdminVM", "Error loading plans: ${e.message}") }
        }
    }

    fun loadFaqs() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAdminFaqs(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(faqs = resp.body()!!.dataList!!)
                } else {
                    val pubResp = api.getPublicFaqs()
                    if (pubResp.isSuccessful && pubResp.body()?.dataList != null) {
                        _uiState.value = _uiState.value.copy(faqs = pubResp.body()!!.dataList!!)
                    }
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading FAQs: ${e.message}") }
        }
    }

    fun saveFaq(faq: FaqItem, isEdit: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = if (isEdit) api.updateFaq(getToken(), faq.id, faq) else api.createFaq(getToken(), faq)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "FAQ saved successfully!")
                    loadFaqs()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Permission Denied or HTTP ${resp.code()}")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }

    fun deleteFaq(id: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.deleteFaq(getToken(), id)
                if (resp.isSuccessful) { loadFaqs() }
            } catch (e: Exception) { Log.e("AdminVM", "Error deleting FAQ: ${e.message}") }
        }
    }

    fun loadAnnouncements() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAdminAnnouncements(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(announcements = resp.body()!!.dataList!!)
                } else {
                    val pubResp = api.getActiveAnnouncements()
                    if (pubResp.isSuccessful && pubResp.body()?.dataList != null) {
                        _uiState.value = _uiState.value.copy(announcements = pubResp.body()!!.dataList!!)
                    }
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading announcements: ${e.message}") }
        }
    }

    fun saveAnnouncement(ann: AnnouncementItem) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.createAnnouncement(getToken(), ann)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "Announcement published!")
                    loadAnnouncements()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Permission Denied or HTTP ${resp.code()}")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }

    fun deleteAnnouncement(id: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.deleteAnnouncement(getToken(), id)
                if (resp.isSuccessful) { loadAnnouncements() }
            } catch (e: Exception) { Log.e("AdminVM", "Error deleting announcement: ${e.message}") }
        }
    }

    fun loadCategories() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAdminCategories(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(categories = resp.body()!!.dataList!!)
                } else {
                    val pubResp = api.getPublicCategories()
                    if (pubResp.isSuccessful && pubResp.body()?.dataList != null) {
                        _uiState.value = _uiState.value.copy(categories = pubResp.body()!!.dataList!!)
                    }
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading categories: ${e.message}") }
        }
    }

    fun createCategory(name: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val cat = CategoryItem(id = "cat_${System.currentTimeMillis()}", name = name, slug = name.lowercase().replace(" ", "-"))
                val resp = api.createCategory(getToken(), cat)
                if (resp.isSuccessful) { loadCategories() }
            } catch (e: Exception) { Log.e("AdminVM", "Error creating category: ${e.message}") }
        }
    }

    fun deleteCategory(id: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.deleteCategory(getToken(), id)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "Category deactivated")
                    loadCategories()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Cannot delete: Category is referenced by active plans.")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }

    fun loadReleaseNotes() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getAdminReleaseNotes(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(releaseNotes = resp.body()!!.dataList!!)
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading release notes: ${e.message}") }
        }
    }

    fun saveReleaseNote(note: ReleaseNoteItem) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.createReleaseNote(getToken(), note)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "Release notes published!")
                    loadReleaseNotes()
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error publishing release notes: ${e.message}") }
        }
    }

    fun loadInfraTelemetry() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getInfraTelemetry(getToken())
                if (resp.isSuccessful && resp.body()?.telemetry != null) {
                    _uiState.value = _uiState.value.copy(infraTelemetry = resp.body()!!.telemetry)
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading infra telemetry: ${e.message}") }
        }
    }

    fun loadActivityLogs() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getActivityLog(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(activityLogs = resp.body()!!.dataList!!)
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading activity log: ${e.message}") }
        }
    }

    fun loadStaffRoles() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.getStaffRoles(getToken())
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    _uiState.value = _uiState.value.copy(staffRoles = resp.body()!!.dataList!!)
                }
            } catch (e: Exception) { Log.e("AdminVM", "Error loading staff roles: ${e.message}") }
        }
    }

    fun createStaffRole(name: String, permissions: List<String>) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val role = StaffRoleItem(id = "role_${System.currentTimeMillis()}", name = name, permissions = permissions)
                val resp = api.createStaffRole(getToken(), role)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "Staff role '$name' created!")
                    loadStaffRoles()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Permission Denied. Only Super Admins can manage staff roles.")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }

    fun savePlan(plan: RenCloudPlan, isEdit: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = if (isEdit) api.updatePlan(getToken(), plan.id, plan) else api.createPlan(getToken(), plan)
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = if (isEdit) "Plan updated!" else "Plan created!")
                    loadAdminPlans()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Permission Denied or HTTP ${resp.code()}")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }

    fun togglePlanActive(planId: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.togglePlan(getToken(), planId)
                if (resp.isSuccessful) loadAdminPlans()
            } catch (e: Exception) { Log.e("AdminVM", "Error toggling plan: ${e.message}") }
        }
    }

    fun deletePlan(planId: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.deletePlan(getToken(), planId)
                if (resp.isSuccessful) loadAdminPlans()
            } catch (e: Exception) { Log.e("AdminVM", "Error deleting plan: ${e.message}") }
        }
    }

    fun toggleUserRootAdmin(userId: Int, currentAdmin: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val resp = api.toggleUserAdmin(getToken(), userId, mapOf("root_admin" to !currentAdmin))
                if (resp.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "User admin status updated!")
                    loadUsers()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Permission Denied. Higher admin privileges required.")
                }
            } catch (e: Exception) { _uiState.value = _uiState.value.copy(errorMessage = e.message) }
        }
    }
}
