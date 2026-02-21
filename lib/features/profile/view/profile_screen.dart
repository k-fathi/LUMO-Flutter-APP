import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../community/widgets/post_card.dart';
import '../../community/models/mock_post.dart';
import '../../analysis/widgets/generate_code_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/avatar_widget.dart';

import '../../../data/models/user_model.dart';

/// ProfileScreen (Screen 12) - Figma Spec
///
/// CustomScrollView with Slivers:
///   1. SliverToBoxAdapter: Gradient header + overlapping avatar + name/role/bio + stats
///   2. SliverToBoxAdapter: TabBar (My Posts / Media)
///   3. SliverList: User's posts using PostCard widget
class ProfileScreen extends StatefulWidget {
  final String? userId;
  final UserModel? user;

  const ProfileScreen({super.key, this.userId, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isMyProfile =
        widget.user == null || widget.user?.id == currentUser?.id;
    final user = isMyProfile ? currentUser : widget.user;
    final isDoctor = user?.role.name == 'doctor';
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── 1. Header Section ─────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
              name: user?.name ?? 'User',
              role: isDoctor ? l10n.roleDoctor : l10n.roleParent,
              isDoctor: isDoctor,
              photoUrl: user?.avatarUrl,
              followers: user?.followersCount ?? 128,
              following: user?.followingCount ?? 64,
              isMyProfile: isMyProfile,
              isFollowing: _isFollowing,
              onToggleFollow: () {
                setState(() {
                  _isFollowing = !_isFollowing;
                });
              },
              onEditProfile: () {
                Navigator.pushNamed(context, RouteNames.editProfile);
              },
              onSettings: () {
                Navigator.pushNamed(context, RouteNames.settings);
              },
              onSignOut: () {
                authProvider.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (route) => false,
                );
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
                            icon: Icons.qr_code_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            title: l10n.generateNewCode,
                            subtitle: l10n.generateCodeSubtitle,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => GenerateCodeDialog(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildQuickAction(
                            icon: Icons.local_hospital_rounded,
                            iconColor: const Color(0xFF22C55E),
                            title: l10n.clinicInfo,
                            subtitle: l10n.editClinicInfo,
                            onTap: () {
                              final controller =
                                  TextEditingController(text: 'Al-Amal Clinic');
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
                                          border: const OutlineInputBorder(),
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
                                              content: Text(l10n.dataUpdated)),
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
                            icon: Icons.person_add_alt_1_rounded,
                            iconColor: AppColors.primary,
                            title: l10n.joinDoctor,
                            subtitle: l10n.joinDoctorSubtitle,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RouteNames.doctorRequest);
                            },
                          ),
                          const SizedBox(height: 8),
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
                                  context, RouteNames.editProfile);
                            },
                          ),
                        ],
                ),
              ),
            ),

          // ── 2. My Posts List ────────────────────────────
          // Directly showing the list without TabBar since we removed Media tab
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Title for the section
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        l10n.myPosts,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.headlineMedium?.color,
                        ),
                      ),
                    );
                  }
                  return PostCard(post: _myPosts[index - 1]);
                },
                childCount: _myPosts.length + 1,
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
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
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
              size: 20,
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
  final String? photoUrl;
  final int followers;
  final int following;
  final bool isMyProfile;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.isDoctor,
    this.photoUrl,
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
    const double gradientHeight = 140;
    const double avatarRadius = 50;
    const double avatarOverlap = 30;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // ── Gradient + Avatar Stack ───────────────────────
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Gradient Background
            Column(
              children: [
                Container(
                  height: gradientHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: isMyProfile
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMyProfile)
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          if (isMyProfile) ...[
                            // Settings icon
                            IconButton(
                              onPressed: onSettings,
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            // Sign out
                            IconButton(
                              onPressed: onSignOut,
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Spacer for the overlapping avatar
                const SizedBox(height: avatarRadius - avatarOverlap + 16),
              ],
            ),

            // Overlapping Avatar
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: theme.scaffoldBackgroundColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.light
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AvatarWidget(
                  size: avatarRadius * 2,
                  imageUrl: photoUrl,
                  fallbackIcon: isDoctor
                      ? Icons.medical_services_rounded
                      : Icons.person_rounded,
                ),
              ),
            ),
          ],
        ),

        // ── Name, Role Badge ──────────────────────────────
        Container(
          width: double.infinity,
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            children: [
              // Name
              Text(
                name,
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.displayMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Role Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDoctor
                      ? AppColors.secondary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDoctor
                          ? Icons.medical_services_outlined
                          : Icons.child_care_rounded,
                      size: 14,
                      color: isDoctor
                          ? AppColors.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDoctor
                            ? AppColors.primary
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Stats Row ─────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.followers);
                      },
                      child:
                          _StatItem(label: l10n.followers, value: '$followers'),
                    ),
                    _divider(theme),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.following);
                      },
                      child:
                          _StatItem(label: l10n.following, value: '$following'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Action Buttons ────────────────────────────
              if (isMyProfile)
                Row(
                  children: [
                    // Edit Profile (Outlined)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditProfile,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l10n.editProfile),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Share Profile
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(const ClipboardData(
                              text: 'https://lumo.app/u/username'));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.profileLinkCopied)),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.share_outlined,
                          color: theme.iconTheme.color,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    // Follow Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onToggleFollow,
                        icon: Icon(
                          isFollowing
                              ? Icons.check_circle_outline
                              : Icons.person_add_alt_1_rounded,
                          size: 18,
                        ),
                        label: Text(isFollowing ? l10n.unfollow : l10n.follow),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFollowing ? theme.cardColor : AppColors.primary,
                          foregroundColor:
                              isFollowing ? AppColors.primary : Colors.white,
                          side: isFollowing
                              ? const BorderSide(color: AppColors.primary)
                              : null,
                          elevation: isFollowing ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Message Button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // TODO: Navigate to message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('ميزة المحادثة قريباً')),
                          );
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: theme.iconTheme.color,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 32,
      color: theme.dividerColor,
    );
  }
}

/// Individual stat item (Followers / Following / Posts)
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.displaySmall?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

// ── Mock User Posts ────────────────────────────────────────────
final List<MockPost> _myPosts = [
  MockPost(
    id: 'my-1',
    authorName: 'المستخدم',
    authorRole: 'parent',
    timeAgo: 'منذ ساعة',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1708300000000),
    content:
        'تجربتي مع التطبيق رائعة جداً! ساعدني في متابعة صحة ابني بشكل مستمر والتواصل مع الأطباء المتخصصين. أنصح كل الآباء والأمهات بتجربته.',
    likesCount: 32,
    commentsCount: 8,
  ),
  MockPost(
    id: 'my-2',
    authorName: 'المستخدم',
    authorRole: 'parent',
    timeAgo: 'منذ 3 أيام',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1708000000000),
    content:
        'الحمد لله ابني بدأ يتحسن في النطق بعد جلسات التخاطب المنتظمة. شكراً لكل الأطباء الذين ساعدونا!',
    imageUrl: 'placeholder',
    likesCount: 56,
    commentsCount: 14,
  ),
  MockPost(
    id: 'my-3',
    authorName: 'المستخدم',
    authorRole: 'parent',
    timeAgo: 'منذ أسبوع',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1707500000000),
    content:
        'هل يوجد مركز متخصص لعلاج تأخر النمو في مدينتكم؟ أرجو المشاركة بتجاربكم 🙏',
    likesCount: 18,
    commentsCount: 22,
  ),
  MockPost(
    id: 'my-4',
    authorName: 'المستخدم',
    authorRole: 'parent',
    timeAgo: 'منذ أسبوعين',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1707000000000),
    content:
        'نصيحة مهمة: التدخل المبكر في علاج أي مشاكل تطورية عند الأطفال يصنع فرقاً كبيراً. لا تؤجلوا الزيارة للطبيب المتخصص.',
    likesCount: 89,
    commentsCount: 31,
  ),
];
