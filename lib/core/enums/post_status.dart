import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum PostStatus {
  draft,      // مسودة
  published,  // منشور
  archived,   // مؤرشف
  deleted;    // محذوف

  String get displayName {
    switch (this) {
      case PostStatus.draft:
        return 'مسودة';
      case PostStatus.published:
        return 'منشور';
      case PostStatus.archived:
        return 'مؤرشف';
      case PostStatus.deleted:
        return 'محذوف';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case PostStatus.draft:
        return 'Draft';
      case PostStatus.published:
        return 'Published';
      case PostStatus.archived:
        return 'Archived';
      case PostStatus.deleted:
        return 'Deleted';
    }
  }

  Color get color {
    switch (this) {
      case PostStatus.draft:
        return AppColors.warning;
      case PostStatus.published:
        return AppColors.success;
      case PostStatus.archived:
        return AppColors.mutedForeground;
      case PostStatus.deleted:
        return AppColors.destructive;
    }
  }

  IconData get icon {
    switch (this) {
      case PostStatus.draft:
        return Icons.edit_outlined;
      case PostStatus.published:
        return Icons.public_rounded;
      case PostStatus.archived:
        return Icons.archive_outlined;
      case PostStatus.deleted:
        return Icons.delete_outline_rounded;
    }
  }

  bool get isDraft => this == PostStatus.draft;
  bool get isPublished => this == PostStatus.published;
  bool get isArchived => this == PostStatus.archived;
  bool get isDeleted => this == PostStatus.deleted;

  static PostStatus fromString(String value) {
    return PostStatus.values.firstWhere(
          (status) => status.name == value.toLowerCase(),
      orElse: () => PostStatus.published,
    );
  }
}