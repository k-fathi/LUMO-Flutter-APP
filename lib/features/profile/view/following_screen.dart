import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Following Screen - Matches React FollowingScreen pattern (same as FollowersScreen)
///
/// React: Gradient header, rounded-2xl cards, gradient unfollow buttons
class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final List<Map<String, dynamic>> following = [
    {'id': '1', 'name': 'يتابع 1', 'role': 'مستخدم', 'isFollowing': true},
    {'id': '2', 'name': 'يتابع 2', 'role': 'طبيب', 'isFollowing': true},
    {'id': '3', 'name': 'يتابع 3', 'role': 'مستخدم', 'isFollowing': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GradientAppBar(title: 'المتابَعون'),
      body: following.isEmpty
          ? Center(
              child: Text(
                'لا تتابع أحد بعد',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFollowingCard(user),
                );
              },
            ),
    );
  }

  Widget _buildFollowingCard(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFollowing = user['isFollowing'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? theme.dividerColor : const Color(0xFFE3F2FD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: null,
            name: user['name'] as String,
            size: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] as String,
                  style: AppTextStyles.body.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['role'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Unfollow button
          InkWell(
            onTap: () {
              setState(() {
                user['isFollowing'] = !isFollowing;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFollowing
                        ? 'تم البدء بمتابعة ${user['name']}'
                        : 'تم إلغاء متابعة ${user['name']}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: isDark
                        ? theme.dividerColor
                        : (isFollowing
                            ? const Color(0xFFE3F2FD)
                            : AppColors.primary),
                    width: 2),
                borderRadius: BorderRadius.circular(12),
                color: isFollowing ? Colors.transparent : AppColors.primary,
              ),
              alignment: Alignment.center,
              child: Text(
                isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                style: AppTextStyles.caption.copyWith(
                  color: isFollowing ? AppColors.mutedForeground : Colors.white,
                  fontWeight: isFollowing ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
