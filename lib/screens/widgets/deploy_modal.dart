import 'package:flutter/material.dart';
import '../../models/rencloud_plan.dart';
import '../../core/theme/app_theme.dart';

class DeployModal extends StatefulWidget {
  final RenCloudPlan plan;

  const DeployModal({super.key, required this.plan});

  @override
  State<DeployModal> createState() => _DeployModalState();
}

class _DeployModalState extends State<DeployModal> {
  String selectedRegion = 'Mumbai, India (Asia-South)';
  String selectedOs = 'Ubuntu 22.04 LTS';

  final List<String> regions = [
    'Mumbai, India (Asia-South)',
    'Singapore (Asia-Southeast)',
    'Frankfurt, Germany (Europe)',
    'US East (N. Virginia)',
  ];

  final List<String> osOptions = [
    'Ubuntu 22.04 LTS',
    'Debian 12 Bookworm',
    'AlmaLinux 9',
    'Windows Server 2022',
    'Pterodactyl Panel Pre-installed',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deploy ${widget.plan.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.plan.categoryName, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      Text(widget.plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '₹${widget.plan.monthlyPriceInr}/mo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.extrabold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Server Region', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) => setState(() => selectedRegion = val!),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            ),
            const SizedBox(height: 16),
            const Text('Select Operating System / Template', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedOs,
              items: osOptions.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) => setState(() => selectedOs = val!),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deployment initiated for ${widget.plan.name} in $selectedRegion!'),
                      backgroundColor: Colors.green[700],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm & Launch Instant Provisioning', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
