import 'package:flutter/material.dart';

/// Izbira datuma izpita (onboarding in Profil). Možni so datumi od
/// danes do treh let naprej.
Future<DateTime?> showExamDatePicker(
  BuildContext context, {
  DateTime? current,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  // Pretekel datum (izpit je že mimo) ne sme biti začetna izbira,
  // ker mora biti initialDate med firstDate in lastDate.
  final initial = current != null && !current.isBefore(today)
      ? current
      : today.add(const Duration(days: 30));

  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: today,
    lastDate: DateTime(today.year + 3, today.month, today.day),
    helpText: 'Datum izpita',
  );
}
