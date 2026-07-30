import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/rencloud_plan.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/rencloud_auth_provider.dart';
import '../widgets/skeuomorphic_card.dart';

class AdminControlCenter extends ConsumerStatefulWidget {
  const AdminControlCenter({super.key});

  @override
  ConsumerState<AdminControlCenter> createState() => _AdminControlCenterState();
}

class _AdminControlCenterState extends ConsumerState<AdminControlCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _maintenanceMode = false;
  bool _announcementActive = true;
  final TextEditingController _announcementController =
      TextEditingController(text: '⚡ Summer Special: Get 20% off on all NVMe Minecraft & VPS Plans!');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(filteredPlansProvider);
    final authState = ref.watch(rencloudAuthProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RenCloud Admin Control Center'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.accentAqua,
          labelColor: AppTheme.accentAqua,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Plan Manager'),
            Tab(icon: Icon(Icons.web_rounded), text: 'App & Website'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'User Roles'),
            Tab(icon: Icon(Icons.developer_board_rounded), text: 'Node Health'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Plan Management Tab
          _buildPlanManagerTab(plans),

          // 2. App & Website Settings Tab
          _buildWebsiteSettingsTab(),

          // 3. User Roles & Admin Access Tab
          _buildUserRolesTab(user),

          // 4. Node Health & Metrics Tab
          _buildNodeHealthTab(),
        ],
      ),
    );
  }

  // --- TAB 1: PLAN MANAGER ---
  Widget _buildPlanManagerTab(List<RenCloudPlan> plans) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Catalog Plans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              ElevatedButton.icon(
                onPressed: _showAddPlanDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add New Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAqua,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return SkeuomorphicCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAqua.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dns_rounded, color: AppTheme.accentAqua, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (plan.isPopular) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.metallicGoldGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('POPULAR', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black)),
                                ),
                              ],
                            ],
                          ),
                          Text('${plan.cpu} • ${plan.ram} • ${plan.nvmeStorage}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                          Text('Price: ₹${plan.monthlyPriceInr}/mo', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.accentAqua)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppTheme.accentAqua, size: 20),
                      onPressed: () => _showEditPlanDialog(plan),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 2: WEBSITE & APP SETTINGS ---
  Widget _buildWebsiteSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Global App & Website Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          SkeuomorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Global Maintenance Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Blocks new orders & shows maintenance banner to non-admin users', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  value: _maintenanceMode,
                  activeColor: Colors.redAccent,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _maintenanceMode = val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Announcement Banner Broadcast', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Display marquee announcement at top of app home screen', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  value: _announcementActive,
                  activeColor: AppTheme.accentAqua,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _announcementActive = val);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _announcementController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Announcement Banner Message',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Website settings saved & broadcasted!'), backgroundColor: Colors.green),
                      );
                    },
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: USER ROLES ---
  Widget _buildUserRolesTab(dynamic currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Role & Admin Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          SkeuomorphicCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.accentAqua,
                  child: Icon(Icons.shield_rounded, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentUser?.fullName ?? 'Admin Account', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(currentUser?.email ?? 'admin@rencloud.online', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppTheme.metallicGoldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('SUPER ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: NODE HEALTH ---
  Widget _buildNodeHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Node Health & Infrastructure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SkeuomorphicCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                      SizedBox(height: 6),
                      Text('Active Nodes', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      Text('12 / 12', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkeuomorphicCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: const [
                      Icon(Icons.memory_rounded, color: AppTheme.accentAqua, size: 28),
                      SizedBox(height: 6),
                      Text('RAM Capacity', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      Text('64% Used', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Server Plan'),
        content: const Text('Enter details to deploy new plan directly to catalog.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New plan added to catalog!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Save Plan'),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(RenCloudPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${plan.name}'),
        content: Text('Modify price, RAM, CPU, or features for ${plan.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated ${plan.name}!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
