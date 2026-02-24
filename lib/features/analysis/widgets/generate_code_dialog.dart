import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// GenerateCodeDialog — Doctor generates a code to share with a parent
///
/// Content: "Share this code with the parent"
/// Display: Large bold code (e.g., LUMO-2024) + Copy button
class GenerateCodeDialog extends StatelessWidget {
  GenerateCodeDialog({super.key});

  // Generate a random code like LUMO-XXXX
  final String _code = 'LUMO-${(1000 + Random().nextInt(9000))}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'رمز المريض الجديد',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'شارك هذا الرمز مع ولي الأمر لربط حساب الطفل',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Code Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _code,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Copy Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الرمز!'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('نسخ الرمز'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Close Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
