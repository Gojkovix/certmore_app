import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Nekaj številk v eni vrstici, ločenih s tanko črto — brez grafov,
/// ki bi pri malo podatkih ne povedali ničesar.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.stats});

  /// Pari (vrednost, oznaka).
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (final (i, (value, label)) in stats.indexed) ...[
                if (i > 0)
                  const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(
                  child: Semantics(
                    label: '$label: $value',
                    excludeSemantics: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Column(
                        children: [
                          Text(
                            value,
                            style: AppTypography.title.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
