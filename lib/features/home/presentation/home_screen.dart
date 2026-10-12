import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// ZAČASNO: minimalen Domov, da lahko preizkusimo prijavo in obnovo seje.
/// Celoten zaslon (z navigacijo in vsebino) pride v naslednjem koraku.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String greeting(DateTime now) => switch (now.hour) {
    >= 5 && < 10 => 'Dobro jutro',
    >= 10 && < 18 => 'Dober dan',
    _ => 'Dober večer',
  };

  Future<void> _signOut(BuildContext context) async {
    await AppScope.of(context).auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).auth.user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xxxl,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greeting(DateTime.now())}, ${user?.firstName ?? ''}.',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Pripravljen na naslednji korak?',
                style: AppTypography.bodySecondary,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _signOut(context),
                child: const Text('Odjava'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
