import 'package:flutter/material.dart';

/// ElevatedCard - Updated to match React Card pattern
///
/// React: rounded-3xl border-0 shadow-sm
/// or: rounded-3xl shadow-lg border-0
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        // React: rounded-3xl → 24px
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE3F2FD),
          width: 1,
        ),
        // React: shadow-sm for post cards
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: elevation != null ? elevation! * 2 : 4,
            offset: Offset(0, elevation ?? 1),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
