import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/mixins/form_validation_mixin.dart';
import '../../../shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Signup Screen
///
/// User registration with role-specific fields
/// Features:
/// - Common fields (name, email, password, phone)
/// - Parent fields (child name, age)
/// - Doctor fields (specialization, license, experience)
/// - Complete validation
/// - Loading state
class SignupScreen extends StatefulWidget {
  final UserRole? selectedRole;

  const SignupScreen({super.key, this.selectedRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with FormValidationMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Parent fields
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();

  // Doctor fields
  final _clinicLocationController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  File? _userImage;
  File? _childImage;
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole ?? UserRole.parent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _clinicLocationController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isChild}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          if (isChild) {
            _childImage = File(pickedFile.path);
          } else {
            _userImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!validateForm()) return;

    if (_selectedRole.isParent && _childImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إرفاق صورة الطفل (إجباري)'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: _selectedRole.isParent ? 'patient' : 'doctor',
        childName:
            _selectedRole.isParent ? _childNameController.text.trim() : null,
        childAge: _selectedRole.isParent
            ? int.tryParse(_childAgeController.text)
            : null,
        doctorNumber: _selectedRole.isDoctor
            ? _licenseNumberController.text.trim()
            : null,
        clinicLocation: _selectedRole.isDoctor
            ? _clinicLocationController.text.trim()
            : null,
        userImageUrl: _userImage?.path,
        childImageUrl: _childImage?.path,
      );

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        
        // If registration was successful but user is null, it means OTP is required
        if (authProvider.currentUser == null) {
          Navigator.pushNamed(
            context,
            RouteNames.otpVerification,
            arguments: {
              'phone': _phoneController.text.trim(),
              'isPasswordReset': false,
            },
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.mainLayout,
            (route) => false,
          );
        }
      } else {
        if (!mounted) return;
        _showErrorSnackBar(authProvider.errorMessage ?? 'فشل إنشاء الحساب');
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPhotoInputField({
    required File? imageFile,
    required VoidCallback onTap,
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    imageFile != null ? AppColors.primary : AppColors.secondary,
                width: imageFile != null ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  prefixIcon,
                  color: AppColors.mutedForeground,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    imageFile != null ? 'تم رفع الصورة بنجاح' : hint,
                    style: AppTextStyles.body.copyWith(
                      color: imageFile != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
                if (imageFile != null) ...[
                  const SizedBox(width: 12),
                  ClipOval(
                    child: Image.file(
                      imageFile,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 24,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header with Logo
                Center(
                  child: Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          'assets/images/lumo-logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'إنشاء حساب',
                  style: AppTextStyles.h1.copyWith(
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'التسجيل ك${_selectedRole.isDoctor ? "طبيب" : "مستخدم"}',
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Common fields
                AppTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: validateName,
                ),
                const SizedBox(height: 20),
                _buildPhotoInputField(
                  imageFile: _userImage,
                  onTap: () => _pickImage(isChild: false),
                  label: 'الصورة الشخصية',
                  hint: 'أضف صورتك الشخصية (اختياري)',
                  prefixIcon: _selectedRole.isDoctor
                      ? Icons.medical_services_outlined
                      : Icons.person_outline,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _phoneController,
                  label: 'رقم الجوال',
                  hint: 'أدخل رقم الجوال',
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أنشئ كلمة مرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أكد كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),

                // Role-specific fields
                if (_selectedRole.isParent) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _childNameController,
                    label: 'اسم الطفل',
                    hint: 'أدخل اسم الطفل',
                    prefixIcon: Icons.favorite_border,
                    validator: validateChildName,
                  ),
                  const SizedBox(height: 20),
                  _buildPhotoInputField(
                    imageFile: _childImage,
                    onTap: () => _pickImage(isChild: true),
                    label: 'صورة الطفل',
                    hint: 'أضف صورة الطفل (إجباري)',
                    prefixIcon: Icons.child_care_outlined,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _childAgeController,
                    label: 'عمر الطفل',
                    hint: 'أدخل عمر الطفل',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: validateAge,
                  ),
                ],

                if (_selectedRole.isDoctor) ...[
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _licenseNumberController,
                    label: 'رقم الطبيب / الترخيص',
                    hint: 'أدخل رقم الطبيب',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    validator: validateLicenseNumber,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _clinicLocationController,
                    label: 'موقع العيادة',
                    hint: 'أدخل موقع العيادة',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال موقع العيادة' : null,
                  ),
                ],

                const SizedBox(height: 40),
                AppButton(
                  text: 'إنشاء حساب',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.login);
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.destructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
