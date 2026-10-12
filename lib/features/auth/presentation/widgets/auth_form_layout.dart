import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/pill_button.dart';

/// Skupna postavitev za registracijo in prijavo: naslov, kratek opis,
/// polja, eno glavno dejanje in sekundarna povezava.
///
/// Polja se pomikajo, glavni gumb pa je pritrjen spodaj, zato pri odprti
/// tipkovnici nikoli ne izgine pod njo.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.primaryLabel,
    required this.onPrimary,
    required this.loading,
    required this.secondary,
    this.error,
    this.showDemoNotice = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool loading;
  final Widget secondary;
  final String? error;
  final bool showDemoNotice;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    // Obrazec se pomika, dejanja pa so pritrjena spodaj — ko se odpre
    // tipkovnica, se Scaffold skrči in gumb ostane tik nad njo.
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xs,
                  AppSpacing.page,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        // Ikona poravnana z robom besedila.
                        offset: const Offset(-AppSpacing.sm, 0),
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          tooltip: 'Nazaj',
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Semantics(
                      header: true,
                      child: Text(title, style: AppTypography.headline),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTypography.bodySecondary),
                    const SizedBox(height: AppSpacing.xxl),
                    for (final (i, field) in fields.indexed) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.lg),
                      field,
                    ],
                    AnimatedSize(
                      duration: AppMotion.selection,
                      curve: AppMotion.standard,
                      alignment: Alignment.topCenter,
                      child: error == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.lg,
                              ),
                              child: _FormError(message: error),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xs,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PillButton(
                    label: primaryLabel,
                    onPressed: onPrimary,
                    loading: loading,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  secondary,
                  if (showDemoNotice && !keyboardOpen) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const _DemoNotice(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Napaka iz strežnika (npr. napačno geslo). Ikona in besedilo poskrbita,
/// da napaka ni izražena samo z barvo.
class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pošteno sporočilo, da gre za lokalni demo, dokler API ni povezan.
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Demo način: račun je shranjen samo na tej napravi.',
      textAlign: TextAlign.center,
      style: AppTypography.caption,
    );
  }
}
