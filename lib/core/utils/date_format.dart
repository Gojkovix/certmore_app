const _monthsGenitive = [
  'januarja',
  'februarja',
  'marca',
  'aprila',
  'maja',
  'junija',
  'julija',
  'avgusta',
  'septembra',
  'oktobra',
  'novembra',
  'decembra',
];

/// Slovenski zapis datuma, npr. "14. marca 2027".
String formatLongDate(DateTime date) =>
    '${date.day}. ${_monthsGenitive[date.month - 1]} ${date.year}';
