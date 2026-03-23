import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/post_model.dart';
import '../../../shared/providers/notification_provider.dart';
import '../view_model/community_view_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isOwnProfile;
  final bool hideFollowButton;

  const PostCard({
    super.key,
    required this.post,
    this.isOwnProfile = false,
    this.hideFollowButton = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser?.id ?? 0;

    // تأكيد إنك صاحب البوست عشان يظهرلك زرار التعديل والحذف
    final isOwner = currentUserId != 0 && post.userId == currentUserId;

    // --- الفلتر الذكي الصارم ---
    String displayName = post.userName;

    // لو الباك إند باعت null كنص أو باعتها فاضية أو القيمة الاحتياطية "مستخدم"
    if (displayName.toLowerCase().contains('null') ||
        displayName.trim().isEmpty ||
        displayName == 'مستخدم') {
      if (isOwner && currentUser != null && currentUser.name.isNotEmpty) {
        displayName = currentUser.name; // خد اسمك من البروفايل بتاعك إنت
      } else {
        displayName = 'مستخدم'; // لو بوست بتاع حد تاني ومعندوش اسم
      }
    } else if (isOwner && currentUser != null && currentUser.name.isNotEmpty) {
      // حتى لو فيه اسم، لو أنا صاحب البوست، دايمًا استخدم اسمي اللي في الـ Auth عشان لو غيرته يظهر فورًا
      displayName = currentUser.name;
    }

    final String? displayAvatar =
        (isOwner && (post.userAvatarUrl == null || post.userAvatarUrl!.isEmpty))
            ? currentUser?.avatarUrl
            : post.userAvatarUrl;
    // ----------------------------

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, RouteNames.postDetail,
                arguments: post);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    AvatarWidget(
                      size: 40,
                      imageUrl: displayAvatar, // تم استخدام المتغير الذكي
                      onTap: () => _navigateToProfile(context, post),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToProfile(context, post),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName, // تم استخدام المتغير الذكي
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              DateFormatter.formatRelativeTime(post.createdAt),
                              style: AppTextStyles.caption.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // قائمة الخيارات (تظهر للكل بخيارات مختلفة)
                    if (isOwner)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.pushNamed(
                              context,
                              RouteNames.editPost,
                              arguments: post,
                            );
                          } else if (value == 'delete') {
                            final confirmed =
                                await DeleteConfirmationDialog.show(
                              context,
                              title: 'حذف المنشور',
                              message: 'هل أنت متأكد من حذف هذا المنشور؟',
                            );
                            if (confirmed == true && mounted) {
                              context
                                  .read<CommunityViewModel>()
                                  .deletePost(post.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.edit),
                            ],
                          )),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      )
                    else if (!widget.hideFollowButton && post.userId != 0)
                      Consumer<CommunityViewModel>(
                        builder: (context, viewModel, child) {
                          final isFollowing =
                              viewModel.isFollowing(post.userId);
                          
                          if (isFollowing) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            child: TextButton(
                              onPressed: () async {
                                final wasFollowing = isFollowing;
                                await viewModel.toggleFollow(
                                  post.userId,
                                  currentUserId: currentUserId,
                                );
                                if (!wasFollowing && post.userId != 0) {
                                  Future.microtask(() {
                                    if (context.mounted) {
                                      context
                                          .read<NotificationProvider>()
                                          .sendFollowNotification(
                                            targetUserId: post.userId,
                                            followerName:
                                                authProvider.currentUser?.name ??
                                                    '',
                                          );
                                    }
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.follow,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextContent(post.content, l10n),
                    if (post.hasImage && post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 200,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // Footer — reads fresh from ViewModel to fix likes scoping per user
              Consumer<CommunityViewModel>(
                builder: (context, viewModel, child) {
                  final livePost = viewModel.findPostById(post.id) ?? post;
                  final liveIsLiked = livePost.isLikedBy(currentUserId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: liveIsLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          label: '${livePost.likesCount}',
                          color: liveIsLiked ? Colors.red : Colors.grey,
                          onTap: () {
                            final wasLiked = livePost.isLikedBy(currentUserId);
                            viewModel.toggleLike(post.id);

                            if (!wasLiked &&
                                post.userId != currentUserId &&
                                post.userId != 0) {
                              context.read<NotificationProvider>().sendPostLikeNotification(
                                    postId: post.id,
                                    postOwnerId: post.userId,
                                    likerName: currentUser?.name ?? 'مستخدم',
                                  );
                            }
                          },
                        ),
                        _ActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${livePost.commentsCount}',
                          color: Colors.grey,
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.postDetail,
                                arguments: livePost);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(String content, AppLocalizations l10n) {
    if (!_isExpanded && content.length > 150) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${content.substring(0, 150)}...', style: AppTextStyles.body),
          InkWell(
            onTap: () => setState(() => _isExpanded = true),
            child: Text(
              l10n.readMore,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
    return Text(content, style: AppTextStyles.body);
  }

  void _navigateToProfile(BuildContext context, PostModel post) {
    Navigator.pushNamed(
      context,
      RouteNames.profile,
      arguments: {
        'userId': post.userId,
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
