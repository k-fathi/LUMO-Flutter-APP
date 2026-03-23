import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../community/widgets/post_card.dart';
import '../../community/view_model/community_view_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/providers/notification_provider.dart';
import '../view_model/profile_view_model.dart';

///
/// Refactored to use CommunityViewModel for user posts.
class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final int? userId;

  const ProfileScreen({super.key, this.user, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _followersDelta = 0;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready for providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      final targetUserId = widget.userId ?? widget.user?.id;
      final isMyProfile = targetUserId == null || targetUserId == currentUserId;

      if (isMyProfile) {
        context.read<CommunityViewModel>().loadMyPosts();
      }

      if (targetUserId != null) {
        context.read<ProfileViewModel>().loadProfile(targetUserId).then((_) {
          if (mounted) {
            setState(() => _followersDelta = 0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final communityViewModel = context.watch<CommunityViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();
    final currentUser = authProvider.currentUser;

    final targetUserId = widget.userId ?? widget.user?.id;
    final isMyProfile = (widget.user == null && widget.userId == null) ||
        widget.userId == currentUser?.id ||
        widget.user?.id == currentUser?.id;

    final user =
        isMyProfile ? currentUser : (profileViewModel.user ?? widget.user);
    final isDoctor = user?.role.name == 'doctor';
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Show target user's posts for their profile, current user's posts for own profile
    final displayPosts = isMyProfile
        ? communityViewModel.myPosts
        : communityViewModel.posts
            .where((p) => p.userId == targetUserId)
            .toList();

    final baseFollowers = profileViewModel.user?.followersCount ?? 0;
    final followersShow = baseFollowers + _followersDelta;
    final followingShow = profileViewModel.user?.followingCount ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Builder(
        builder: (context) {
          // If loading, show indicator
          if (profileViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // If not loading and no user found (and not my profile), show error
          if (user == null && !isMyProfile) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_rounded,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      profileViewModel.errorMessage ??
                          'لم يتم العثور على المستخدم',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (targetUserId != null) {
                          context
                              .read<ProfileViewModel>()
                              .loadProfile(targetUserId);
                        }
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('رجوع'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (targetUserId != null) {
                await context
                    .read<ProfileViewModel>()
                    .loadProfile(targetUserId);
              }
              await context.read<CommunityViewModel>().loadMyPosts();
            },
            child: CustomScrollView(
              slivers: [
                // ── 1. Header Section ─────────────────────────────
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    userId: targetUserId,
                    name: user?.name ?? 'User',
                    role: isDoctor ? l10n.roleDoctor : l10n.roleParent,
                    isDoctor: isDoctor,
                    photoUrl: user?.avatarUrl,
                    followers: followersShow,
                    following: followingShow,
                    isMyProfile: isMyProfile,
                    isFollowing: targetUserId != null &&
                        communityViewModel.isFollowing(targetUserId),
                    onToggleFollow: () async {
                      debugPrint(
                          'Toggling follow for target user: $targetUserId');
                      final currentUserId =
                          context.read<AuthProvider>().currentUser?.id;
                      if (targetUserId != null && currentUserId != null) {
                        final wasFollowing =
                            communityViewModel.isFollowing(targetUserId);

                        // Optimistic UI update for count
                        setState(() {
                          _followersDelta += wasFollowing ? -1 : 1;
                        });

                        try {
                          await context.read<CommunityViewModel>().toggleFollow(
                              targetUserId,
                              currentUserId: currentUserId);

                          // Notify and Sync Count
                          if (!wasFollowing) {
                            context
                                .read<NotificationProvider>()
                                .sendFollowNotification(
                                  targetUserId: targetUserId,
                                  followerName: context
                                          .read<AuthProvider>()
                                          .currentUser
                                          ?.name ??
                                      '',
                                );
                          }

                          // Web/UX feedback snackbar
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(!wasFollowing
                                    ? 'تم متابعة ${user?.name}'
                                    : 'تم إلغاء متابعة ${user?.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }

                          // Final sync with backend for actual counts
                          if (mounted) {
                            context
                                .read<ProfileViewModel>()
                                .loadProfile(targetUserId);
                          }
                        } catch (e) {
                          // Revert on failure
                          setState(() {
                            _followersDelta -= wasFollowing ? -1 : 1;
                          });
                        }
                      }
                    },
                    onEditProfile: () {
                      Navigator.pushNamed(context, RouteNames.editProfile);
                    },
                    onSettings: () {
                      Navigator.pushNamed(context, RouteNames.settings);
                    },
                    onSignOut: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.login,
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),

                // ── 1b. Role-Specific Quick Actions (Only if my profile) ──────────────
                if (isMyProfile)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                        children: isDoctor
                            ? [
                                // ── DOCTOR Actions ──────────────────
                                _buildQuickAction(
                                  icon: Icons.people_alt_rounded,
                                  iconColor: AppColors.primary,
                                  title: l10n.viewPatients,
                                  subtitle: l10n.viewPatientsSubtitle,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RouteNames.doctorPatients);
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildQuickAction(
                                  icon: Icons.local_hospital_rounded,
                                  iconColor: const Color(0xFF22C55E),
                                  title: l10n.clinicInfo,
                                  subtitle: l10n.editClinicInfo,
                                  onTap: () {
                                    final controller = TextEditingController(
                                        text: 'Al-Amal Clinic');
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(l10n.editClinicInfo),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: controller,
                                              decoration: InputDecoration(
                                                labelText: l10n.clinicNameLabel,
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(l10n.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(l10n.dataUpdated)),
                                              );
                                            },
                                            child: Text(l10n.save),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ]
                            : [
                                // ── PARENT Actions ──────────────────
                                _buildQuickAction(
                                  icon: Icons.analytics_outlined,
                                  iconColor: const Color(0xFFF59E0B),
                                  title: l10n.analysisHistory,
                                  subtitle: l10n.viewChildAnalysisSubtitle,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RouteNames.parentAnalysis);
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildQuickAction(
                                  icon: Icons.child_care_rounded,
                                  iconColor: const Color(0xFF06B6D4),
                                  title: l10n.childInfo,
                                  subtitle: l10n.editChildInfo,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RouteNames.childProfile);
                                  },
                                ),
                              ],
                      ),
                    ),
                  ),

                // ── 2. My Posts List ────────────────────────────
                if (communityViewModel.isLoading && displayPosts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (displayPosts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.post_add,
                              size: 64, color: theme.disabledColor),
                          const SizedBox(height: 16),
                          Text(
                            isMyProfile
                                ? 'لم تقم بنشر أي شيء بعد'
                                : 'لا توجد منشورات لهذا المستخدم',
                            style: TextStyle(color: theme.disabledColor),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                isMyProfile ? l10n.myPosts : l10n.posts,
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.headlineMedium?.color,
                                ),
                              ),
                            );
                          }
                          final post = displayPosts[index - 1];
                          return PostCard(
                            post: post,
                            isOwnProfile: isMyProfile,
                            hideFollowButton: true,
                          );
                        },
                        childCount: displayPosts.length + 1,
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: theme.disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Profile Header - Gradient BG + Overlapping Avatar + Stats
// ══════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final bool isDoctor;
  final int? userId;
  final String? photoUrl;
  final int followers;
  final int following;
  final bool isMyProfile;
  final bool isFollowing;

  final VoidCallback onToggleFollow;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final Future<void> Function() onSignOut;

  const _ProfileHeader({
    required this.userId,
    required this.name,
    required this.role,
    required this.isDoctor,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.isMyProfile,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onEditProfile,
    required this.onSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. Background Gradient Container
        Container(
          height: 200 + topPadding,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, Color(0xFF1E88E5)],
            ),
          ),
        ),

        // 2. Control Buttons (Top Row)
        Positioned(
          top: topPadding + 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Settings/Back Icon
              isMyProfile
                  ? IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                      onPressed: onSettings,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),

              // Title
              Text(
                l10n.profile,
                style: AppTextStyles.h3
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),

              // SignOut icon only if my profile
              if (isMyProfile)
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: onSignOut,
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),

        // 3. Profile Card Overlay
        Padding(
          padding: EdgeInsets.only(top: 140 + topPadding, left: 16, right: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name
                Text(
                  name,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                // Role
                Text(
                  role,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.mutedForeground),
                ),

                const SizedBox(height: 20),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        if (userId != null) {
                          Navigator.pushNamed(
                            context,
                            RouteNames.followers,
                            arguments: userId,
                          );
                        }
                      },
                      child: _buildStat(l10n.followers, followers.toString()),
                    ),
                    Container(width: 1, height: 24, color: theme.dividerColor),
                    InkWell(
                      onTap: () {
                        if (userId != null) {
                          Navigator.pushNamed(
                            context,
                            RouteNames.following,
                            arguments: userId,
                          );
                        }
                      },
                      child: _buildStat(l10n.following, following.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Action Button (Edit or Follow)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isMyProfile ? onEditProfile : onToggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMyProfile
                          ? theme.colorScheme.surfaceContainerHighest
                          : (isFollowing
                              ? Colors.grey[300]
                              : AppColors.primary),
                      foregroundColor: isMyProfile
                          ? theme.textTheme.bodyLarge?.color
                          : (isFollowing ? Colors.black87 : Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isMyProfile
                          ? l10n.editProfile
                          : (isFollowing ? l10n.unfollow : l10n.follow),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Overlapping Avatar
        Positioned(
          top: 90 + topPadding,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: AvatarWidget(
                size: 90,
                imageUrl: photoUrl,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style:
              AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}

// End of file. Mock data removed.
