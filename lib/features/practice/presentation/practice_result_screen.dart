import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/grouped_list.dart';
import '../../../core/widgets/pill_button.dart';
import '../../progress/models/practice_record.dart';
import '../models/practice_request.dart';

/// Povzetek zaključene vaje: rezultat, kratek komentar in pregled
/// odgovorov. Brez konfetov — rezultat govori sam zase.
class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key, required this.record});

  final PracticeRecord record;

  static String summary(int correct, int total) {
    if (total == 0) return '';
    final ratio = correct / total;
    if (ratio == 1) return 'Vse pravilno. To snov dobro obvladaš.';
    if (ratio >= 0.7) {
      return 'Dober rezultat. Poglej še vprašanja, pri katerih si se zmotil.';
    }
    if (ratio >= 0.4) {
      return 'Na dobri poti si. Preberi pojasnila in poskusi znova.';
    }
    return 'Ta snov potrebuje še nekaj vaje. Preberi pojasnila in poskusi znova.';
  }

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;
    final total = record.answers.length;
    final correct = record.correctCount;
    final wrongIds = [
      for (final a in record.answers)
        if (!a.correct) a.questionId,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.huge,
                  AppSpacing.page,
                  AppSpacing.xl,
                ),
                children: [
                  Text(
                    record.title,
                    style: AppTypography.label.copyWith(color: AppColors.teal),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    label: '$correct od $total pravilnih odgovorov',
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        text: '$correct',
                        children: [
                          TextSpan(
                            text: ' / $total',
                            style: AppTypography.display.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      style: AppTypography.display.copyWith(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  const Text(
                    'pravilnih odgovorov',
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(summary(correct, total), style: AppTypography.body),
                  const SizedBox(height: AppSpacing.xxl),
                  GroupedList(
                    children: [
                      for (final answer in record.answers)
                        _AnswerRow(
                          text:
                              content.question(answer.questionId)?.text ??
                              'Vprašanje ni več na voljo.',
                          correct: answer.correct,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wrongIds.isNotEmpty) ...[
                    PillButton.secondary(
                      label: 'Ponovi napačne',
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.practiceSession,
                        arguments: PracticeRequest.review(wrongIds),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  PillButton(
                    label: 'Končaj',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.text, required this.correct});

  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${correct ? 'Pravilno' : 'Napačno'}: $text',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Icons.check_rounded : Icons.close_rounded,
              size: 20,
              color: correct ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
