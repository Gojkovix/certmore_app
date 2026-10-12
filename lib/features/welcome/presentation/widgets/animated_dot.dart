import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Faze typewriter animacije, na katere se odziva pika.
enum TypewriterPhase { typing, holding, deleting, waiting }

/// Majhna teal pika na koncu tipkanega besedila.
///
/// - med tipkanjem rahlo "diha",
/// - ob končani frazi enkrat zadržano utripne (z mehkim obročem),
/// - med brisanjem se nekoliko skrči in umiri.
///
/// Namenoma nima neprekinjenega vrtenja ali utripanja v mirovanju,
/// da ne deluje kot indikator nalaganja.
class AnimatedDot extends StatefulWidget {
  const AnimatedDot({
    super.key,
    required this.phase,
    this.size = 9,
    this.color = AppColors.teal,
  });

  final TypewriterPhase phase;
  final double size;
  final Color color;

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _applyPhase(widget.phase, previous: null);
  }

  @override
  void didUpdateWidget(AnimatedDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _applyPhase(widget.phase, previous: oldWidget.phase);
    }
  }

  void _applyPhase(TypewriterPhase phase, {TypewriterPhase? previous}) {
    if (phase == TypewriterPhase.typing) {
      _breath.repeat(reverse: true);
    } else {
      _breath.animateBack(0, duration: const Duration(milliseconds: 200));
    }
    if (phase == TypewriterPhase.holding &&
        previous == TypewriterPhase.typing) {
      _settle.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final dot = DecoratedBox(
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return SizedBox.square(dimension: size, child: dot);
    }

    final receding = widget.phase == TypewriterPhase.deleting ||
        widget.phase == TypewriterPhase.waiting;

    return SizedBox.square(
      dimension: size,
      child: AnimatedOpacity(
        opacity: receding ? 0.6 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: receding ? 0.78 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedBuilder(
            animation: Listenable.merge([_breath, _settle]),
            builder: (context, child) {
              final breath = Curves.easeInOut.transform(_breath.value);
              final settle = _settle.value;
              final settleCurve = Curves.easeOutCubic.transform(settle);
              final active = _settle.isAnimating;

              final dotScale =
                  (1 + 0.1 * breath) * (1 + 0.2 * math.sin(math.pi * settle));

              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  if (active)
                    Transform.scale(
                      scale: 1 + 1.6 * settleCurve,
                      child: Opacity(
                        opacity: 0.28 * (1 - settleCurve),
                        child: child,
                      ),
                    ),
                  Transform.scale(scale: dotScale, child: child),
                ],
              );
            },
            child: dot,
          ),
        ),
      ),
    );
  }
}
