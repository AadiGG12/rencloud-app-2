import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/rencloud_plan.dart';
import '../../core/theme/app_theme.dart';

class DeployModal extends StatefulWidget {
  final RenCloudPlan plan;

  const DeployModal({super.key, required this.plan});

  @override
  State<DeployModal> createState() => _DeployModalState();
}

class _DeployModalState extends State<DeployModal> {
  // Pterodactyl Synced Real Locations
  String selectedRegion = 'Mumbai, India (IN-01)';
  final List<String> panelLocations = [
    'Mumbai, India (IN-01 Asia-South)',
    'Singapore (SG-01 Asia-Southeast)',
    'Frankfurt, Germany (DE-01 Europe)',
    'N. Virginia, USA (US-EAST-01)',
  ];

  // Pterodactyl Real Nodes
  String selectedNode = 'Node 01 - AMD Ryzen 9 7950X (High Speed NVMe)';
  final List<String> panelNodes = [
    'Node 01 - AMD Ryzen 9 7950X (High Speed NVMe)',
    'Node 02 - AMD EPYC 7763 (Extreme Performance)',
    'Node 03 - Intel Core i9-14900K (Gaming Priority)',
    'Node 04 - Auto Allocate Best Performance',
  ];

  // Minecraft Pterodactyl Eggs
  String selectedEgg = 'Paper (Recommended - Anti-Lag)';
  final List<String> minecraftEggs = [
    'Paper (Recommended - Anti-Lag)',
    'Purpur (Ultra High Performance)',
    'Spigot / CraftBukkit',
    'Vanilla Minecraft',
    'Fabric (Modded)',
    'Forge (Modded)',
    'Velocity / BungeeCord Proxy',
    'Geyser / Bedrock Crossplay',
  ];

  // Selected Minecraft Version
  String selectedVersion = '1.21.4 (Latest Release)';

  // Non-Minecraft OS Options
  String selectedOs = 'Ubuntu 24.04 LTS';
  final List<String> osOptions = [
    'Ubuntu 24.04 LTS (Recommended)',
    'Ubuntu 22.04 LTS',
    'Debian 12 Bookworm',
    'AlmaLinux 9',
    'Alpine Linux 3.20 (Lightweight)',
    'Windows Server 2022',
  ];

  bool get isMinecraftService {
    final cat = widget.plan.categoryName.toLowerCase();
    final name = widget.plan.name.toLowerCase();
    return cat.contains('minecraft') || name.contains('minecraft') || cat.contains('mc');
  }

  // Complete List of Minecraft Versions from Newest (1.21.4) to Oldest (1.7.10)
  final List<String> allMinecraftVersions = [
    '1.21.4 (Latest Release)',
    '1.21.3',
    '1.21.1',
    '1.21',
    '1.20.6',
    '1.20.4',
    '1.20.2',
    '1.20.1 (Popular Modded)',
    '1.19.4',
    '1.19.3',
    '1.19.2',
    '1.19',
    '1.18.2',
    '1.18.1',
    '1.17.1',
    '1.16.5 (Popular Modded)',
    '1.15.2',
    '1.14.4',
    '1.13.2',
    '1.12.2 (Classic Modded)',
    '1.11.2',
    '1.10.2',
    '1.9.4',
    '1.8.9 (Popular PvP)',
    '1.8.8',
    '1.7.10 (Legacy Classic)',
  ];

  void _openMinecraftVersionDialog() {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredVersions = allMinecraftVersions.where((v) {
              return v.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 440,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Minecraft Version',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search bar
                    TextField(
                      onChanged: (val) {
                        setModalState(() => searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search version (e.g. 1.21, 1.16.5, 1.8.9)...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.accentAqua),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quick Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            label: const Text('Latest 1.21.4', style: TextStyle(fontSize: 10)),
                            onPressed: () {
                              setState(() => selectedVersion = '1.21.4 (Latest Release)');
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            label: const Text('1.20.1 Modded', style: TextStyle(fontSize: 10)),
                            onPressed: () {
                              setState(() => selectedVersion = '1.20.1 (Popular Modded)');
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            label: const Text('1.16.5', style: TextStyle(fontSize: 10)),
                            onPressed: () {
                              setState(() => selectedVersion = '1.16.5 (Popular Modded)');
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            label: const Text('1.8.9 PvP', style: TextStyle(fontSize: 10)),
                            onPressed: () {
                              setState(() => selectedVersion = '1.8.9 (Popular PvP)');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredVersions.length,
                        itemBuilder: (context, index) {
                          final v = filteredVersions[index];
                          final bool isSelected = v == selectedVersion;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppTheme.accentAqua : AppTheme.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              v,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.accentAqua : null,
                              ),
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => selectedVersion = v);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Deploy ${widget.plan.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Plan Overview Banner Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardSurfaceDark : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.plan.categoryName, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        Text(widget.plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${widget.plan.cpu} • ${widget.plan.ram} • ${widget.plan.nvmeStorage}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.accentAqua, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      '₹${widget.plan.monthlyPriceInr}/mo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.accentAqua,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. SELECT SERVER REGION (Synced with Pterodactyl Panel)
              Row(
                children: const [
                  Icon(Icons.public_rounded, size: 16, color: AppTheme.accentAqua),
                  SizedBox(width: 6),
                  Text('Pterodactyl Server Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedRegion,
                isExpanded: true,
                items: panelLocations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => selectedRegion = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),

              // 2. SELECT PTERODACTYL NODE
              Row(
                children: const [
                  Icon(Icons.dns_rounded, size: 16, color: AppTheme.primaryPurple),
                  SizedBox(width: 6),
                  Text('Target Pterodactyl Node', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedNode,
                isExpanded: true,
                items: panelNodes.map((n) => DropdownMenuItem(value: n, child: Text(n, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => selectedNode = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),

              // 3. MINECRAFT SERVICE CUSTOM CONTROLS (EGG + VERSION)
              if (isMinecraftService) ...[
                // Minecraft Egg Selector
                Row(
                  children: const [
                    Icon(Icons.sports_esports_rounded, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text('Minecraft Software / Pterodactyl Egg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedEgg,
                  isExpanded: true,
                  items: minecraftEggs.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) => setState(() => selectedEgg = val!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),

                // Minecraft Version Dialog Launcher Tile
                Row(
                  children: const [
                    Icon(Icons.tag_rounded, size: 16, color: AppTheme.metallicGold),
                    SizedBox(width: 6),
                    Text('Minecraft Version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _openMinecraftVersionDialog,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.accentAqua.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedVersion,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentAqua),
                        ),
                        const Icon(Icons.arrow_drop_down_circle_rounded, color: AppTheme.accentAqua, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Non-Minecraft OS Selector
                const Text('Operating System / Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedOs,
                  isExpanded: true,
                  items: osOptions.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) => setState(() => selectedOs = val!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Confirm Launch Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.metallicSteelGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentAqua.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                    final String softwareDetails = isMinecraftService
                        ? '$selectedEgg ($selectedVersion)'
                        : selectedOs;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🚀 Launching ${widget.plan.name} in $selectedRegion on $selectedNode ($softwareDetails)!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'CONFIRM & LAUNCH INSTANT PROVISIONING',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
