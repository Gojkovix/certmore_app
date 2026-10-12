import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/grouped_list.dart';
import '../../../core/widgets/tab_page.dart';
import '../../onboarding/models/onboarding_answers.dart';
import '../../onboarding/presentation/exam_date_picker.dart';
import '../../onboarding/presentation/widgets/selection_option.dart';

/// Profil: samo nastavitve, ki dejansko delujejo. Pomoč, obvestila in
/// videz dodamo, ko bodo imeli implementacijo.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changeExamDate(BuildContext context) async {
    final store = AppScope.of(context).onboardingStore;
    final answers = store.load() ?? const OnboardingAnswers();
    final picked = await showExamDatePicker(context, current: answers.examDate);
    if (picked != null) {
      await store.save(answers.withExamDate(picked, today: DateTime.now()));
    }
  }

  Future<void> _changeGoal(BuildContext context) async {
    final store = AppScope.of(context).onboardingStore;
    final answers = store.load() ?? const OnboardingAnswers();
    final goal = await showModalBottomSheet<PreparationGoal>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (context) => _GoalSheet(current: answers.goal),
    );
    if (goal != null) await store.save(answers.copyWith(goal: goal));
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Se želiš odjaviti?', style: AppTypography.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Prekliči'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Odjava'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await AppScope.of(context).auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final user = services.auth.user;

    return ListenableBuilder(
      listenable: services.onboardingStore,
      builder: (context, _) {
        final answers = services.onboardingStore.load();
        final examDate = answers?.examDate;

        return TabPage(
          children: [
            Semantics(
              header: true,
              child: Text(user?.name ?? '', style: AppTypography.headline),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(user?.email ?? '', style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Priprava'),
            GroupedList(
              children: [
                ListRow(
                  title: 'Datum izpita',
                  subtitle: examDate != null
                      ? formatLongDate(examDate)
                      : answers?.examTiming?.label ?? 'Ni nastavljen',
                  onTap: () => _changeExamDate(context),
                ),
                ListRow(
                  title: 'Cilj',
                  subtitle: answers?.goal?.label ?? 'Ni nastavljen',
                  onTap: () => _changeGoal(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Račun'),
            GroupedList(
              children: [
                ListRow(
                  title: 'Odjava',
                  titleColor: AppColors.error,
                  trailing: const SizedBox.shrink(),
                  onTap: () => _signOut(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              [
                'Certmore 1.0.0',
                if (services.auth.isLocal)
                  'Demo način: podatki so shranjeni samo na tej napravi.',
              ].join('\n'),
              style: AppTypography.caption,
            ),
          ],
        );
      },
    );
  }
}

class _GoalSheet extends StatelessWidget {
  const _GoalSheet({required this.current});

  final PreparationGoal? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Kaj želiš doseči?', style: AppTypography.title),
            const SizedBox(height: AppSpacing.lg),
            for (final (i, goal) in PreparationGoal.values.indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm - 2),
              SelectionOption(
                label: goal.label,
                selected: goal == current,
                onTap: () => Navigator.pop(context, goal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
