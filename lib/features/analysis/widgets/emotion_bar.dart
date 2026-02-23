import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Custom EmotionBar Widget — replaces complex chart packages
///
/// Layout: Row → Emoji Icon | Label | LinearProgressIndicator | Percentage
/// Positive emotions → AppColors.primary
/// Negative emotions → AppColors.destructive / Orange
class EmotionBar extends StatelessWidget {
  final String emoji;
  final String label;
  final double percentage; // 0.0 – 1.0
  final Color color;

  const EmotionBar({
    super.key,
    required this.emoji,
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Emoji Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),

          // Label
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Percentage text
          SizedBox(
            width: 42,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
