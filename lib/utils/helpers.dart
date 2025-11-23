import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static DateTime getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime getDateStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isToday(DateTime date) {
    final today = getTodayStart();
    final targetDate = getDateStart(date);
    return today.isAtSameMomentAs(targetDate);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return getDateStart(date1).isAtSameMomentAs(getDateStart(date2));
  }
}

