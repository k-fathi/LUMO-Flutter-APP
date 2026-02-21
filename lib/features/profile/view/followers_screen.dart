import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Followers Screen - Matches React FollowersScreen
///
/// React layout:
/// - Gradient header with back + title
/// - px-6 py-6 space-y-3
/// - Card: p-4 rounded-2xl shadow-sm border-[#E3F2FD]
///   with w-14 h-14 avatar, name, role, gradient follow or E3F2FD "متابَع" button
class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  // Placeholder data matching React
  final List<Map<String, dynamic>> followers = [
    {'name': 'د. محمد أحمد', 'role': 'طبيب قلب', 'isFollowingBack': true},
    {'name': 'سارة علي', 'role': 'مستخدم', 'isFollowingBack': false},
    {'name': 'د. فاطمة حسن', 'role': 'طبيبة أطفال', 'isFollowingBack': true},
    {'name': 'أحمد محمود', 'role': 'مستخدم', 'isFollowingBack': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // React: gradient header with back + title
      appBar: const GradientAppBar(title: 'المتابعون'),
      body: followers.isEmpty
          ? Center(
              child: Text(
                'لا توجد متابعون بعد',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            )
          : ListView.builder(
              // React: px-6 py-6 space-y-3
              padding: const EdgeInsets.all(24),
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final follower = followers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFollowerCard(follower),
                );
              },
            ),
    );
  }

  /// Card matching React: p-4 rounded-2xl shadow-sm border-[#E3F2FD]
  Widget _buildFollowerCard(Map<String, dynamic> follower) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFollowingBack = follower['isFollowingBack'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16), // rounded-2xl
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
          // React: w-14 h-14 avatar
          AvatarWidget(
            imageUrl: null,
            name: follower['name'] as String,
            size: 56,
          ),
          const SizedBox(width: 16),
          // React: flex-1 text-right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // React: text-[#1a1a2e] mb-1
                Text(
                  follower['name'] as String,
                  style: AppTextStyles.body.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // React: text-sm text-[#64748b]
                Text(
                  follower['role'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Follow button - gradient or outline depending on isFollowingBack
          InkWell(
            onTap: () {
              setState(() {
                follower['isFollowingBack'] = !isFollowingBack;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFollowingBack
                        ? 'تمت المتابعة بنجاح'
                        : 'تم إلغاء المتابعة',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: isFollowingBack
                ? Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isDark
                              ? theme.dividerColor
                              : const Color(0xFFE3F2FD),
                          width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'متابَع',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  )
                : Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'متابعة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
