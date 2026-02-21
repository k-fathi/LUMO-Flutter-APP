import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'حذف',
    this.cancelText = 'إلغاء',
    required this.onConfirm,
  });

  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'حذف',
        String cancelText = 'إلغاء',
        required VoidCallback onConfirm,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        title,
        style: AppTextStyles.h2,
      ),
      content: Text(
        message,
        style: AppTextStyles.body,
      ),
      actions: [
        AppButton(
          text: cancelText,
          type: AppButtonType.text,
          onPressed: () => Navigator.pop(context, false),
          isFullWidth: false,
        ),
        AppButton(
          text: confirmText,
          type: AppButtonType.destructive,
          onPressed: () {
            onConfirm();
            Navigator.pop(context, true);
          },
          isFullWidth: false,
        ),
      ],
    );
  }
}