import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ChildState {
  critical,    // Red - حرج
  bad,         // Orange - سيء
  moderate,    // Yellow - متوسط
  good,        // Green - جيد
  excellent;   // Dark Green - ممتاز

  String get displayName {
    switch (this) {
      case ChildState.critical:
        return 'حرج';
      case ChildState.bad:
        return 'سيء';
      case ChildState.moderate:
        return 'متوسط';
      case ChildState.good:
        return 'جيد';
      case ChildState.excellent:
        return 'ممتاز';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case ChildState.critical:
        return 'Critical';
      case ChildState.bad:
        return 'Bad';
      case ChildState.moderate:
        return 'Moderate';
      case ChildState.good:
        return 'Good';
      case ChildState.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (this) {
      case ChildState.critical:
        return AppColors.statusCritical;
      case ChildState.bad:
        return AppColors.statusBad;
      case ChildState.moderate:
        return AppColors.statusModerate;
      case ChildState.good:
        return AppColors.statusGood;
      case ChildState.excellent:
        return AppColors.statusExcellent;
    }
  }

  IconData get icon {
    switch (this) {
      case ChildState.critical:
        return Icons.warning_amber_rounded;
      case ChildState.bad:
        return Icons.sentiment_dissatisfied_rounded;
      case ChildState.moderate:
        return Icons.sentiment_neutral_rounded;
      case ChildState.good:
        return Icons.sentiment_satisfied_rounded;
      case ChildState.excellent:
        return Icons.sentiment_very_satisfied_rounded;
    }
  }

  String get description {
    switch (this) {
      case ChildState.critical:
        return 'الحالة حرجة وتحتاج متابعة فورية';
      case ChildState.bad:
        return 'الحالة سيئة وتحتاج رعاية طبية';
      case ChildState.moderate:
        return 'الحالة متوسطة وتحتاج مراقبة';
      case ChildState.good:
        return 'الحالة جيدة ومستقرة';
      case ChildState.excellent:
        return 'الحالة ممتازة ومستقرة جداً';
    }
  }

  int get priority {
    switch (this) {
      case ChildState.critical:
        return 5;
      case ChildState.bad:
        return 4;
      case ChildState.moderate:
        return 3;
      case ChildState.good:
        return 2;
      case ChildState.excellent:
        return 1;
    }
  }

  static ChildState fromString(String value) {
    return ChildState.values.firstWhere(
          (state) => state.name == value.toLowerCase(),
      orElse: () => ChildState.moderate,
    );
  }

  static ChildState fromPriority(int priority) {
    switch (priority) {
      case 5:
        return ChildState.critical;
      case 4:
        return ChildState.bad;
      case 3:
        return ChildState.moderate;
      case 2:
        return ChildState.good;
      case 1:
        return ChildState.excellent;
      default:
        return ChildState.moderate;
    }
  }
}