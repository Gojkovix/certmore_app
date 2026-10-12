import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/pill_button.dart';
import 'widgets/typewriter_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _phrases = [
    'Tvoje znanje. Preverjeno.',
    'Vadi na izpitnih vprašanjih.',
    'Razumi, zakaj je odgovor pravilen.',
    'Uči se v svojem tempu.',
  ];

  @override
  Widget build(BuildContext context) {
    final logoWidth = (MediaQuery.sizeOf(context).width * 0.62).clamp(
      180.0,
      260.0,
    );

    return Scaffold(
      body: SafeArea(
        // SliverFillRemaining razporedi vsebino čez cel zaslon, na majhnih
        // zaslonih ali pri veliki pisavi pa omogoči pomikanje.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 5),
                    Center(
                      child: Semantics(
                        label: 'Certmore',
                        image: true,
                        child: SvgPicture.asset(
                          'assets/images/certmore_logo.svg',
                          width: logoWidth,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    const Spacer(flex: 6),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Priprava na strokovni izpit',
                      style: AppTypography.label.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const TypewriterText(
                      phrases: _phrases,
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PillButton(
                      label: 'Začnimo',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.onboarding),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PillButton.secondary(
                      label: 'Prijava',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.login),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Z nadaljevanjem se strinjaš s pogoji uporabe.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
