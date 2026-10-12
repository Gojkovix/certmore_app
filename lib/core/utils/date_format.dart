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

/// Število koledarskih dni od [from] do [to] (negativno, če je [to] prej).
///
/// Računamo v UTC, ker lokalni dan ob prestavitvi ure traja 23 ali 25 ur
/// in bi `difference().inDays` lahko vrnil napačen rezultat.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// "Danes", "Včeraj" ali datum, npr. "14. marca 2027".
String formatRelativeDay(DateTime date, {required DateTime now}) {
  return switch (daysBetween(date, now)) {
    0 => 'Danes',
    1 => 'Včeraj',
    _ => formatLongDate(date),
  };
}
