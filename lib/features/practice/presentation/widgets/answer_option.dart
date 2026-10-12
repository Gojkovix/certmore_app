import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

enum AnswerState {
  /// Pred oddajo, ni izbran.
  idle,

  /// Pred oddajo, izbran.
  selected,

  /// Po oddaji: pravilen odgovor.
  correct,

  /// Po oddaji: izbran, a napačen.
  incorrect,

  /// Po oddaji: ni izbran in ni pravilen.
  dimmed,
}

/// En ponujen odgovor z oznako črke (A, B, C …).
///
/// Pravilnost ni sporočena samo z barvo: črka se zamenja z ikono
/// (kljukica / križec), bralnik zaslona pa prebere stanje z besedo.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
  });

  final int index;
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  String get _letter => String.fromCharCode(65 + index);

  (Color background, Color border) get _surface => switch (state) {
    AnswerState.idle ||
    AnswerState.dimmed => (AppColors.surface, AppColors.border),
    AnswerState.selected => (
      AppColors.surface,
      AppColors.navy.withValues(alpha: 0.55),
    ),
    AnswerState.correct => (
      AppColors.success.withValues(alpha: 0.07),
      AppColors.success.withValues(alpha: 0.6),
    ),
    AnswerState.incorrect => (
      AppColors.error.withValues(alpha: 0.06),
      AppColors.error.withValues(alpha: 0.6),
    ),
  };

  String? get _semanticState => switch (state) {
    AnswerState.selected => 'izbrano',
    AnswerState.correct => 'pravilen odgovor',
    AnswerState.incorrect => 'tvoj odgovor, napačen',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final (background, border) = _surface;
    final semanticState = _semanticState;

    return Semantics(
      button: onTap != null,
      selected: state == AnswerState.selected,
      inMutuallyExclusiveGroup: true,
      label: ['$_letter: $text', ?semanticState].join(', '),
      excludeSemantics: true,
      child: AnimatedOpacity(
        opacity: state == AnswerState.dimmed ? 0.55 : 1,
        duration: AppMotion.selection,
        child: AnimatedContainer(
          duration: AppMotion.selection,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: border),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadii.cardRadius,
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap!();
                    },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(letter: _letter, state: state),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(text, style: AppTypography.option),
                      ),
                    ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.letter, required this.state});

  final String letter;
  final AnswerState state;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color foreground, Color? outline) = switch (state) {
      AnswerState.selected => (AppColors.navy, Colors.white, null),
      AnswerState.correct => (AppColors.success, Colors.white, null),
      AnswerState.incorrect => (AppColors.error, Colors.white, null),
      _ => (AppColors.surface, AppColors.textSecondary, AppColors.border),
    };

    final Widget content = switch (state) {
      AnswerState.correct => Icon(
        Icons.check_rounded,
        size: 16,
        color: foreground,
      ),
      AnswerState.incorrect => Icon(
        Icons.close_rounded,
        size: 16,
        color: foreground,
      ),
      _ => Text(
        letter,
        style: AppTypography.label.copyWith(color: foreground, fontSize: 13),
      ),
    };

    return AnimatedContainer(
      duration: AppMotion.selection,
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: outline == null ? null : Border.all(color: outline),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.selection,
        child: KeyedSubtree(key: ValueKey(state), child: content),
      ),
    );
  }
}
