import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Enotna postavitev zavihka: naslov in vsebina, ki se pomika.
///
/// Spodnji odmik upošteva steklen navigacijski trak (Scaffold z
/// `extendBody` ga prišteje k MediaQuery.padding), zato zadnji element
/// nikoli ne ostane skrit pod njim.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.children, this.title, this.subtitle});

  final String? title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final title = this.title;
    final subtitle = this.subtitle;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        MediaQuery.paddingOf(context).top + AppSpacing.xxl,
        AppSpacing.page,
        bottomInset + AppSpacing.xxl,
      ),
      children: [
        if (title != null)
          Semantics(
            header: true,
            child: Text(title, style: AppTypography.headline),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodySecondary),
        ],
        if (title != null || subtitle != null)
          const SizedBox(height: AppSpacing.xxl),
        ...children,
      ],
    );
  }
}

/// Naslov razdelka znotraj zavihka.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: AppTypography.cardTitle),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
