import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pill_button.dart';
import '../models/onboarding_answers.dart';
import 'widgets/onboarding_progress.dart';
import 'widgets/selection_option.dart';

/// Štirje kratki koraki, prikazani kot pogovor: eno vprašanje naenkrat,
/// odgovori ostanejo shranjeni ob vračanju nazaj.
///
/// Stanje je preprosto (en indeks koraka + odgovori), zato zadošča
/// StatefulWidget brez knjižnice za upravljanje stanja.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _stepCount = 4;

  int _step = 0;
  OnboardingAnswers _answers = const OnboardingAnswers();
  bool _completing = false;
  bool _restored = false;

  /// InheritedWidget (AppScope) v initState še ni dostopen,
  /// zato prejšnje odgovore naložimo tukaj — samo enkrat.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    _answers = AppScope.of(context).onboardingStore.load() ?? _answers;
  }

  bool get _isLastStep => _step == _stepCount - 1;

  bool get _canContinue => switch (_step) {
    0 => _answers.discovery != null,
    1 => _answers.goal != null,
    2 => _answers.examTiming != null,
    _ => _answers.knowledge != null,
  };

  /// Vsako izbiro takoj shranimo, da se ob zaprtju aplikacije ne izgubi.
  void _update(OnboardingAnswers answers) {
    setState(() => _answers = answers);
    AppScope.of(context).onboardingStore.save(answers);
  }

  void _next() {
    if (!_canContinue) return;
    if (_isLastStep) {
      _complete();
    } else {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.maybePop(context);
    }
  }

  /// Zaščita pred dvojnim pritiskom: dokler je registracija odprta,
  /// drugi pritisk ne odpre še enega zaslona.
  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    await Navigator.pushNamed(context, AppRoutes.register);
    _completing = false;
  }

  Future<void> _pickExamDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _answers.examDate ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: DateTime(today.year + 3, today.month, today.day),
      helpText: 'Datum izpita',
    );
    if (picked != null && mounted) {
      _update(_answers.withExamDate(picked, today: today));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sistemski "nazaj" na Androidu najprej vrača po korakih,
    // šele na prvem koraku zapre onboarding.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(step: _step, total: _stepCount, onBack: _back),
              Padding(
                padding: AppSpacing.pagePadding,
                child: OnboardingProgress(step: _step, total: _stepCount),
              ),
              Expanded(
                // Prejšnji korak hitro zbledi, novi se pojavi takoj, a
                // njegovi elementi (FadeSlideIn) počakajo, da stari izgine —
                // besedili se tako nikoli ne prekrivata.
                child: AnimatedSwitcher(
                  duration: AppMotion.page,
                  reverseDuration: _ChoiceStep.exitDuration,
                  switchInCurve: const Threshold(0),
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
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
                child: PillButton(
                  label: 'Nadaljuj',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: _canContinue ? _next : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _ChoiceStep(
        question: 'Kako si izvedel za Certmore?',
        hint: 'Izberi eno možnost.',
        values: DiscoverySource.values,
        labelOf: (v) => v.label,
        isSelected: (v) => _answers.discovery == v,
        onSelect: (v) => _update(_answers.copyWith(discovery: v)),
      ),
      1 => _ChoiceStep(
        question: 'Kaj želiš doseči?',
        hint: 'Prilagodili bomo tvojo izkušnjo.',
        values: PreparationGoal.values,
        labelOf: (v) => v.label,
        isSelected: (v) => _answers.goal == v,
        onSelect: (v) => _update(_answers.copyWith(goal: v)),
      ),
      2 => _ChoiceStep(
        question: 'Kdaj imaš strokovni izpit?',
        hint: 'Pomagali ti bomo organizirati pripravo.',
        values: ExamTiming.values,
        labelOf: (v) => v.label,
        // Ko je izbran točen datum, je označen samo ta.
        isSelected: (v) =>
            _answers.examDate == null && _answers.examTiming == v,
        onSelect: (v) => _update(_answers.withExamTiming(v)),
        footer: _ExamDateOption(date: _answers.examDate, onTap: _pickExamDate),
      ),
      _ => _ChoiceStep(
        question: 'Kako dobro poznaš izpitno snov?',
        hint: 'Ni napačnega odgovora.',
        values: KnowledgeLevel.values,
        labelOf: (v) => v.label,
        isSelected: (v) => _answers.knowledge == v,
        onSelect: (v) => _update(_answers.copyWith(knowledge: v)),
      ),
    };
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
  });

  final int step;
  final int total;
  final VoidCallback onBack;

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Padding(
      // IconButton ima 12 px notranjega odmika, zato je ikona
      // poravnana z 24 px robom strani.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Nazaj',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          ExcludeSemantics(
            child: Text(
              '${_pad(step + 1)} / ${_pad(total)}',
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

/// Vprašanje z eno izbiro. Elementi ob prikazu zaporedno pripeljejo,
/// kar daje občutek pogovora in ne obrazca.
class _ChoiceStep<T> extends StatelessWidget {
  const _ChoiceStep({
    required this.question,
    required this.hint,
    required this.values,
    required this.labelOf,
    required this.isSelected,
    required this.onSelect,
    this.footer,
  });

  final String question;
  final String hint;
  final List<T> values;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final ValueChanged<T> onSelect;
  final Widget? footer;

  /// Koliko časa potrebuje prejšnji korak, da zbledi.
  static const exitDuration = Duration(milliseconds: 140);
  static const _stagger = Duration(milliseconds: 35);

  Duration _delay(int order) => exitDuration + _stagger * order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxxl,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            delay: _delay(0),
            child: Semantics(
              header: true,
              liveRegion: true,
              child: Text(question, style: AppTypography.headline),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FadeSlideIn(
            delay: _delay(1),
            child: Text(hint, style: AppTypography.bodySecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          for (final (i, value) in values.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm - 2),
            FadeSlideIn(
              delay: _delay(i + 2),
              child: SelectionOption(
                label: labelOf(value),
                selected: isSelected(value),
                onTap: () => onSelect(value),
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(delay: _delay(values.length + 2), child: footer!),
          ],
        ],
      ),
    );
  }
}

class _ExamDateOption extends StatelessWidget {
  const _ExamDateOption({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    return SelectionOption(
      label: date == null ? 'Izberi točen datum' : formatLongDate(date),
      subtitle: date == null ? null : 'Točen datum izpita · tapni za spremembo',
      selected: date != null,
      idleIcon: Icons.calendar_today_outlined,
      onTap: onTap,
    );
  }
}
