import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class AnimatedGlassNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AnimatedGlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AnimatedGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<AnimatedGlassNavItem> items;

  const AnimatedGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.accentAqua.withValues(alpha: 0.35) : AppTheme.primaryPurple.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.accentAqua.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Sliding Animated Indicator Glow Pill under active tab
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              alignment: Alignment(-1.0 + (selectedIndex * (2.0 / (items.length - 1))), 1.0),
              child: FractionallySizedBox(
                widthFactor: 1.0 / items.length,
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.metallicSteelGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentAqua.withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Items Row
            Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTabSelected(index);
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected ? AppTheme.metallicSteelGradient : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.accentAqua.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.textSecondary : const Color(0xFF64748B)),
                              size: isSelected ? 22 : 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isSelected ? 10.5 : 9.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.accentAqua
                                  : (isDark ? AppTheme.textSecondary : const Color(0xFF64748B)),
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
