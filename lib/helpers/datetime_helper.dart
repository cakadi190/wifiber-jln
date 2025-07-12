import 'package:intl/intl.dart';

/// Utility class for handling common DateTime operations.
class DateHelper {
  /// Nama bulan dalam Bahasa Indonesia.
  static const List<String> _monthsIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  /// Nama bulan singkat dalam Bahasa Indonesia.
  static const List<String> _monthsShortIndo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Nama hari dalam Bahasa Indonesia.
  static const List<String> _daysIndo = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

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
  /// Default pattern is `'dd-MM-yyyy'` (Indonesian format).
  static String format(DateTime date, {String pattern = 'dd-MM-yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Formats the current date and time using the given [pattern].
  ///
  /// Default pattern is `'dd-MM-yyyy HH:mm:ss'`.
  static String formatNow({String pattern = 'dd-MM-yyyy HH:mm:ss'}) {
    return DateFormat(pattern).format(DateTime.now());
  }

  /// Formats a [DateTime] object into a date string with common formats.
  ///
  /// Available formats:
  /// - `short`: dd/MM/yyyy
  /// - `medium`: dd MMM yyyy
  /// - `long`: dd MMMM yyyy
  /// - `full`: EEEE, dd MMMM yyyy
  static String formatDate(DateTime date, {String format = 'medium'}) {
    switch (format.toLowerCase()) {
      case 'short':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'medium':
        return '${date.day} ${_monthsShortIndo[date.month - 1]} ${date.year}';
      case 'long':
        return '${date.day} ${_monthsIndo[date.month - 1]} ${date.year}';
      case 'full':
        return '${_daysIndo[date.weekday - 1]}, ${date.day} ${_monthsIndo[date.month - 1]} ${date.year}';
      default:
        return '${date.day} ${_monthsShortIndo[date.month - 1]} ${date.year}';
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
  /// - `short`: dd/MM/yyyy HH:mm
  /// - `medium`: dd MMM yyyy HH:mm:ss
  /// - `long`: dd MMMM yyyy HH:mm:ss.SSS
  /// - `full`: EEEE, dd MMMM yyyy HH:mm:ss
  /// - `iso`: yyyy-MM-ddTHH:mm:ss.SSSZ
  static String formatDateTime(DateTime date, {String format = 'medium'}) {
    switch (format.toLowerCase()) {
      case 'short':
        return '${formatDate(date, format: 'short')} ${formatTime(date, format: 'short')}';
      case 'medium':
        return '${formatDate(date, format: 'medium')} ${formatTime(date, format: 'medium')}';
      case 'long':
        return '${formatDate(date, format: 'long')} ${formatTime(date, format: 'long')}';
      case 'full':
        return '${formatDate(date, format: 'full')} ${formatTime(date, format: 'medium')}';
      case 'iso':
        return date.toIso8601String();
      default:
        return '${formatDate(date, format: 'medium')} ${formatTime(date, format: 'medium')}';
    }
  }

  /// Formats the current date and time into a complete date-time string.
  ///
  /// Uses the same format options as [formatDateTime].
  static String formatCurrentDateTime({String format = 'medium'}) {
    return formatDateTime(DateTime.now(), format: format);
  }

  /// Formats a [DateTime] object into a relative time string (e.g., "2 jam yang lalu").
  ///
  /// For times within the last minute, returns "baru saja".
  /// For times within the last hour, returns minutes ago.
  /// For times within the last day, returns hours ago.
  /// For times within the last week, returns days ago.
  /// Otherwise, returns the formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
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