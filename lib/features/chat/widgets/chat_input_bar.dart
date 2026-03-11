import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// ChatInputBar - Figma Screen 10 Spec
///
/// Fixed at the bottom.
/// TextField with localized placeholder (e.g. "Type a message...").
/// Attachment Icon (Left), Send Button (Right - Gradient Circle).
/// BG: matches scaffold surface, text field has a rounded pill shape.
class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final Color? accentColor;
  final LinearGradient? accentGradient;

  final bool disabled;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.accentColor,
    this.accentGradient,
    this.disabled = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Text Field - Refined for better prominence
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.disabled,
                  onChanged: (v) =>
                      setState(() => _hasText = v.trim().isNotEmpty),
                  onSubmitted: (_) => _handleSend(),
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.chatInputPlaceholder,
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button - Gradient Circle
            GestureDetector(
              onTap: widget.disabled ? null : _handleSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: (_hasText && !widget.disabled)
                      ? (widget.accentGradient ?? AppColors.primaryGradient)
                      : null,
                  color:
                      (_hasText && !widget.disabled) ? null : AppColors.muted,
                  shape: BoxShape.circle,
                  boxShadow: (_hasText && !widget.disabled)
                      ? [
                          BoxShadow(
                            color: (widget.accentColor ?? AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: (_hasText && !widget.disabled)
                      ? Colors.white
                      : AppColors.mutedForeground,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
