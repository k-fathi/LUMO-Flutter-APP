import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/mixins/form_validation_mixin.dart';

/// Forgot Password Screen - Pixel-perfect match to React ForgotPasswordScreen
///
/// React layout:
/// - bg-gradient-to-b from-[#E3F2FD] to-white flex flex-col
/// - Header: px-6 pt-12 pb-8 with ArrowLeft back button
/// - Phone input (not email)
/// - Help text card at bottom
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with FormValidationMixin {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_phoneController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // In a real app, navigate to verification code screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال رمز التحقق'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // React: bg-gradient-to-b from-[#E3F2FD] to-white
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header - React: px-6 pt-12 pb-8
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button - React: text-[#2196F3] mb-6
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // React: text-3xl text-[#1a1f36] mb-2 text-right
                    Text(
                      'نسيت كلمة المرور؟',
                      style: AppTextStyles.h1.copyWith(
                        color: const Color(0xFF1A1F36),
                        fontSize: 30, // text-3xl
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // React: text-[#64748b] text-right
                    Text(
                      'أدخل رقم هاتفك وسنرسل لك رمز التحقق',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Form - React: flex-1 px-6
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Phone field - React: space-y-6
                      AppTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        hint: '+966 50 123 4567',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      // Submit button - React: w-full h-14 rounded-2xl bg-gradient-to-r from-[#2196F3] to-[#1565C0]
                      AppButton(
                        text: _isLoading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                        onPressed: _phoneController.text.trim().isEmpty && !_isLoading
                            ? null
                            : _handleSendCode,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 32),

                      // Help Text - React: mt-8 p-4 bg-white rounded-2xl border border-[#E3F2FD]
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16), // rounded-2xl
                          border: Border.all(
                            color: const Color(0xFFE3F2FD),
                          ),
                        ),
                        child: Text(
                          'سيتم إرسال رمز التحقق عبر رسالة نصية إلى رقم هاتفك. قد يستغرق الأمر بضع دقائق.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}