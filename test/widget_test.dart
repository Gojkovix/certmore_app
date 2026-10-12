import 'package:certmore/features/onboarding/presentation/widgets/selection_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

Finder _continueButton() =>
    find.ancestor(of: find.text('Nadaljuj'), matching: find.byType(InkWell));

bool _isEnabled(WidgetTester tester) =>
    tester.widget<InkWell>(_continueButton()).onTap != null;

void main() {
  testWidgets('welcome prikaže statično frazo in oba gumba', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Tvoje znanje. Preverjeno.'), findsWidgets);
    expect(find.text('Začnimo'), findsOneWidget);
    expect(find.text('Prijava'), findsOneWidget);
  });

  testWidgets('onboarding: izbira, napredovanje in ohranjanje odgovorov', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Začnimo'));
    await tester.pumpAndSettle();

    expect(find.text('Kako si izvedel za Certmore?'), findsOneWidget);
    expect(find.text('01 / 04'), findsOneWidget);
    expect(_isEnabled(tester), isFalse);

    await tester.tap(find.text('Google'));
    await tester.pump();
    expect(_isEnabled(tester), isTrue);

    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();
    expect(find.text('Kaj želiš doseči?'), findsOneWidget);
    expect(_isEnabled(tester), isFalse);

    // Nazaj: prejšnja izbira mora ostati označena.
    await tester.tap(find.byTooltip('Nazaj'));
    await tester.pumpAndSettle();
    final google = tester.widget<SelectionOption>(
      find.widgetWithText(SelectionOption, 'Google'),
    );
    expect(google.selected, isTrue);
    expect(_isEnabled(tester), isTrue);

    // Celoten tok do registracije.
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Začenjam s pripravami.'));
    await tester.pump();
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();

    expect(find.text('Kdaj imaš strokovni izpit?'), findsOneWidget);
    await tester.tap(find.text('Datuma še ne poznam.'));
    await tester.pump();
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();

    expect(find.text('04 / 04'), findsOneWidget);
    await tester.tap(find.text('Nekaj že znam.'));
    await tester.pump();
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();

    expect(find.text('Že imaš račun? Prijava'), findsOneWidget);
  });

  testWidgets('sistemski nazaj vrača po korakih', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Začnimo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Instagram'));
    await tester.pump();
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Kako si izvedel za Certmore?'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Začnimo'), findsOneWidget);
  });

  testWidgets('majhen zaslon z veliko pisavo se ne prelije', (tester) async {
    tester.view.physicalSize = const Size(320, 568) * 2;
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Začnimo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Začnimo'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
