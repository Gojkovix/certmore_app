import 'package:certmore/features/practice/presentation/widgets/answer_option.dart';
import 'package:certmore/features/progress/presentation/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

Future<void> _openTopic(WidgetTester tester, String title) async {
  await tester.tap(find.text('Vaja'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

/// Odgovori na vsa vprašanja z odgovorom A.
Future<void> _answerAll(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pump();
    await tester.tap(find.text('Preveri odgovor'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(RegExp(r'^(Pravilno!|Ni povsem pravilno\.)$')),
      findsOneWidget,
    );
    await tester.tap(
      find.text(i == count - 1 ? 'Poglej rezultat' : 'Naslednje vprašanje'),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('nov uporabnik vidi prvo vajo in prazen napredek', (
    tester,
  ) async {
    await pumpApp(tester, storage: await signedInStorage(tester));

    expect(find.text('Začni prvo vajo'), findsOneWidget);
    expect(find.text('Tvoj napredek'), findsNothing);

    await tester.tap(find.text('Napredek'));
    await tester.pumpAndSettle();
    expect(find.text('Tukaj boš videl, kako napreduješ.'), findsOneWidget);
  });

  testWidgets('vaja po temi se zabeleži v napredek', (tester) async {
    await pumpApp(tester, storage: await signedInStorage(tester));
    await _openTopic(tester, 'Slovenski jezik');

    expect(find.text('1 / 3'), findsOneWidget);
    // Gumb "Preveri odgovor" je onemogočen, dokler ni izbire.
    final check = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Preveri odgovor'),
        matching: find.byType(InkWell),
      ),
    );
    expect(check.onTap, isNull);

    await _answerAll(tester, 3);
    expect(find.text('pravilnih odgovorov'), findsOneWidget);

    await tester.tap(find.text('Končaj'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Napredek'));
    await tester.pumpAndSettle();
    expect(find.text('Zadnjih 7 dni'), findsOneWidget);
    // Seznam je len (ListView), zato se do razdelka najprej pomaknemo.
    await tester.scrollUntilVisible(
      find.text('Zadnje vaje'),
      200,
      scrollable: find.descendant(
        of: find.byType(ProgressScreen),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Zadnje vaje'), findsOneWidget);

    await tester.tap(find.text('Domov'));
    await tester.pumpAndSettle();
    expect(find.text('Tvoj napredek'), findsOneWidget);
    expect(find.text('Začni prvo vajo'), findsNothing);
  });

  testWidgets('prekinjena vaja se ne shrani', (tester) async {
    await pumpApp(tester, storage: await signedInStorage(tester));
    await _openTopic(tester, 'Slovenski jezik');

    await tester.tap(find.byType(AnswerOption).first);
    await tester.pump();
    await tester.tap(find.byTooltip('Zapri vajo'));
    await tester.pumpAndSettle();
    expect(find.text('Prekineš vajo?'), findsOneWidget);

    await tester.tap(find.text('Prekini'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Domov'));
    await tester.pumpAndSettle();
    expect(find.text('Začni prvo vajo'), findsOneWidget);
  });
}
