import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Spodnja navigacija z "matiranim steklom": vsebina, ki se pomika pod
/// njo, je zamegljena in rahlo vidna. Zadržano — brez sijaja, gradientov
/// ali plavajočih oblik, le zameglitev, prosojna površina in tanka črta.
///
/// Za učinek mora Scaffold imeti `extendBody: true`, da se vsebina
/// izriše tudi pod vrstico.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _height = 64.0;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.78),
            border: Border(
              top: BorderSide(
                color: AppColors.navy.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: _height,
              child: Row(
                children: [
                  for (final (i, item) in items.indexed)
                    Expanded(
                      child: _NavButton(
                        item: item,
                        selected: i == selectedIndex,
                        onTap: () {
                          if (i != selectedIndex) {
                            HapticFeedback.selectionClick();
                          }
                          onSelected(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        highlightShape: BoxShape.circle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.selection,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                key: ValueKey(selected),
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            AnimatedDefaultTextStyle(
              duration: AppMotion.selection,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
              child: Text(item.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
