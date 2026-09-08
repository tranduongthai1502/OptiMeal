import 'package:intl/intl.dart';

/// Utilities for formatting dates, time windows, and countdowns.
class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime dateTime) => _dateFormat.format(dateTime);

  static String formatTime(DateTime dateTime) => _timeFormat.format(dateTime);

  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime);

  /// Formats a pickup window e.g. "16:00 - 18:30, 25/10/2026"
  static String formatPickupWindow(DateTime start, DateTime end) {
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return '${formatTime(start)} - ${formatTime(end)}, ${formatDate(start)}';
    }
    return '${formatDateTime(start)} - ${formatDateTime(end)}';
  }

  /// Formats remaining duration into MM:SS (e.g. 19:45)
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
