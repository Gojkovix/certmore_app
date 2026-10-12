import 'package:certmore/core/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 12, 9);

  test('dolg zapis datuma v rodilniku', () {
    expect(formatLongDate(DateTime(2027, 3, 14)), '14. marca 2027');
  });

  test('relativni dan', () {
    expect(formatRelativeDay(DateTime(2026, 10, 12, 23), now: now), 'Danes');
    expect(formatRelativeDay(DateTime(2026, 10, 11, 1), now: now), 'Včeraj');
    expect(
      formatRelativeDay(DateTime(2026, 10, 1), now: now),
      '1. oktobra 2026',
    );
  });

  test('daysBetween ne zgreši ob prestavitvi ure', () {
    // 29. 3. 2026 se ura v Sloveniji premakne naprej (dan ima 23 ur).
    expect(daysBetween(DateTime(2026, 3, 29), DateTime(2026, 3, 30)), 1);
    expect(daysBetween(DateTime(2026, 3, 28, 12), DateTime(2026, 3, 30)), 2);
    expect(daysBetween(DateTime(2026, 10, 12), DateTime(2026, 10, 10)), -2);
  });
}
