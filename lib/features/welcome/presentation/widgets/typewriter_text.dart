import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'animated_dot.dart';

/// Izmenično natipka in izbriše fraze, s teal piko na koncu
/// (podobno kot kurzor v ChatGPT).
///
/// Višina se izračuna iz najdaljše fraze, zato se postavitev pod njo
/// nikoli ne premika — tudi pri večji sistemski pisavi.
/// Ob vklopljenem "zmanjšaj gibanje" prikaže prvo frazo statično.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.phrases,
    required this.style,
    this.typingDelay = const Duration(milliseconds: 45),
    this.deletingDelay = const Duration(milliseconds: 22),
    this.holdDuration = const Duration(milliseconds: 2800),
    this.gapDuration = const Duration(milliseconds: 320),
  });

  final List<String> phrases;
  final TextStyle style;
  final Duration typingDelay;
  final Duration deletingDelay;
  final Duration holdDuration;
  final Duration gapDuration;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  static const _punctuationPause = Duration(milliseconds: 200);

  Timer? _timer;
  int _index = 0;
  int _length = 0;
  TypewriterPhase _phase = TypewriterPhase.typing;

  bool? _reduceMotion;
  bool _active = true;

  String get _current => widget.phrases[_index];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // TickerMode je izklopljen, ko je zaslon prekrit z drugim (npr. med
    // onboardingom) — takrat tipkanje začasno ustavimo.
    final active = TickerMode.of(context);

    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _active = active;
      _restart();
    } else if (active != _active) {
      _active = active;
      active ? _scheduleFor(_phase) : _timer?.cancel();
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phrases.length != widget.phrases.length) _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    _index = 0;
    if (widget.phrases.isEmpty) return;

    if (_reduceMotion == true) {
      _length = _current.length;
      _phase = TypewriterPhase.holding;
      return;
    }

    _length = 0;
    _phase = TypewriterPhase.typing;
    if (_active) _scheduleFor(_phase);
  }

  void _scheduleFor(TypewriterPhase phase) {
    _timer?.cancel();
    if (_reduceMotion == true || widget.phrases.isEmpty) return;

    final delay = switch (phase) {
      TypewriterPhase.typing => _typingDelay(),
      TypewriterPhase.holding => widget.holdDuration,
      TypewriterPhase.deleting => widget.deletingDelay,
      TypewriterPhase.waiting => widget.gapDuration,
    };
    _timer = Timer(delay, _step);
  }

  /// Kratek premor po ločilu, da tipkanje deluje bolj naravno.
  Duration _typingDelay() {
    if (_length > 0 && _length < _current.length) {
      final last = _current[_length - 1];
      if (last == '.' || last == ',') return _punctuationPause;
    }
    return widget.typingDelay;
  }

  void _step() {
    if (!mounted) return;

    setState(() {
      switch (_phase) {
        case TypewriterPhase.typing:
          _length++;
          if (_length >= _current.length) _phase = TypewriterPhase.holding;
        case TypewriterPhase.holding:
          _phase = TypewriterPhase.deleting;
        case TypewriterPhase.deleting:
          _length = math.max(0, _length - 2); // briše hitreje, kot tipka
          if (_length == 0) _phase = TypewriterPhase.waiting;
        case TypewriterPhase.waiting:
          _index = (_index + 1) % widget.phrases.length;
          _phase = TypewriterPhase.typing;
      }
    });

    _scheduleFor(_phase);
  }

  Widget _line(String text, {TypewriterPhase? dotPhase}) {
    final dotSize = (widget.style.fontSize ?? 30) * 0.3;

    return Text.rich(
      TextSpan(
        text: text,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(left: dotSize * 0.6),
              child: dotPhase == null
                  ? SizedBox.square(dimension: dotSize)
                  : AnimatedDot(phase: dotPhase, size: dotSize),
            ),
          ),
        ],
      ),
      style: widget.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phrases.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: widget.phrases.first,
      header: true,
      child: ExcludeSemantics(
        child: Stack(
          children: [
            // Nevidne fraze rezervirajo višino najdaljše med njimi.
            for (final phrase in widget.phrases)
              Visibility.maintain(visible: false, child: _line(phrase)),
            _line(_current.substring(0, _length), dotPhase: _phase),
          ],
        ),
      ),
    );
  }
}
