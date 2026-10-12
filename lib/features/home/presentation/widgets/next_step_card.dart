import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Najbolj izpostavljen element na Domov: en jasen naslednji korak.
/// Temna površina ga loči od ostale (svetle) vsebine brez dodatnih
/// okraskov.
class NextStepCard extends StatefulWidget {
  const NextStepCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  State<NextStepCard> createState() => _NextStepCardState();
}

class _NextStepCardState extends State<NextStepCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadii.large));

    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.description}',
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.99 : 1,
        duration: AppMotion.press,
        curve: AppMotion.standard,
        child: Material(
          color: AppColors.navy,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Naslednji korak',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.title,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          widget.description,
                          style: AppTypography.bodySecondary.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(
                      dimension: 40,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
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
