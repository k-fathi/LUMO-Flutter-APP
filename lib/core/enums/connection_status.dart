import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ConnectionStatus {
  pending,    // قيد الانتظار
  accepted,   // مقبول
  rejected;   // مرفوض

  String get displayName {
    switch (this) {
      case ConnectionStatus.pending:
        return 'قيد الانتظار';
      case ConnectionStatus.accepted:
        return 'مقبول';
      case ConnectionStatus.rejected:
        return 'مرفوض';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case ConnectionStatus.pending:
        return 'Pending';
      case ConnectionStatus.accepted:
        return 'Accepted';
      case ConnectionStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ConnectionStatus.pending:
        return AppColors.warning;
      case ConnectionStatus.accepted:
        return AppColors.success;
      case ConnectionStatus.rejected:
        return AppColors.destructive;
    }
  }

  IconData get icon {
    switch (this) {
      case ConnectionStatus.pending:
        return Icons.schedule_rounded;
      case ConnectionStatus.accepted:
        return Icons.check_circle_rounded;
      case ConnectionStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  bool get isPending => this == ConnectionStatus.pending;
  bool get isAccepted => this == ConnectionStatus.accepted;
  bool get isRejected => this == ConnectionStatus.rejected;

  static ConnectionStatus fromString(String value) {
    return ConnectionStatus.values.firstWhere(
          (status) => status.name == value.toLowerCase(),
      orElse: () => ConnectionStatus.pending,
    );
  }
}