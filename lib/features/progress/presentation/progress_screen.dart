import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../core/widgets/grouped_list.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/stats_row.dart';
import '../../../core/widgets/tab_page.dart';
import '../../practice/models/practice_request.dart';
import '../../practice/presentation/widgets/topic_list.dart';
import '../progress_controller.dart';
import 'widgets/activity_chart.dart';

/// Napredek: aktivnost, uspešnost po temah in zadnje vaje.
/// Brez podatkov pokaže prazno stanje z jasnim naslednjim korakom.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _recentLimit = 5;

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final progress = services.progress;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        if (!progress.hasActivity) return const _EmptyProgress();

        final now = DateTime.now();
        final days = [
          for (var i = 6; i >= 0; i--)
            DateTime(now.year, now.month, now.day - i),
        ];
        final accuracy = progress.accuracy;

        return TabPage(
          title: 'Napredek',
          subtitle: 'Kako napreduješ pri pripravi na izpit.',
          children: [
            StatsRow(
              stats: [
                ('${progress.answeredCount}', 'Rešena vprašanja'),
                (accuracy == null ? '—' : formatPercent(accuracy), 'Uspešnost'),
                ('${progress.records.length}', 'Vaje'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Zadnjih 7 dni'),
            ActivityChart(
              days: days,
              counts: [for (final day in days) progress.answeredOn(day)],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Po temah'),
            _TopicBreakdown(progress: progress),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Zadnje vaje'),
            GroupedList(
              children: [
                for (final record in progress.records.take(_recentLimit))
                  ListRow(
                    title: record.title,
                    subtitle: formatRelativeDay(record.finishedAt, now: now),
                    trailing: Text(
                      '${record.correctCount}/${record.answers.length}',
                      style: AppTypography.label.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Uspešnost po temah s tanko vrstico. Teme, ki jih uporabnik še ni
/// vadil, so jasno označene, namesto da bi kazale 0 %.
class _TopicBreakdown extends StatelessWidget {
  const _TopicBreakdown({required this.progress});

  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;

    return GroupedList(
      children: [
        for (final topic in content.topics)
          Builder(
            builder: (context) {
              final stats = progress.statsFor(topic.id);
              final accuracy = stats.accuracy;
              return InkWell(
                onTap: () => startPractice(
                  context,
                  PracticeRequest.topic(content, topic.id),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.title,
                              style: AppTypography.option,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            accuracy == null ? '—' : formatPercent(accuracy),
                            style: AppTypography.label.copyWith(
                              color: accuracy == null
                                  ? AppColors.muted
                                  : AppColors.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _Meter(value: accuracy ?? 0),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        accuracy == null
                            ? 'Še nisi vadil'
                            : '${stats.correct} od ${questionCount(stats.answered)} pravilno',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.border,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: const ColoredBox(color: AppColors.teal),
          ),
        ),
      ),
    );
  }
}

class _EmptyProgress extends StatelessWidget {
  const _EmptyProgress();

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;

    return TabPage(
      title: 'Napredek',
      children: [
        const Text(
          'Tukaj boš videl, kako napreduješ.',
          style: AppTypography.cardTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Ko rešiš prvo vajo, se bodo tu pokazali uspešnost po temah, '
          'tvoja aktivnost in zadnje vaje.',
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        PillButton(
          label: 'Začni vajo',
          onPressed: () =>
              startPractice(context, PracticeRequest.mixed(content)),
        ),
      ],
    );
  }
}
