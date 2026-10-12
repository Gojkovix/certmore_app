import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../app/router.dart';
import '../../../../core/utils/number_format.dart';
import '../../../../core/widgets/grouped_list.dart';
import '../../models/practice_request.dart';

/// Odpre vajo. Skupna pot za vse vstopne točke (Domov, Vaja, Napredek).
void startPractice(BuildContext context, PracticeRequest request) {
  Navigator.pushNamed(context, AppRoutes.practiceSession, arguments: request);
}

/// Seznam tem z dejansko uspešnostjo — če uporabnik teme še ni vadil,
/// to pove, namesto da bi prikazal izmišljen odstotek.
class TopicList extends StatelessWidget {
  const TopicList({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final content = services.content;
    final progress = services.progress;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => GroupedList(
        children: [
          for (final topic in content.topics)
            Builder(
              builder: (context) {
                final count = content.questionsFor(topic.id).length;
                final accuracy = progress.statsFor(topic.id).accuracy;
                return ListRow(
                  title: topic.title,
                  subtitle: [
                    questionCount(count),
                    accuracy == null
                        ? 'še nisi vadil'
                        : '${formatPercent(accuracy)} uspešnost',
                  ].join(' · '),
                  onTap: () => startPractice(
                    context,
                    PracticeRequest.topic(content, topic.id),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
