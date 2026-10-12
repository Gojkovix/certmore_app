import 'package:flutter/material.dart';

import '../../core/widgets/glass_nav_bar.dart';
import '../home/presentation/home_screen.dart';
import '../practice/presentation/practice_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../progress/presentation/progress_screen.dart';

/// Glavni del aplikacije po prijavi: štirje zavihki in steklena
/// navigacija.
///
/// IndexedStack ohrani stanje vseh zavihkov (npr. položaj pomika),
/// ko uporabnik preklaplja med njimi.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _items = [
    GlassNavItem(
      label: 'Domov',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    GlassNavItem(
      label: 'Vaja',
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note_rounded,
    ),
    GlassNavItem(
      label: 'Napredek',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
    GlassNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sistemski "nazaj" z drugih zavihkov najprej vrne na Domov.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        // Vsebina se izriše pod navigacijo, da je steklen učinek viden.
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              PracticeScreen(),
              ProgressScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: GlassNavBar(
          items: _items,
          selectedIndex: _index,
          onSelected: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}
