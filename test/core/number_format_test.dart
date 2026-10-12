import 'package:certmore/core/utils/number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slovenska množina', () {
    expect(questionCount(1), '1 vprašanje');
    expect(questionCount(2), '2 vprašanji');
    expect(questionCount(3), '3 vprašanja');
    expect(questionCount(4), '4 vprašanja');
    expect(questionCount(5), '5 vprašanj');
    expect(questionCount(11), '11 vprašanj');
    expect(questionCount(101), '101 vprašanje');
    expect(questionCount(0), '0 vprašanj');
  });

  test('odstotek s presledkom', () {
    expect(formatPercent(2 / 3), '67 %');
    expect(formatPercent(1), '100 %');
  });
}
