import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Tanka vrstica napredka. Ob spremembi koraka gladko zdrsne na novo
/// vrednost.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.step,
    required this.total,
  });

  /// Trenutni korak, začenši z 0.
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = (step + 1) / total;

    return Semantics(
      label: 'Korak ${step + 1} od $total',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: ColoredBox(
              color: AppColors.border,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: value),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.progress,
                curve: AppMotion.emphasized,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: const ColoredBox(color: AppColors.teal),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
