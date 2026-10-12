import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_format.dart';
import '../../onboarding/models/onboarding_answers.dart';

/// ZAČASNO (faza 3): registracija in prijava še nista izdelani, ker
/// zaledje za avtentikacijo še ni določeno. Zaslon to pošteno pove,
/// namesto da bi simuliral uspešno prijavo.
class AuthPendingScreen extends StatelessWidget {
  const AuthPendingScreen.register({super.key, this.answers})
      : title = 'Ustvari račun';

  const AuthPendingScreen.login({super.key})
      : title = 'Dobrodošel nazaj.',
        answers = null;

  final String title;
  final OnboardingAnswers? answers;

  @override
  Widget build(BuildContext context) {
    final answers = this.answers;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                tooltip: 'Nazaj',
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                top: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.headline),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Ta del aplikacije je še v pripravi.',
                    style: AppTypography.bodySecondary,
                  ),
                  if (kDebugMode && answers != null) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _DebugAnswers(answers: answers),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Samo v razvojni različici: pokaže zbrane odgovore iz onboardinga,
/// da lahko preveriš, ali se pravilno prenesejo naprej.
class _DebugAnswers extends StatelessWidget {
  const _DebugAnswers({required this.answers});

  final OnboardingAnswers answers;

  @override
  Widget build(BuildContext context) {
    final examDate = answers.examDate;
    final rows = [
      ('Vir', answers.discovery?.label),
      ('Cilj', answers.goal?.label),
      (
        'Izpit',
        examDate != null ? formatLongDate(examDate) : answers.examTiming?.label,
      ),
      ('Znanje', answers.knowledge?.label),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG · odgovori iz onboardinga',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final (key, value) in rows)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '$key: ${value ?? '—'}',
                  style: AppTypography.bodySecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
