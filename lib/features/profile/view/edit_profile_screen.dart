import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../data/models/parent_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../community/view_model/community_view_model.dart';
import '../../../core/router/route_names.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Edit Profile Screen
///
/// Reads user data from `AuthProvider` (single source of truth).
/// On save: calls `authProvider.updateProfile` which hits the real REST API
/// (POST /profile?_method=PUT) and updates the in-memory user immediately.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();

  File? _userImage;
  File? _childImage;
  final _imagePicker = ImagePicker();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields from the central AuthProvider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromProvider();
    });
  }

  void _prefillFromProvider() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';

    if (user is ParentModel) {
      _childNameController.text = user.childName;
      _childAgeController.text = user.childAge > 0 ? '${user.childAge}' : '';
    }
    setState(() {});
  }

  Future<void> _pickImage(bool isChild) async {
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

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      avatarFilePath: _userImage?.path,
      childName: _childNameController.text.trim().isEmpty
          ? null
          : _childNameController.text.trim(),
      childAge: int.tryParse(_childAgeController.text.trim()),
      childPhotoUrl: _childImage?.path,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Sync names in community posts immediately
      final updatedUser = authProvider.currentUser;
      if (updatedUser != null) {
        context.read<CommunityViewModel>().updateAuthorInfoInPosts(
              updatedUser.id,
              updatedUser.name,
              updatedUser.avatarUrl,
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الشخصي بنجاح'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'فشل تحديث الملف الشخصي'),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isParent = user is ParentModel;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'تعديل الملف الشخصي',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'حفظ',
                      style: AppTextStyles.body.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // ── Profile Picture ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? theme.dividerColor
                                : const Color(0xFFE3F2FD),
                            width: 4,
                          ),
                        ),
                        child: AvatarWidget(
                          imageUrl: user?.avatarUrl,
                          imageFile: _userImage,
                          name: user?.name,
                          size: 112,
                          fallbackIcon: user?.role.name == 'doctor'
                              ? Icons.medical_services_rounded
                              : Icons.person_rounded,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اضغط لتغيير الصورة',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Form Fields ──────────────────────────────────────
            _buildFormField(
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            _buildFormField(
              label: 'البريد الإلكتروني',
              icon: Icons.email_outlined,
              controller: _emailController,
              readOnly: true, // Email is usually not editable
            ),
            const SizedBox(height: 20),
            _buildFormField(
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),

            // ── Parent-only: Child fields ────────────────────────
            if (isParent) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? theme.dividerColor
                                  : const Color(0xFFE3F2FD),
                              width: 4,
                            ),
                          ),
                          child: AvatarWidget(
                            imageUrl: (user as ParentModel?)?.childPhotoUrl,
                            imageFile: _childImage,
                            name: _childNameController.text.isNotEmpty
                                ? _childNameController.text
                                : 'طفل',
                            size: 80,
                            fallbackIcon: Icons.child_care_rounded,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(true),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'صورة الطفل',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'اسم الطفل',
                icon: Icons.child_care,
                controller: _childNameController,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                label: 'عمر الطفل',
                icon: Icons.calendar_today_outlined,
                controller: _childAgeController,
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 48),

            // ── Sign Out ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.login,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('تسجيل الخروج'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFFE3F2FD),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Delete Account ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const FittedBox(
                    fit: BoxFit.scaleDown, child: Text('حذف الحساب')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.destructive.withValues(alpha: 0.1)
                      : const Color(0xFFFFEEEE),
                  foregroundColor: AppColors.destructive,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : (readOnly
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFE3F2FD)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor.withValues(alpha: 0.5)
                  : const Color(0xFFE3F2FD),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: readOnly
                  ? AppColors.mutedForeground
                  : theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon:
                  Icon(icon, size: 20, color: AppColors.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'هل أنت متأكد من حذف الحساب؟',
          style: AppTextStyles.h3.copyWith(
            color: theme.textTheme.titleLarge?.color,
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك ومنشوراتك ورسائلك بشكل دائم.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
          ),
          textAlign: TextAlign.right,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : const Color(0xFFE3F2FD),
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                        fit: BoxFit.scaleDown, child: Text('إلغاء')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await context.read<AuthProvider>().logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.login,
                          (route) => false,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('خطأ أثناء حذف الحساب: $e'),
                            backgroundColor: AppColors.destructive,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.destructive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                        fit: BoxFit.scaleDown, child: Text('نعم، احذف الحساب')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    super.dispose();
  }
}
