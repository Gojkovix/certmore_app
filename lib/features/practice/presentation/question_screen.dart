import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/step_progress.dart';
import '../../progress/models/practice_record.dart';
import '../models/practice_request.dart';
import '../models/question.dart';
import 'widgets/answer_option.dart';

/// Vaja: eno vprašanje naenkrat. Uporabnik izbere odgovor, ga zavestno
/// preveri, dobi povratno informacijo s pojasnilom in gre naprej.
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key, required this.request});

  final PracticeRequest request;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _scroll = ScrollController();
  final _answers = <AnswerRecord>[];

  late List<Question> _questions;
  int _index = 0;
  int? _selected;
  bool _submitted = false;
  bool _finishing = false;

  Question get _question => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final content = AppScope.of(context).content;
    _questions = [
      for (final id in widget.request.questionIds) ?content.question(id),
    ];
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _submit() {
    final selected = _selected;
    if (selected == null || _submitted) return;
    setState(() {
      _submitted = true;
      _answers.add(
        AnswerRecord(
          questionId: _question.id,
          topicId: _question.topicId,
          selectedIndex: selected,
          correct: selected == _question.correctIndex,
        ),
      );
    });
    // Povratna informacija je pod odgovori — pomaknemo jo v vidno polje.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppMotion.page,
        curve: AppMotion.standard,
      );
    });
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _submitted = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final record = PracticeRecord(
      title: widget.request.title,
      topicId: widget.request.topicId,
      finishedAt: DateTime.now(),
      answers: List.unmodifiable(_answers),
    );
    await AppScope.of(context).progress.add(record);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.practiceResult,
      arguments: record,
    );
  }

  /// Pred prekinitvijo vprašamo, če je uporabnik že kaj odgovoril.
  Future<void> _close() async {
    if (_answers.isEmpty && _selected == null) {
      Navigator.pop(context);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Prekineš vajo?', style: AppTypography.title),
        content: const Text(
          'Odgovori iz te vaje ne bodo shranjeni.',
          style: AppTypography.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nadaljuj vajo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Prekini'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  AnswerState _stateFor(int option) {
    if (!_submitted) {
      return option == _selected ? AnswerState.selected : AnswerState.idle;
    }
    if (option == _question.correctIndex) return AnswerState.correct;
    if (option == _selected) return AnswerState.incorrect;
    return AnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const _EmptySession();

    final content = AppScope.of(context).content;
    final topic = content.topic(_question.topicId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                current: _index + 1,
                total: _questions.length,
                onClose: _close,
              ),
              Padding(
                padding: AppSpacing.pagePadding,
                child: StepProgress(step: _index, total: _questions.length),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.page,
                  reverseDuration: const Duration(milliseconds: 140),
                  switchInCurve: const Threshold(0),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  child: SingleChildScrollView(
                    key: ValueKey(_index),
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.xxl,
                      AppSpacing.page,
                      AppSpacing.xl,
                    ),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            [
                              ?topic?.title,
                              if (content.isSample) 'Vzorčno vprašanje',
                            ].join(' · '),
                            style: AppTypography.label.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Semantics(
                            header: true,
                            child: Text(
                              _question.text,
                              style: AppTypography.title,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          for (final (i, option)
                              in _question.options.indexed) ...[
                            if (i > 0)
                              const SizedBox(height: AppSpacing.sm - 2),
                            AnswerOption(
                              index: i,
                              text: option,
                              state: _stateFor(i),
                              onTap: _submitted
                                  ? null
                                  : () => setState(() => _selected = i),
                            ),
                          ],
                          if (_submitted) ...[
                            const SizedBox(height: AppSpacing.xl),
                            FadeSlideIn(
                              child: _Feedback(
                                question: _question,
                                correct: _selected == _question.correctIndex,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: _submitted
                    ? PillButton(
                        label: _isLast
                            ? 'Poglej rezultat'
                            : 'Naslednje vprašanje',
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: _next,
                        loading: _finishing,
                      )
                    : PillButton(
                        label: 'Preveri odgovor',
                        onPressed: _selected == null ? null : _submit,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.current,
    required this.total,
    required this.onClose,
  });

  final int current;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            tooltip: 'Zapri vajo',
            icon: const Icon(Icons.close_rounded),
          ),
          const Spacer(),
          Semantics(
            label: 'Vprašanje $current od $total',
            excludeSemantics: true,
            child: Text(
              '$current / $total',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Povratna informacija po oddaji. Ton je podporen in profesionalen;
/// pojasnilo prikažemo samo, če ga vir vsebuje.
class _Feedback extends StatelessWidget {
  const _Feedback({required this.question, required this.correct});

  final Question question;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final explanation = question.explanation;
    final color = correct ? AppColors.success : AppColors.error;
    final correctLetter = String.fromCharCode(65 + question.correctIndex);

    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 22,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                correct ? 'Pravilno!' : 'Ni povsem pravilno.',
                style: AppTypography.cardTitle.copyWith(color: color),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Pravilen odgovor je $correctLetter.',
              style: AppTypography.bodySecondary,
            ),
          ],
          if (explanation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.soft,
                borderRadius: AppRadii.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pojasnilo', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(explanation, style: AppTypography.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySession extends StatelessWidget {
  const _EmptySession();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: const Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          'Za to vajo trenutno ni vprašanj.',
          style: AppTypography.bodySecondary,
        ),
      ),
    );
  }
}
