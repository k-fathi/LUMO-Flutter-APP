import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  // Format date to display format (dd/MM/yyyy)
  static String formatDate(DateTime date, {bool isArabic = true}) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  // Format time to display format (hh:mm a)
  static String formatTime(DateTime date, {bool isArabic = true}) {
    final formatter = DateFormat('hh:mm a');
    final time = formatter.format(date);

    if (isArabic) {
      return time.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    }

    return time;
  }

  // Format date and time (dd/MM/yyyy hh:mm a)
  static String formatDateTime(DateTime date, {bool isArabic = true}) {
    return '${formatDate(date, isArabic: isArabic)} ${formatTime(date, isArabic: isArabic)}';
  }

  // Format relative time (e.g., "منذ 5 دقائق", "منذ ساعة")
  static String formatRelativeTime(DateTime date, {bool isArabic = true}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return isArabic ? 'الآن' : 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      if (isArabic) {
        return 'منذ $minutes ${_getArabicMinutesWord(minutes)}';
      } else {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      }
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (isArabic) {
        return 'منذ $hours ${_getArabicHoursWord(hours)}';
      } else {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (isArabic) {
        return 'منذ $days ${_getArabicDaysWord(days)}';
      } else {
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      }
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      if (isArabic) {
        return 'منذ $weeks ${_getArabicWeeksWord(weeks)}';
      } else {
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      }
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      if (isArabic) {
        return 'منذ $months ${_getArabicMonthsWord(months)}';
      } else {
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      }
    } else {
      final years = (difference.inDays / 365).floor();
      if (isArabic) {
        return 'منذ $years ${_getArabicYearsWord(years)}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    }
  }

  // Format for chat messages (show time if today, date if older)
  static String formatChatTime(DateTime date, {bool isArabic = true}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Same day - show time only
      return formatTime(date, isArabic: isArabic);
    } else if (difference.inDays == 1) {
      // Yesterday
      return isArabic ? 'أمس' : 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      final formatter = DateFormat('EEEE');
      final dayName = formatter.format(date);
      return isArabic ? _getArabicDayName(date.weekday) : dayName;
    } else {
      // Older - show date
      return formatDate(date, isArabic: isArabic);
    }
  }

  // Format for analysis timestamp
  static String formatAnalysisTime(DateTime date, {bool isArabic = true}) {
    return formatDateTime(date, isArabic: isArabic);
  }

  // Format for post timestamp
  static String formatPostTime(DateTime date, {bool isArabic = true}) {
    return formatRelativeTime(date, isArabic: isArabic);
  }

  // Format month and year (e.g., "يناير 2024")
  static String formatMonthYear(DateTime date, {bool isArabic = true}) {
    if (isArabic) {
      return '${_getArabicMonthName(date.month)} ${date.year}';
    } else {
      final formatter = DateFormat('MMMM yyyy');
      return formatter.format(date);
    }
  }

  // Format day and month (e.g., "15 يناير")
  static String formatDayMonth(DateTime date, {bool isArabic = true}) {
    if (isArabic) {
      return '${date.day} ${_getArabicMonthName(date.month)}';
    } else {
      final formatter = DateFormat('d MMMM');
      return formatter.format(date);
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays < 7 && difference.inDays >= 0;
  }

  // Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Helper methods for Arabic plurals
  static String _getArabicMinutesWord(int count) {
    if (count == 1) return 'دقيقة';
    if (count == 2) return 'دقيقتان';
    if (count >= 3 && count <= 10) return 'دقائق';
    return 'دقيقة';
  }

  static String _getArabicHoursWord(int count) {
    if (count == 1) return 'ساعة';
    if (count == 2) return 'ساعتان';
    if (count >= 3 && count <= 10) return 'ساعات';
    return 'ساعة';
  }

  static String _getArabicDaysWord(int count) {
    if (count == 1) return 'يوم';
    if (count == 2) return 'يومان';
    if (count >= 3 && count <= 10) return 'أيام';
    return 'يوم';
  }

  static String _getArabicWeeksWord(int count) {
    if (count == 1) return 'أسبوع';
    if (count == 2) return 'أسبوعان';
    if (count >= 3 && count <= 10) return 'أسابيع';
    return 'أسبوع';
  }

  static String _getArabicMonthsWord(int count) {
    if (count == 1) return 'شهر';
    if (count == 2) return 'شهران';
    if (count >= 3 && count <= 10) return 'أشهر';
    return 'شهر';
  }

  static String _getArabicYearsWord(int count) {
    if (count == 1) return 'سنة';
    if (count == 2) return 'سنتان';
    if (count >= 3 && count <= 10) return 'سنوات';
    return 'سنة';
  }

  static String _getArabicMonthName(int month) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return arabicMonths[month - 1];
  }

  static String _getArabicDayName(int weekday) {
    const arabicDays = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    return arabicDays[weekday - 1];
  }
}