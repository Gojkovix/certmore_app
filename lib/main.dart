import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const CertmoreApp());

// barve
const _navy = Color(0xFF0D2638);
const _teal = Color(0xFF16A394);
const _background = Color(0xFFF8FCFB);
const _soft = Color(0xFFE9F4F1);
const _muted = Color(0xFF7A9994);

class CertmoreApp extends StatelessWidget {
  const CertmoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certmore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.light(
          primary: _navy,
          secondary: _teal,
          surface: _background,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ZGORNJI DEL – LOGOTIP
              const Expanded(flex: 5, child: SizedBox()),

              Center(
                child: SvgPicture.asset(
                  'assets/images/certmore_logo.svg',
                  width: 260,
                ),
              ),

              // PROSTOR MED LOGOTIPOM IN NAPISOM
              const Spacer(flex: 6),

              // SPODNJI DEL – NASLOV
              const Text(
                'Priprava na strokovni izpit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _teal,
                ),
              ),

              const SizedBox(height: 12),

              const _Typewriter(
                phrases: [
                  'Tvoje znanje. Preverjeno.',
                  'Vadi na izpitnih vprašanjih.',
                  'Razumi, zakaj je odgovor pravilen.',
                  'Uči se v svojem tempu.',
                ],
              ),

              const SizedBox(height: 36),

              // GLAVNI GUMB
              _PillButton(
                label: 'Začnimo',
                background: _navy,
                foreground: Colors.white,
                onPressed: () {},
              ),

              const SizedBox(height: 10),

              // PRIJAVA
              _PillButton(
                label: 'Prijava',
                background: _soft,
                foreground: _navy,
                onPressed: () {},
              ),

              const SizedBox(height: 18),

              const Text(
                'Z nadaljevanjem se strinjaš s pogoji uporabe.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

// tipkanje naslova, podobno kot pri chatgpt
class _Typewriter extends StatefulWidget {
  const _Typewriter({required this.phrases});

  final List<String> phrases;

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  static const _tick = Duration(milliseconds: 45);

  Timer? _timer;
  int _phrase = 0;
  int _chars = 0;
  int _hold = 0; // pavza v tickih
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tick, (_) => _step());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _step() {
    if (_hold > 0) {
      _hold--;
      return;
    }

    final full = widget.phrases[_phrase];
    setState(() {
      if (!_deleting) {
        if (_chars < full.length) {
          _chars++;
        } else {
          _deleting = true;
          _hold = 65;
        }
      } else if (_chars > 0) {
        _chars = max(0, _chars - 2); // briše hitreje kot tipka
      } else {
        _deleting = false;
        _phrase = (_phrase + 1) % widget.phrases.length;
        _hold = 6;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.phrases[_phrase].substring(0, _chars);

    // fiksna visina, drugace gumbi skacejo
    return SizedBox(
      height: 120,
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 5),
                decoration: const BoxDecoration(
                  color: _teal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        style: const TextStyle(
          fontSize: 30,
          height: 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: _navy,
        ),
      ),
    );
  }
}
