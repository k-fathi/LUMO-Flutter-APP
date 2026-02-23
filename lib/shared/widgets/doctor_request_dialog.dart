import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class DoctorRequestDialog extends StatefulWidget {
  final Function(String code) onSubmit;

  const DoctorRequestDialog({
    super.key,
    required this.onSubmit,
  });

  static Future<void> show(
      BuildContext context, {
        required Function(String code) onSubmit,
      }) {
    return showDialog(
      context: context,
      builder: (context) => DoctorRequestDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<DoctorRequestDialog> createState() => _DoctorRequestDialogState();
}

class _DoctorRequestDialogState extends State<DoctorRequestDialog> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال كود الطبيب'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_codeController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.medical_services_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'طلب الالتحاق بطبيب',
            style: AppTextStyles.h3,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل كود الطبيب الذي ترغب في الانضمام إليه',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _codeController,
            hint: 'مثال: DOC123456',
            prefixIcon: Icons.vpn_key_rounded,
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        AppButton(
          text: 'إرسال الطلب',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
          isFullWidth: false,
        ),
      ],
    );
  }
}