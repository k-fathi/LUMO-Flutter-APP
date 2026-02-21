import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../view_model/profile_view_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../shared/providers/patient_provider.dart';
import '../../../shared/providers/community_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../chat/view_model/chat_view_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/router/route_names.dart';

/// Edit Profile Screen - Matches React EditProfileScreen
///
/// React layout:
/// - Gradient header with back + title + white save button
/// - Avatar with camera overlay (gradient circle)
/// - E3F2FD rounded-2xl input fields with icons
/// - Sign out button (E3F2FD bg, blue text)
/// - Delete account button (fee bg, red text) with confirmation dialog
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
  late ProfileViewModel _viewModel;

  File? _userImage;
  File? _childImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      repository: getIt<ProfileRepository>(),
    );
    _nameController.text = _viewModel.userName;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // React: gradient header with back + title + save button
      appBar: GradientAppBar(
        title: 'تعديل الملف الشخصي',
        actions: [
          // React: bg-white text-[#2196F3] h-9 px-4 rounded-xl
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextButton(
              onPressed: () {
                _viewModel.updateProfile(
                  userId: _viewModel.user?.id ?? '',
                  name: _nameController.text,
                  phone: _phoneController.text,
                  avatarUrl: _userImage?.path ?? _viewModel.user?.avatarUrl,
                );
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
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
      body: ChangeNotifierProvider<ProfileViewModel>.value(
        value: _viewModel,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Profile Picture - React: relative w-28 h-28 border-4 border-[#E3F2FD] + camera overlay
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
                                width: 4),
                          ),
                          child: AvatarWidget(
                            imageUrl: _viewModel.user?.avatarUrl,
                            imageFile: _userImage,
                            name: _viewModel.userName,
                            size: 112,
                            fallbackIcon: _viewModel.user?.role.name == 'doctor'
                                ? Icons.medical_services_rounded
                                : Icons.person_rounded,
                          ),
                        ),
                        // Camera button
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
                    // React: text-sm text-[#64748b] mt-3
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

              // Form Fields - React: space-y-5
              _buildFormField(
                label: 'الاسم الكامل',
                icon: Icons.person_outline,
                controller: _nameController,
                defaultValue: 'أحمد محمد',
              ),
              const SizedBox(height: 20),
              _buildFormField(
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                controller: _emailController,
                defaultValue: 'ahmed@example.com',
              ),
              const SizedBox(height: 20),
              _buildFormField(
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                defaultValue: '+966 50 123 4567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              if (_viewModel.user?.role.name == 'parent') ...[
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
                                  width: 4),
                            ),
                            child: AvatarWidget(
                              imageUrl: (_viewModel.user as ParentModel?)
                                  ?.childPhotoUrl,
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
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
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
                  defaultValue: 'محمد',
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'عمر الطفل',
                  icon: Icons.calendar_today_outlined,
                  controller: _childAgeController,
                  defaultValue: '5',
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 48),

              // Account Actions - React: mt-12 space-y-3
              // Sign Out - React: w-full h-12 rounded-xl bg-[#E3F2FD] text-[#2196F3]
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // 1. Clear memory state of all major providers
                    context.read<PatientProvider>().clearState();
                    context.read<CommunityProvider>().clearState();
                    context.read<UserProvider>().clearUser();

                    // 2. Clear ViewModels
                    getIt<ChatViewModel>().clearState();
                    _viewModel.logout(); // Clears profile state

                    // 3. Clear auth and local caches
                    await context.read<AuthProvider>().signOut();

                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('تسجيل الخروج'),
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

              // Delete Account - React: w-full h-12 rounded-xl bg-[#fee] text-[#ef4444]
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('حذف الحساب'),
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
      ),
    );
  }

  /// Form field matching React: h-14 rounded-2xl border-[#E3F2FD] bg-[#E3F2FD] pr-12
  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? defaultValue,
    TextInputType? keyboardType,
  }) {
    if (controller.text.isEmpty && defaultValue != null) {
      controller.text = defaultValue;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // React: mb-2 block text-[#1a1a2e] text-right
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56, // h-14
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16), // rounded-2xl
            border: Border.all(
                color: isDark
                    ? theme.dividerColor.withValues(alpha: 0.5)
                    : const Color(0xFFE3F2FD)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              // React: icon at right side (pr-12) → RTL means icon is trailing, but in React it's absolute right
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
          borderRadius: BorderRadius.circular(24), // rounded-3xl
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
        actions: [
          // Cancel - React: flex-1 bg-[#E3F2FD] text-[#2196F3] rounded-xl h-11
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
                child: const Text('إلغاء'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Delete - React: flex-1 bg-[#ef4444] text-white rounded-xl h-11
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().deleteAccount();
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
                child: const Text('نعم، احذف الحساب'),
              ),
            ),
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
    _viewModel.dispose();
    super.dispose();
  }
}
