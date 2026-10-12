import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Ena izbira v onboarding vprašanju.
///
/// Izbrano stanje: rahlo teal ozadje, zadržan teal rob in majhna kljukica
/// na desni. Stanje ni izraženo samo z barvo — kljukica in semantika
/// ("izbrano") ga sporočata tudi brez nje.
class SelectionOption extends StatelessWidget {
  const SelectionOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.idleIcon,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// Ikona, prikazana na mestu kljukice, ko možnost ni izbrana.
  final IconData? idleIcon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: AppMotion.selection,
        curve: AppMotion.standard,
        decoration: BoxDecoration(
          color: selected ? AppColors.tealTint : AppColors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(
            color: selected
                ? AppColors.teal.withValues(alpha: 0.7)
                : AppColors.border,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadii.cardRadius,
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: AppTypography.option),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _Indicator(selected: selected, idleIcon: idleIcon),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.selected, this.idleIcon});

  final bool selected;
  final IconData? idleIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (idleIcon != null)
            AnimatedOpacity(
              opacity: selected ? 0 : 1,
              duration: AppMotion.selection,
              child: Icon(idleIcon, size: 20, color: AppColors.textSecondary),
            ),
          AnimatedScale(
            scale: selected ? 1 : 0.6,
            duration: AppMotion.selection,
            curve: AppMotion.standard,
            child: AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: AppMotion.selection,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 22,
                  child: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
