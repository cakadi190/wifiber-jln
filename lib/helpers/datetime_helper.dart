import 'package:intl/intl.dart';

/// Utility class for handling common DateTime operations.
class DateHelper {
  /// Returns the current date and time.
  static DateTime now() {
    return DateTime.now();
  }

  /// Parses a [date] string into a [DateTime] object.
  ///
  /// Throws a [FormatException] if the string is not valid.
  static DateTime parse(String date) {
    return DateTime.parse(date);
  }

  /// Formats a [DateTime] object into a string using the given [pattern].
  ///
  /// Default pattern is `'yyyy-MM-dd'`.
  static String format(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }

  /// Formats the current date and time using the given [pattern].
  ///
  /// Default pattern is `'yyyy-MM-dd HH:mm:ss'`.
  static String formatNow({String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(DateTime.now());
  }

  /// Formats a [DateTime] object into a date string with common formats.
  ///
  /// Available formats:
  /// - `short`: MM/dd/yyyy
  /// - `medium`: MMM dd, yyyy
  /// - `long`: MMMM dd, yyyy
  /// - `full`: EEEE, MMMM dd, yyyy
  static String formatDate(DateTime date, {String format = 'medium'}) {
    switch (format.toLowerCase()) {
      case 'short':
        return DateFormat('MM/dd/yyyy').format(date);
      case 'medium':
        return DateFormat('MMM dd, yyyy').format(date);
      case 'long':
        return DateFormat('MMMM dd, yyyy').format(date);
      case 'full':
        return DateFormat('EEEE, MMMM dd, yyyy').format(date);
      default:
        return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Formats a [DateTime] object into a time string with common formats.
  ///
  /// Available formats:
  /// - `short`: HH:mm
  /// - `medium`: HH:mm:ss
  /// - `long`: HH:mm:ss.SSS
  /// - `12hour`: h:mm a
  /// - `12hourSeconds`: h:mm:ss a
  static String formatTime(DateTime date, {String format = 'medium'}) {
    switch (format.toLowerCase()) {
      case 'short':
        return DateFormat('HH:mm').format(date);
      case 'medium':
        return DateFormat('HH:mm:ss').format(date);
      case 'long':
        return DateFormat('HH:mm:ss.SSS').format(date);
      case '12hour':
        return DateFormat('h:mm a').format(date);
      case '12hourseconds':
        return DateFormat('h:mm:ss a').format(date);
      default:
        return DateFormat('HH:mm:ss').format(date);
    }
  }

  /// Formats a [DateTime] object into a complete date-time string.
  ///
  /// Available formats:
  /// - `short`: MM/dd/yyyy HH:mm
  /// - `medium`: MMM dd, yyyy HH:mm:ss
  /// - `long`: MMMM dd, yyyy HH:mm:ss.SSS
  /// - `full`: EEEE, MMMM dd, yyyy HH:mm:ss
  /// - `iso`: yyyy-MM-ddTHH:mm:ss.SSSZ
  static String formatDateTime(DateTime date, {String format = 'medium'}) {
    switch (format.toLowerCase()) {
      case 'short':
        return DateFormat('MM/dd/yyyy HH:mm').format(date);
      case 'medium':
        return DateFormat('MMM dd, yyyy HH:mm:ss').format(date);
      case 'long':
        return DateFormat('MMMM dd, yyyy HH:mm:ss.SSS').format(date);
      case 'full':
        return DateFormat('EEEE, MMMM dd, yyyy HH:mm:ss').format(date);
      case 'iso':
        return date.toIso8601String();
      default:
        return DateFormat('MMM dd, yyyy HH:mm:ss').format(date);
    }
  }

  /// Formats the current date and time into a complete date-time string.
  ///
  /// Uses the same format options as [formatDateTime].
  static String formatCurrentDateTime({String format = 'medium'}) {
    return formatDateTime(DateTime.now(), format: format);
  }

  /// Formats a [DateTime] object into a relative time string (e.g., "2 hours ago").
  ///
  /// For times within the last minute, returns "just now".
  /// For times within the last hour, returns minutes ago.
  /// For times within the last day, returns hours ago.
  /// For times within the last week, returns days ago.
  /// Otherwise, returns the formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return formatDate(date);
    }
  }

  /// Checks if two [DateTime] objects fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns a new [DateTime] that is [days] days after the provided [date].
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Returns a new [DateTime] representing the start of the day (00:00:00.000).
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns a new [DateTime] representing the end of the day (23:59:59.999).
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Returns the number of full days between [from] and [to].
  ///
  /// Result can be negative if [from] is after [to].
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Returns true if the given [date] is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(now, date);
  }
}