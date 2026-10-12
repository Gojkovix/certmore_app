import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

enum PillButtonVariant { primary, secondary }

/// Glavni gumb Certmore. Polno zaobljen, z mirnim odzivom ob pritisku
/// (rahla potemnitev in komaj opazno pomanjšanje) ter gladkim prehodom
/// med omogočenim in onemogočenim stanjem.
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.primary,
    this.trailingIcon,
    this.loading = false,
  });

  const PillButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.loading = false,
  }) : variant = PillButtonVariant.secondary;

  final String label;

  /// `null` pomeni, da je gumb onemogočen.
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final IconData? trailingIcon;

  /// Med nalaganjem gumb obdrži barvo, pokaže indikator in ne sprejema
  /// pritiskov — tako preprečimo dvojno oddajo obrazca.
  final bool loading;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  (Color, Color) get _colors {
    if (widget.onPressed == null) return (AppColors.border, AppColors.muted);
    return switch (widget.variant) {
      PillButtonVariant.primary => (AppColors.navy, Colors.white),
      PillButtonVariant.secondary => (AppColors.soft, AppColors.navy),
    };
  }

  @override
  void didUpdateWidget(PillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    final pressedOverlay = widget.variant == PillButtonVariant.primary
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.navy.withValues(alpha: 0.05);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.loading ? '${widget.label}, nalaganje' : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppMotion.press,
        curve: AppMotion.standard,
        child: AnimatedContainer(
          duration: AppMotion.selection,
          curve: AppMotion.standard,
          decoration: ShapeDecoration(
            color: background,
            shape: const StadiumBorder(),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _enabled ? widget.onPressed : null,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              customBorder: const StadiumBorder(),
              splashFactory: NoSplash.splashFactory,
              highlightColor: pressedOverlay,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  // Gumb vedno zavzame celotno razpoložljivo širino.
                  child: Align(
                    heightFactor: 1,
                    child: AnimatedDefaultTextStyle(
                      duration: AppMotion.selection,
                      style: AppTypography.button.copyWith(color: foreground),
                      child: _withLoading(
                        foreground,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.label,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (widget.trailingIcon != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                widget.trailingIcon,
                                size: 18,
                                color: foreground,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Besedilo ostane v postavitvi (nevidno), da gumb ne spremeni velikosti.
  Widget _withLoading(Color color, Widget content) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: widget.loading ? 0 : 1,
          duration: AppMotion.press,
          child: content,
        ),
        if (widget.loading)
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
      ],
    );
  }
}
