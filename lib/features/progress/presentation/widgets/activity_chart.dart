import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/number_format.dart';

/// Število rešenih vprašanj po dnevih (zadnjih 7 dni, danes desno).
///
/// En poudarek (teal), nevtralni prazni dnevi, vrednosti neposredno nad
/// stolpci — brez mreže in legende, ki pri sedmih stolpcih nista potrebni.
class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key, required this.days, required this.counts});

  /// Dnevi od najstarejšega do danes.
  final List<DateTime> days;
  final List<int> counts;

  static const _barAreaHeight = 72.0;
  static const _weekdays = ['P', 'T', 'S', 'Č', 'P', 'S', 'N'];

  @override
  Widget build(BuildContext context) {
    final max = counts.fold(0, (a, b) => a > b ? a : b);
    final total = counts.fold(0, (a, b) => a + b);

    return Semantics(
      label: 'Zadnjih 7 dni: skupaj ${questionCount(total)}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, count) in counts.indexed)
                Expanded(
                  child: _Bar(
                    count: count,
                    fraction: max == 0 ? 0 : count / max,
                    label: _weekdays[days[i].weekday - 1],
                    isToday: i == counts.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.count,
    required this.fraction,
    required this.label,
    required this.isToday,
  });

  final int count;
  final double fraction;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final height = count == 0
        ? 3.0
        : (ActivityChart._barAreaHeight * fraction).clamp(6.0, 72.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count == 0 ? '' : '$count',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        TweenAnimationBuilder<double>(
          tween: Tween(end: height),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.progress,
          curve: AppMotion.standard,
          builder: (context, value, _) => Container(
            width: 20,
            height: value,
            decoration: BoxDecoration(
              color: count == 0 ? AppColors.border : AppColors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isToday ? AppColors.textPrimary : AppColors.muted,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
