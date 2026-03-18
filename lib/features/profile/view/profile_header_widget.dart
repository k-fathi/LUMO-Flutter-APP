import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// ProfileHeaderWidget - Matches React ProfileScreen header pattern
///
/// React layout:
/// - Gradient header: from-[#2196F3] to-[#1565C0] pt-12 pb-32 rounded-b-[32px]
///   with centered title "ملفي الشخصي"
/// - Overlapping card: -mt-24 rounded-3xl shadow-lg border-0
///   with w-28 h-28 avatar, text-2xl name, edit button (E3F2FD bg),
///   doctor patients button or parent request button (gradient),
///   2-column stats grid (grid-cols-2) with border-t border-b border-[#E3F2FD]
class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;
  final bool isOwnProfile;
  final bool isFollowing;
  final VoidCallback? onFollowTap;
  final VoidCallback? onEditProfile;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onViewPatients;
  final VoidCallback? onPatientRequest;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    this.isOwnProfile = false,
    this.isFollowing = false,
    this.onFollowTap,
    this.onEditProfile,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onViewPatients,
    this.onPatientRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDoctor = user.role.isDoctor;

    return Column(
      children: [
        // Gradient Header - React: bg-gradient-to-r from-[#2196F3] to-[#1565C0] pt-12 pb-32 rounded-b-[32px]
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 96, // pb-32 ≈ 128px, reduced for overlapping card
          ),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Center(
            child: Text(
              'ملفي الشخصي',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 24, // text-2xl
              ),
            ),
          ),
        ),

        // Profile Info Card - React: px-6 -mt-24
        Transform.translate(
          offset: const Offset(0, -96),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24), // rounded-3xl
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar - React: w-28 h-28 border-4 border-white shadow-lg mb-4
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardColor, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.4 : 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AvatarWidget(
                      imageUrl: user.avatarUrl,
                      name: user.name,
                      size: 112,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name - React: text-2xl text-[#1a1f36] mb-6
                  Text(
                    user.name,
                    style: AppTextStyles.h1.copyWith(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 24,
                    ),
                  ),
                  if (user.isVerified ?? false) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF2196F3), size: 20),
                  ],
                  const SizedBox(height: 24),

                  // Edit Profile Button - React: w-full h-12 rounded-xl bg-[#E3F2FD] text-[#2196F3]
                  if (isOwnProfile) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: onEditProfile,
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('تعديل الملف الشخصي'),
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

                    // Doctor: "مرضاي" button / Parent: "طلب انضمام لطبيب" button
                    // React: w-full h-12 rounded-xl bg-gradient-to-r text-white
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              isDoctor ? onViewPatients : onPatientRequest,
                          icon: Icon(isDoctor ? Icons.people : Icons.person_add,
                              size: 20),
                          label: Text(isDoctor ? 'مرضاي' : 'طلب انضمام لطبيب'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Follow Button for other users
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient:
                              isFollowing ? null : AppColors.primaryGradient,
                          color: isFollowing
                              ? (isDark
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : const Color(0xFFE3F2FD))
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onFollowTap,
                          icon: Icon(
                              isFollowing
                                  ? Icons.person_remove_rounded
                                  : Icons.person_add_rounded,
                              size: 20),
                          label:
                              Text(isFollowing ? 'إلغاء المتابعة' : 'متابعة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: isFollowing
                                ? theme.colorScheme.primary
                                : Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Stats - React: grid grid-cols-2 gap-4 py-4 border-t border-b border-[#E3F2FD]
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: isDark
                                ? theme.dividerColor
                                : const Color(0xFFE3F2FD)),
                        bottom: BorderSide(
                            color: isDark
                                ? theme.dividerColor
                                : const Color(0xFFE3F2FD)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context: context,
                            value: user.followersCount.toString(),
                            label: 'المتابعون',
                            onTap: onFollowersTap,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context: context,
                            value: user.followingCount.toString(),
                            label: 'المتابَعون',
                            onTap: onFollowingTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // React: text-2xl text-[#1a1f36] mb-1
            Text(
              value,
              style: AppTextStyles.h1.copyWith(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            // React: text-sm text-[#64748b]
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
