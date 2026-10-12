/// Slovenska množina ima štiri oblike, odvisne od zadnjih dveh števk:
/// 1 vprašanje, 2 vprašanji, 3 vprašanja, 5 vprašanj.
String pluralSl(
  int count, {
  required String one,
  required String two,
  required String few,
  required String many,
}) {
  final form = switch (count.abs() % 100) {
    1 => one,
    2 => two,
    3 || 4 => few,
    _ => many,
  };
  return '$count $form';
}

String questionCount(int count) => pluralSl(
  count,
  one: 'vprašanje',
  two: 'vprašanji',
  few: 'vprašanja',
  many: 'vprašanj',
);

/// Delež (0–1) kot odstotek po slovenskem pravopisu: "67 %".
String formatPercent(double ratio) => '${(ratio * 100).round()} %';
