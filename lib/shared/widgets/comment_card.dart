import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/comment_model.dart';
import 'package:intl/intl.dart' show Bidi;
import 'avatar_widget.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50], // surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!), // border color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                imageUrl: comment.userAvatarUrl,
                name: comment.userName,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelativeTime(comment.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.destructive,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              comment.content,
              style: AppTextStyles.body,
              textDirection: Bidi.detectRtlDirectionality(comment.content)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              textAlign: Bidi.detectRtlDirectionality(comment.content)
                  ? TextAlign.right
                  : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
