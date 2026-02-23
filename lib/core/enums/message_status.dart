import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum MessageStatus {
  sending,    // جاري الإرسال
  sent,       // تم الإرسال
  delivered,  // تم التسليم
  read,       // تمت القراءة
  failed;     // فشل الإرسال

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'جاري الإرسال';
      case MessageStatus.sent:
        return 'تم الإرسال';
      case MessageStatus.delivered:
        return 'تم التسليم';
      case MessageStatus.read:
        return 'تمت القراءة';
      case MessageStatus.failed:
        return 'فشل الإرسال';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.schedule_rounded;
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.read:
        return Icons.done_all_rounded;
      case MessageStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case MessageStatus.sending:
        return AppColors.mutedForeground;
      case MessageStatus.sent:
        return AppColors.mutedForeground;
      case MessageStatus.delivered:
        return AppColors.mutedForeground;
      case MessageStatus.read:
        return AppColors.primary;
      case MessageStatus.failed:
        return AppColors.destructive;
    }
  }

  bool get isSending => this == MessageStatus.sending;
  bool get isSent => this == MessageStatus.sent;
  bool get isDelivered => this == MessageStatus.delivered;
  bool get isRead => this == MessageStatus.read;
  bool get isFailed => this == MessageStatus.failed;

  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
          (status) => status.name == value.toLowerCase(),
      orElse: () => MessageStatus.sent,
    );
  }
}