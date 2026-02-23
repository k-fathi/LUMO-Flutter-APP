import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// MessageBubble - Figma Screen 10 Spec
///
/// My Message: Aligned Right, Gradient BG (#2196F3 → #1565C0), White Text,
///             Rounded-2xl with sharp Bottom-Right corner.
/// Other Message: Aligned Left, #F1F5F9 BG, Dark Text,
///                Rounded-2xl with sharp Bottom-Left corner.
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 64 : 16,
        right: isMine ? 16 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // My: Gradient, Other: theme surface
            gradient: isMine ? AppColors.primaryGradient : null,
            color: isMine
                ? null
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              // Sharp corner on sender side
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: isMine
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
