import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Skupina vrstic v eni obrobljeni površini, ločenih s tanko črto —
/// mirnejše in bolj pregledno kot niz samostojnih kartic.
class GroupedList extends StatelessWidget {
  const GroupedList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadii.cardRadius,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.md,
                    color: AppColors.border,
                  ),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Vrstica v [GroupedList].
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final trailing =
        this.trailing ??
        (onTap != null
            ? const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.muted,
              )
            : null);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.option.copyWith(color: titleColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
