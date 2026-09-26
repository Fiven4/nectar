import 'package:cloud_firestore/cloud_firestore.dart';

int toIntValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}

double toDoubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim().replaceAll(',', '.') ?? '') ?? 0;
}

String toStringValue(dynamic value) => value?.toString().trim() ?? '';

DateTime toDateTimeValue(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}

String formatDateTime(DateTime date) {
  return '${formatDate(date)} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
