import 'package:flutter/material.dart';

/// Reward Transaction Type Enum
enum TransactionType {
  earning,
  spending;

  String get displayName {
    switch (this) {
      case TransactionType.earning:
        return 'Earning';
      case TransactionType.spending:
        return 'Spending';
    }
  }
}

/// Date Filter Type Enum
enum DateFilterType {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom;

  String get displayName {
    switch (this) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last30Days:
        return 'Last 30 Days';
      case DateFilterType.custom:
        return 'Custom Range';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateFilterType.today:
        return DateTimeRange(
          start: today,
          end: now,
        );
      case DateFilterType.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: today,
        );
      case DateFilterType.last7Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: now,
        );
      case DateFilterType.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
      case DateFilterType.custom:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
    }
  }
}