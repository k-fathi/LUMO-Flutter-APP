import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Comment Input Widget - Pixel-perfect match to React CommentsScreen bottom input
///
/// React: sticky bottom-0 bg-white border-t border-[#E3F2FD] px-6 py-4
/// Avatar (w-9 h-9) + Input (rounded-full bg-[#E3F2FD]) + Send button (gradient rounded-full)
class CommentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final String? userAvatar;
  final String userName;

  const CommentInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.userAvatar,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // React: sticky bottom-0 bg-white border-t border-[#E3F2FD] px-6 py-4
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // React: Avatar w-9 h-9
            AvatarWidget(
              imageUrl: userAvatar,
              name: userName,
              size: 36,
            ),
            const SizedBox(width: 12),
            // React: flex-1 h-12 rounded-full border-[#E3F2FD] bg-[#E3F2FD] px-5
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: theme.colorScheme.surfaceContainerHighest),
                ),
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body
                      .copyWith(color: theme.textTheme.bodyLarge?.color),
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقاً...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: theme.hintColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // React: w-12 h-12 rounded-full bg-gradient-to-r from-[#2196F3] to-[#1565C0] shadow-lg
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: isLoading ? null : onSend,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
