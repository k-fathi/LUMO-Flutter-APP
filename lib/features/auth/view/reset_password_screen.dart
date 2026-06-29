import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/mixins/form_validation_mixin.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with FormValidationMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!validateForm()) return;

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.resetPassword(
      phone: widget.phone,
      otp: widget.otp,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response != null && response.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.primary,
        ),
      );

      // Navigate to login and clear stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.errorMessage ?? (isAr ? 'فشل إعادة تعيين كلمة المرور' : 'Failed to reset password')),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor]
                : [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Align(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Icon(
                          isAr ? Icons.arrow_forward : Icons.arrow_back,
                          size: 24,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'كلمة مرور جديدة' : 'New Password',
                      style: AppTextStyles.h1.copyWith(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? 'يرجى إدخال كلمة المرور الجديدة وتأكيدها' : 'Please enter and confirm your new password',
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _passwordController,
                      label: isAr ? 'كلمة المرور الجديدة' : 'New Password',
                      hint: isAr ? 'أدخل كلمة المرور' : 'Enter password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        isAr
                            ? 'يجب أن لا تقل كلمة المرور عن 8 أحرف وتحتوي على حرف ورقم واحد على الأقل.'
                            : 'Password must be at least 8 characters long and contain at least one letter and one number.',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                      hint: isAr ? 'أعد إدخال كلمة المرور' : 'Re-enter password',
                      prefixIcon: Icons.lock_clock_outlined,
                      obscureText: true,
                      validator: (value) => validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: isAr ? 'حفظ' : 'Save',
                      onPressed: _handleReset,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
