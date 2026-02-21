import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ButtonVariant {
  unspecified, // default
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum ButtonSize {
  unspecified, // default
  sm,
  lg,
  icon,
}

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = ButtonVariant.unspecified,
    this.size = ButtonSize.unspecified,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  }) : assert(text != null || child != null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    Widget content = _buildContent();

    // Wrap in InkWell for better touch feedback if needed, but ElevatedButton handles it.
    // For specific variants, we implement the style.

    switch (variant) {
      case ButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.destructive,
            foregroundColor: AppColors.destructiveForeground,
            elevation: 0,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12)), // Radius from theme/globals
          ),
          child: content,
        );
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.labelLarge?.color,
            side: const BorderSide(color: AppColors.border),
            padding: _getPadding(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: content,
        );
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.secondaryForeground,
            elevation: 0,
            padding: _getPadding(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: content,
        );
      case ButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.labelLarge?.color,
            padding: _getPadding(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: content,
        );
      case ButtonVariant.link:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: content,
        );
      default:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            elevation: 0,
            padding: _getPadding(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: content,
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getLoaderColor(),
        ),
      );
    }

    final List<Widget> children = [];
    if (icon != null) {
      children.add(Icon(icon, size: 18));
      children.add(const SizedBox(width: 8)); // Space between icon and text
    }

    if (text != null) {
      children.add(Text(
        text!,
        // Style is handled by button theme mostly, but we can override if needed
      ));
    } else if (child != null) {
      children.add(child!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double? _getHeight() {
    // Let the button sizing logic handle it naturally or enforce if strictly needed
    switch (size) {
      case ButtonSize.sm:
        return 36;
      case ButtonSize.lg:
        return 50;
      case ButtonSize.icon:
        return 40;
      default:
        return 44;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (size == ButtonSize.icon) return EdgeInsets.zero;
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ButtonSize.unspecified:
      default:
        return const EdgeInsets.symmetric(horizontal: 16);
    }
  }

  Color _getLoaderColor() {
    switch (variant) {
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.secondary:
        return AppColors.primary;
      default:
        return AppColors.primaryForeground;
    }
  }
}
