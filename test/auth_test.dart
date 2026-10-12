import 'dart:convert';

import 'package:certmore/features/onboarding/presentation/widgets/selection_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

/// Odgovori, s katerimi so vsi koraki onboardinga že izpolnjeni.
final _answeredOnboarding = {
  'onboarding.answers': jsonEncode({
    'discovery': 'google',
    'goal': 'starting',
    'examTiming': 'unknown',
    'knowledge': 'some',
  }),
};

/// Trenutna vsebina lažne hrambe — za simulacijo ponovnega zagona.
Future<Map<String, Object>> _storageSnapshot() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final key in prefs.getKeys()) key: prefs.get(key)!};
}

Future<void> _openRegistration(WidgetTester tester) async {
  await tester.tap(find.text('Začnimo'));
  await tester.pumpAndSettle();
  for (var i = 0; i < 4; i++) {
    await tester.tap(find.text('Nadaljuj'));
    await tester.pumpAndSettle();
  }
}

/// Odjava gre prek zavihka Profil in potrditvenega okna.
Future<void> _signOut(WidgetTester tester) async {
  await tester.tap(find.text('Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Odjava'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Odjava').last);
  await tester.pumpAndSettle();
}

Future<void> _register(WidgetTester tester) async {
  await tester.enterText(find.bySemanticsLabel('Ime'), 'Ana Novak');
  await tester.enterText(
    find.bySemanticsLabel('E-poštni naslov'),
    'Ana@Primer.si ',
  );
  await tester.enterText(find.bySemanticsLabel('Geslo'), 'varno-geslo');
  await tester.tap(find.widgetWithText(InkWell, 'Ustvari račun'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding obnovi shranjene odgovore', (tester) async {
    await pumpApp(tester, storage: _answeredOnboarding);
    await tester.tap(find.text('Začnimo'));
    await tester.pumpAndSettle();

    final google = tester.widget<SelectionOption>(
      find.widgetWithText(SelectionOption, 'Google'),
    );
    expect(google.selected, isTrue);
  });

  testWidgets('registracija pokaže napake pri praznih poljih', (tester) async {
    await pumpApp(tester, storage: _answeredOnboarding);
    await _openRegistration(tester);

    await tester.tap(find.widgetWithText(InkWell, 'Ustvari račun'));
    await tester.pump();

    expect(find.text('Vpiši svoje ime.'), findsOneWidget);
    expect(find.text('Vpiši e-poštni naslov.'), findsOneWidget);
    expect(find.text('Vpiši geslo.'), findsOneWidget);
  });

  testWidgets('registracija vodi na Domov, seja preživi ponovni zagon', (
    tester,
  ) async {
    await pumpApp(tester, storage: _answeredOnboarding);
    await _openRegistration(tester);
    await _register(tester);

    expect(find.textContaining(', Ana.'), findsOneWidget);

    // Gesla ni nikjer v hrambi v izvirni obliki.
    final storage = await _storageSnapshot();
    expect(storage.values.join(), isNot(contains('varno-geslo')));

    await pumpApp(tester, storage: storage);
    expect(find.textContaining(', Ana.'), findsOneWidget);
    expect(find.text('Začnimo'), findsNothing);
  });

  testWidgets('napačno geslo pokaže sporočilo, pravilno prijavi', (
    tester,
  ) async {
    await pumpApp(tester, storage: _answeredOnboarding);
    await _openRegistration(tester);
    await _register(tester);

    await _signOut(tester);
    expect(find.text('Začnimo'), findsOneWidget);

    await tester.tap(find.text('Prijava'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.bySemanticsLabel('E-poštni naslov'),
      'ana@primer.si',
    );
    await tester.enterText(find.bySemanticsLabel('Geslo'), 'napacno-geslo');
    await tester.tap(find.widgetWithText(InkWell, 'Prijava'));
    await tester.pumpAndSettle();
    expect(find.text('E-poštni naslov ali geslo ni pravilno.'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Geslo'), 'varno-geslo');
    await tester.tap(find.widgetWithText(InkWell, 'Prijava'));
    await tester.pumpAndSettle();
    expect(find.textContaining(', Ana.'), findsOneWidget);
  });

  testWidgets('registracija z obstoječim e-naslovom je zavrnjena', (
    tester,
  ) async {
    await pumpApp(tester, storage: _answeredOnboarding);
    await _openRegistration(tester);
    await _register(tester);
    await _signOut(tester);

    await _openRegistration(tester);
    await _register(tester);
    expect(
      find.text('Račun s tem e-poštnim naslovom že obstaja.'),
      findsOneWidget,
    );
  });
}
