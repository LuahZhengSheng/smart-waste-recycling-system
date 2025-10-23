import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterUtils {
  DateFilterUtils._();

  /// Format date range for display
  static String formatDateRange(DateTimeRange dateRange, bool isToday) {
    if (isToday) {
      return DateFormat('dd MMM yyyy').format(dateRange.start);
    }

    return '${DateFormat('dd MMM yy').format(dateRange.start)} - ${DateFormat('dd MMM yy').format(dateRange.end)}';
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  /// Format time
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${DateFormat('dd MMM yyyy').format(dateTime)} • ${formatTime(dateTime)}';
  }
}