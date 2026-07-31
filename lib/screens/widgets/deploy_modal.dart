import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../models/rencloud_plan.dart';
import '../../core/theme/app_theme.dart';

class DeployModal extends StatefulWidget {
  final RenCloudPlan plan;

  const DeployModal({super.key, required this.plan});

  @override
  State<DeployModal> createState() => _DeployModalState();
}

class _DeployModalState extends State<DeployModal> {
  static const String panelUrl = 'https://panel.rencloud.online';
  static const String ptlaKey = 'ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0';

  bool _isLoadingPanelData = true;

  // Real Locations
  String selectedRegion = 'India (Asia-South)';
  List<String> panelLocations = [
    'India (Asia-South)',
    'Singapore (Asia-Southeast)',
  ];

  // Real Nodes
  String selectedNode = 'India-amd-at3 (Node #9)';
  List<String> panelNodes = [
    'India-amd-at3 (Node #9)',
    'at-intel-in6 (Node #14)',
    'at-intel-in7 (Node #15)',
    'at-ryzen-in (Node #16)',
    'hx-intel-in8 (Node #20)',
    'free-sg2 (Node #17)',
    'free-sg3 (Node #19)',
  ];

  // Real Minecraft Eggs
  String selectedEgg = 'Paper (Egg #4 - Recommended)';
  List<String> minecraftEggs = [
    'Paper (Egg #4 - Recommended)',
    'Vanilla Minecraft (Egg #5)',
    'Forge Minecraft (Egg #2)',
    'Bungeecord Proxy (Egg #1)',
    'SpongeVanilla (Egg #3)',
    'PocketmineMP (Bedrock/PE) (Egg #19)',
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
    'Node.js 21 Environment',
    'Python 3.11 Environment',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLivePanelData();
  }

  Future<void> _fetchLivePanelData() async {
    try {
      final locResp = await http.get(
        Uri.parse('$panelUrl/api/application/locations'),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      final nodeResp = await http.get(
        Uri.parse('$panelUrl/api/application/nodes'),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      if (locResp.statusCode == 200) {
        final data = json.decode(locResp.body);
        final locs = data['data'] as List<dynamic>? ?? [];
        if (locs.isNotEmpty) {
          final fetchedLocs = locs.map((e) {
            final a = e['attributes'];
            final shortName = a['short'] ?? 'Location';
            final longName = a['long'];
            return longName != null && longName.toString().isNotEmpty
                ? '$shortName ($longName)'
                : shortName.toString();
          }).toList();

          if (mounted) {
            setState(() {
              panelLocations = fetchedLocs;
              selectedRegion = fetchedLocs.first;
            });
          }
        }
      }

      if (nodeResp.statusCode == 200) {
        final data = json.decode(nodeResp.body);
        final nodes = data['data'] as List<dynamic>? ?? [];
        if (nodes.isNotEmpty) {
          final fetchedNodes = nodes.map((e) {
            final a = e['attributes'];
            final name = a['name'] ?? 'Node';
            final id = a['id'];
            return '$name (Node #$id)';
          }).toList();

          if (mounted) {
            setState(() {
              panelNodes = fetchedNodes;
              selectedNode = fetchedNodes.first;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[DeployModal] Live panel data fetch notice: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPanelData = false);
      }
    }
  }

  bool get isMinecraftService {
    final cat = widget.plan.categoryName.toLowerCase();
    final name = widget.plan.name.toLowerCase();
    return cat.contains('minecraft') || name.contains('minecraft') || cat.contains('mc');
  }

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

              // 1. SELECT SERVER REGION (Live Pterodactyl Locations)
              Row(
                children: [
                  const Icon(Icons.public_rounded, size: 16, color: AppTheme.accentAqua),
                  const SizedBox(width: 6),
                  const Text('Pterodactyl Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  if (_isLoadingPanelData) ...[
                    const SizedBox(width: 8),
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: panelLocations.contains(selectedRegion) ? selectedRegion : panelLocations.first,
                isExpanded: true,
                items: panelLocations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => selectedRegion = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),

              // 2. SELECT PTERODACTYL NODE (Live Pterodactyl Nodes)
              Row(
                children: const [
                  Icon(Icons.dns_rounded, size: 16, color: AppTheme.primaryPurple),
                  SizedBox(width: 6),
                  Text('Target Pterodactyl Node', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: panelNodes.contains(selectedNode) ? selectedNode : panelNodes.first,
                isExpanded: true,
                items: panelNodes.map((n) => DropdownMenuItem(value: n, child: Text(n, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => selectedNode = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),

              // 3. MINECRAFT EGG + VERSION OR OS SELECTOR
              if (isMinecraftService) ...[
                Row(
                  children: const [
                    Icon(Icons.sports_esports_rounded, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text('Minecraft Software / Pterodactyl Egg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: minecraftEggs.contains(selectedEgg) ? selectedEgg : minecraftEggs.first,
                  isExpanded: true,
                  items: minecraftEggs.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) => setState(() => selectedEgg = val!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),

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
                const Text('Operating System / Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: osOptions.contains(selectedOs) ? selectedOs : osOptions.first,
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
