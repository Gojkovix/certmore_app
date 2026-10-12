import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/number_format.dart';
import '../../../core/widgets/grouped_list.dart';
import '../../../core/widgets/tab_page.dart';
import '../models/practice_request.dart';
import 'widgets/topic_list.dart';

/// Zavihek Vaja: izbira načina vaje in tem.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final content = services.content;
    final progress = services.progress;

    return TabPage(
      title: 'Vaja',
      subtitle: 'Izberi, kako želiš vaditi.',
      children: [
        ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final review = progress.questionsToReview;
            return GroupedList(
              children: [
                ListRow(
                  title: 'Mešana vaja',
                  subtitle: '5 vprašanj iz vseh tem',
                  onTap: () =>
                      startPractice(context, PracticeRequest.mixed(content)),
                ),
                if (review.isNotEmpty)
                  ListRow(
                    title: 'Ponovi napačne',
                    subtitle: questionCount(review.length),
                    onTap: () =>
                        startPractice(context, PracticeRequest.review(review)),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionTitle('Po temah'),
        const TopicList(),
        if (content.isSample) ...[
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Vprašanja so vzorčna in služijo razvoju aplikacije.',
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}
