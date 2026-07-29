import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/rencloud_catalog_data.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';

class CategoryTabs extends ConsumerWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: RenCloudCatalogData.categories.map((cat) {
          final isSelected = selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat['name']!),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedCategoryProvider.notifier).state = cat['id']!;
              },
              selectedColor: AppTheme.primaryPurple,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryPurple : AppTheme.borderLight,
                ),
              ),
              elevation: isSelected ? 3 : 0,
            ),
          );
        }).toList(),
      ),
    );
  }
}
