import 'package:flutter/material.dart';

import '../../core/enums/child_state.dart';
import '../../core/theme/app_text_styles.dart';

class StateBadge extends StatelessWidget {
  final ChildState state;
  final bool showIcon;
  final bool showText;
  final double size;

  const StateBadge({
    super.key,
    required this.state,
    this.showIcon = true,
    this.showText = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIcon && !showText) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: state.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 12 : 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: state.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.color,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              state.icon,
              size: size,
              color: state.color,
            ),
          if (showIcon && showText) const SizedBox(width: 6),
          if (showText)
            Text(
              state.displayName,
              style: AppTextStyles.label.copyWith(
                color: state.color,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}