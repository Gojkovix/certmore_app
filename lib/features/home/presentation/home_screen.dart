import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../core/widgets/stats_row.dart';
import '../../../core/widgets/tab_page.dart';
import '../../practice/models/practice_request.dart';
import '../../practice/presentation/widgets/topic_list.dart';
import 'widgets/next_step_card.dart';

/// Domov: kje je uporabnik, kaj naj naredi naslednje in pot do tem.
/// Vse številke so iz dejanskih odgovorov; novemu uporabniku ne
/// prikazujemo praznih grafov ali izmišljenih odstotkov.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String greeting(DateTime now) => switch (now.hour) {
    >= 5 && < 10 => 'Dobro jutro',
    >= 10 && < 18 => 'Dober dan',
    _ => 'Dober večer',
  };

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final user = services.auth.user;

    return ListenableBuilder(
      listenable: Listenable.merge([
        services.progress,
        services.onboardingStore,
      ]),
      builder: (context, _) {
        final progress = services.progress;
        final examDate = services.onboardingStore.load()?.examDate;

        return TabPage(
          children: [
            Semantics(
              header: true,
              child: Text(
                '${greeting(DateTime.now())}, ${user?.firstName ?? ''}.',
                style: AppTypography.headline,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Pripravljen na naslednji korak?',
              style: AppTypography.bodySecondary,
            ),
            if (examDate != null) _ExamCountdown(date: examDate),
            const SizedBox(height: AppSpacing.xxl),
            _nextStep(context),
            if (progress.hasActivity) ...[
              const SizedBox(height: AppSpacing.xxl),
              const SectionTitle('Tvoj napredek'),
              StatsRow(
                stats: [
                  ('${progress.answeredCount}', 'Rešena vprašanja'),
                  (
                    progress.accuracy == null
                        ? '—'
                        : formatPercent(progress.accuracy!),
                    'Uspešnost',
                  ),
                  ('${progress.answeredOn(DateTime.now())}', 'Danes'),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Teme'),
            const TopicList(),
            if (services.content.isSample) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Vprašanja so vzorčna in služijo razvoju aplikacije.',
                style: AppTypography.caption,
              ),
            ],
          ],
        );
      },
    );
  }

  /// En sam, jasen naslednji korak glede na dejansko aktivnost.
  Widget _nextStep(BuildContext context) {
    final services = AppScope.of(context);
    final content = services.content;
    final progress = services.progress;

    if (!progress.hasActivity) {
      return NextStepCard(
        title: 'Začni prvo vajo',
        description: 'Kratka mešana vaja s 5 vprašanji iz vseh tem.',
        onTap: () => startPractice(context, PracticeRequest.mixed(content)),
      );
    }

    final weakest = progress.weakestTopic(content.topics.map((t) => t.id));
    final weakestTopic = weakest == null ? null : content.topic(weakest);
    if (weakestTopic != null) {
      final accuracy = progress.statsFor(weakestTopic.id).accuracy!;
      return NextStepCard(
        title: 'Ponovi temo ${weakestTopic.title}',
        description:
            'Tu imaš trenutno ${formatPercent(accuracy)} uspešnost — '
            'največ prostora za napredek.',
        onTap: () => startPractice(
          context,
          PracticeRequest.topic(content, weakestTopic.id),
        ),
      );
    }

    final review = progress.questionsToReview;
    if (review.isNotEmpty) {
      return NextStepCard(
        title: 'Ponovi napačne odgovore',
        description:
            'Še enkrat preveri ${questionCount(review.length)}, '
            'pri katerih si se zmotil.',
        onTap: () => startPractice(context, PracticeRequest.review(review)),
      );
    }

    final last = progress.lastRecord!;
    return NextStepCard(
      title: 'Nadaljuj z učenjem',
      description:
          'Zadnjič: ${last.title} · ${last.correctCount}/${last.answers.length} '
          'pravilnih.',
      onTap: () => startPractice(context, PracticeRequest.mixed(content)),
    );
  }
}

class _ExamCountdown extends StatelessWidget {
  const _ExamCountdown({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final days = daysBetween(DateTime.now(), date);
    if (days < 0) return const SizedBox.shrink();

    final when = switch (days) {
      0 => 'Izpit je danes',
      1 => 'Izpit je jutri',
      _ =>
        'Izpit čez ${pluralSl(days, one: 'dan', two: 'dneva', few: 'dni', many: 'dni')}',
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.event_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              '$when · ${formatLongDate(date)}',
              style: AppTypography.bodySecondary.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
