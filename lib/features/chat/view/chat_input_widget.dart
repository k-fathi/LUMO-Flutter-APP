import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Chat Input Widget - Matches React ChatScreen input area
///
/// React: bg-white border-t border-[#E3F2FD] px-6 py-4
/// Paperclip icon + rounded-full E3F2FD input + gradient send button
class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final bool isLoading;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // React: bg-white border-t border-[#E3F2FD] px-6 py-4
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE3F2FD)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // React: flex-1 h-12 rounded-full border-[#E3F2FD] bg-[#E3F2FD] px-5
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE3F2FD)),
                ),
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: const Color(0xFF64748B),
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
            // React: w-12 h-12 rounded-full bg-gradient-to-r shadow-lg
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.3),
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
