import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole userRole;

  const SignUpScreen({super.key, required this.userRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Parent Specific Controllers
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();

  // Doctor Specific Controllers
  final _licenseIdController = TextEditingController();
  final _clinicLocationController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  File? _childImage; // Added for child photo

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _childImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _licenseIdController.dispose();
    _clinicLocationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.userRole.name,
        // Parent-specific
        childName: widget.userRole == UserRole.parent
            ? _childNameController.text.trim()
            : null,
        childAge: widget.userRole == UserRole.parent
            ? int.tryParse(_childAgeController.text.trim())
            : null,
        // Doctor-specific
        doctorNumber: widget.userRole == UserRole.doctor
            ? _licenseIdController.text.trim()
            : null,
        clinicLocation: widget.userRole == UserRole.doctor
            ? _clinicLocationController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.mainLayout,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isParent = widget.userRole == UserRole.parent;
    final roleTitle = isParent ? 'حساب ولي أمر' : 'حساب طبيب';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).iconTheme.color),
        title: Text('إنشاء حساب جديد', style: AppTextStyles.h2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  roleTitle,
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'أكمل بياناتك للمتابعة',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Common Fields
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline,
                  validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v?.contains('@') != true ? 'بريد غير صحيح' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Dynamic Fields based on Role
                if (isParent) ...[
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
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
                          image: _childImage != null
                              ? DecorationImage(
                                  image: FileImage(_childImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _childImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      color: Theme.of(context).hintColor),
                                  const SizedBox(height: 4),
                                  Text(
                                    'صورة الطفل',
                                    style: AppTextStyles.caption.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 10),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _childNameController,
                    label: 'اسم الطفل',
                    icon: Icons.child_care,
                    validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _childAgeController,
                    label: 'عمر الطفل',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                  ),
                ] else ...[
                  _buildTextField(
                    controller: _licenseIdController,
                    label: 'رقم الترخيص الطبي',
                    icon: Icons.badge_outlined,
                    validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _clinicLocationController,
                    label: 'عنوان العيادة',
                    icon: Icons.location_on_outlined,
                    validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                  ),
                ],

                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => (v?.length ?? 0) < 6
                      ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                      : null,
                ),

                const SizedBox(height: 48),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('إنشاء الحساب'),
                ),

                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: AppTextStyles.body,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, RouteNames.login),
                      child: const Text('تسجيل الدخول'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.mutedForeground),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body,
    );
  }
}
