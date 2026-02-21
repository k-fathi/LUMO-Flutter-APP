import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../l10n/app_localizations.dart';
import '../view/comments_screen.dart';
import '../models/mock_post.dart';
import '../../../shared/providers/community_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' show Bidi;
import '../../../data/models/doctor_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// PostCard Widget - Matches Figma Screen 6 Spec
///
/// - Header: CircleAvatar, Name, Time, Role Badge
/// - Body: Text content (max 3 lines + Read More), Optional Image
/// - Footer: Like (Heart), Comment (Message), Share
class PostCard extends StatefulWidget {
  final MockPost post;
  final VoidCallback? onDelete;

  const PostCard({super.key, required this.post, this.onDelete});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDoctor = post.authorRole == 'doctor';
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // Avatar + Name wrapped in InkWell
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final isDoc = post.authorRole == 'doctor';
                      final mockUser = isDoc
                          ? DoctorModel(
                              id: 'mock_author_${post.id}',
                              email: 'author@demo.com',
                              name: post.authorName,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              specialization: 'استشاري',
                              licenseNumber: '12345',
                              yearsOfExperience: 5,
                            )
                          : ParentModel(
                              id: 'mock_author_${post.id}',
                              email: 'author@demo.com',
                              name: post.authorName,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              childName: 'طفل',
                              childAge: 5,
                            );

                      Navigator.pushNamed(
                        context,
                        RouteNames.profile,
                        arguments: {'user': mockUser},
                      );
                    },
                    child: Row(
                      children: [
                        // Avatar
                        AvatarWidget(
                          size: 40,
                          imageUrl: post.authorAvatar,
                          fallbackIcon: post.authorRole == 'doctor'
                              ? Icons.medical_services_rounded
                              : Icons.person_rounded,
                        ),
                        const SizedBox(width: 12),

                        // Name + Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      post.authorName,
                                      style: AppTextStyles.label.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Role Badge
                                  _RoleBadge(isDoctor: isDoctor),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeago.format(post.timestamp, locale: locale),
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Options menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.pushNamed(
                        context,
                        RouteNames.createPost,
                        arguments: {'content': post.content},
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $value')),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    final authProvider = context.read<AuthProvider>();
                    // For mock posts, we don't have real IDs to compare with authUser.
                    // We'll simulate by checking if authorName contains 'المستخدم' (Client-side hack for now)
                    // or if it's the current user.
                    final isMe = post.authorName ==
                            (authProvider.currentUser?.name ?? 'User') ||
                        post.authorName == 'User' ||
                        post.authorName == 'المستخدم';

                    return isMe
                        ? [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(l10n.delete,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ]
                        : [
                            PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  const Icon(Icons.flag, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.report),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'hide',
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_off, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.hide),
                                ],
                              ),
                            ),
                          ];
                  },
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content with Read More
                _buildTextContent(post.content, l10n),

                // Optional Image
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.brightness == Brightness.light
                          ? AppColors.secondary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Divider ─────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),

          // ── Footer ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like
                Consumer<CommunityProvider>(
                  builder: (context, provider, child) {
                    final currentPost = provider.posts.firstWhere(
                      (p) => p.id == post.id,
                      orElse: () => post,
                    );
                    final isLiked = currentPost.isLiked;

                    return _ActionButton(
                      icon: isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      label: '${currentPost.likesCount}',
                      color: isLiked
                          ? AppColors.destructive
                          : theme.textTheme.bodySmall?.color ??
                              AppColors.mutedForeground,
                      onTap: () => provider.toggleLike(post.id),
                    );
                  },
                ),

                // Comment
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.commentsCount}',
                  color: theme.textTheme.bodySmall?.color ??
                      AppColors.mutedForeground,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(postId: post.id),
                      ),
                    );
                  },
                ),

                // Share
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: l10n.share,
                  color: theme.textTheme.bodySmall?.color ??
                      AppColors.mutedForeground,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.linkCopied),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(String content, AppLocalizations l10n) {
    const maxLines = 3;
    final isRtl = Bidi.detectRtlDirectionality(content);
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final textAlign = isRtl ? TextAlign.right : TextAlign.left;

    final textWidget = SizedBox(
      width: double.infinity,
      child: Text(
        content,
        style: AppTextStyles.body.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        textDirection: textDirection,
        textAlign: textAlign,
        maxLines: _isExpanded ? null : maxLines,
        overflow: _isExpanded ? null : TextOverflow.ellipsis,
      ),
    );

    // Check if text needs "Read More"
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
              text: content,
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
          maxLines: maxLines,
          textDirection: textDirection,
        )..layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines && !_isExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textWidget,
              GestureDetector(
                onTap: () => setState(() => _isExpanded = true),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.readMore,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return textWidget;
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.deletePostTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deletePostConfirm,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.postDeleted),
                  backgroundColor: AppColors.destructive,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.yesDelete),
          ),
        ],
      ),
    );
  }
}

/// Role Badge - Small elegant badge
class _RoleBadge extends StatelessWidget {
  final bool isDoctor;

  const _RoleBadge({required this.isDoctor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDoctor
            ? AppColors.secondary // #E3F2FD for doctor
            : theme.colorScheme.surfaceContainerHighest, // Dynamic for parent
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDoctor ? l10n.roleDoctor : l10n.roleParent,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDoctor
              ? AppColors.primary // #2196F3
              : theme.textTheme.bodySmall?.color ?? AppColors.mutedForeground,
        ),
      ),
    );
  }
}

/// Action Button - Footer icon button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
