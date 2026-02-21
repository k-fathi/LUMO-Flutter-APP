import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/elevated_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/notification_provider.dart';
import '../view_model/community_view_model.dart';

/// Posts Feed Widget - Complete social feed with full integration
class PostsFeedWidget extends StatelessWidget {
  const PostsFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunityViewModel, AuthProvider>(
      builder: (context, viewModel, authProvider, child) {
        final currentUserId = authProvider.currentUser?.id ?? '';

        // Loading state
        if (viewModel.isLoading && viewModel.posts.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerCard(),
            ),
          );
        }

        // Empty state
        if (viewModel.posts.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: const EmptyState(
                    icon: Icons.article_outlined,
                    title: 'لا توجد منشورات بعد',
                    message: 'كن أول من ينشر في المجتمع',
                  ),
                ),
              );
            },
          );
        }

        // Posts list
        return ListView.builder(
          itemCount: viewModel.posts.length,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final post = viewModel.posts[index];
            final isOwnPost = post.userId == currentUserId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedCard(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.postDetail,
                    arguments: post.id,
                  );
                },
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Post Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to user profile
                              Navigator.pushNamed(
                                context,
                                RouteNames.profile,
                                arguments: {'userId': post.userId},
                              );
                            },
                            child: AvatarWidget(
                              imageUrl: post.userAvatarUrl,
                              name: post.userName,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.userName,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormatter.formatRelativeTime(
                                      post.createdAt),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isOwnPost)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.mutedForeground,
                              ),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    RouteNames.editPost,
                                    arguments: {
                                      'id': post.id,
                                      'content': post.content,
                                      'imageUrl': post.imageUrl,
                                    },
                                  );

                                  if (result == true) {
                                    viewModel.loadPosts();
                                  }
                                } else if (value == 'delete') {
                                  final confirmed =
                                      await DeleteConfirmationDialog.show(
                                    context,
                                    title: 'حذف المنشور',
                                    message: 'هل أنت متأكد من حذف هذا المنشور؟',
                                    onConfirm: () {},
                                  );

                                  if (confirmed == true) {
                                    final success =
                                        await viewModel.deletePost(post.id);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'تم حذف المنشور'
                                                : 'فشل الحذف',
                                          ),
                                          backgroundColor: success
                                              ? AppColors.success
                                              : AppColors.destructive,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('تعديل'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outlined,
                                          color: AppColors.destructive),
                                      SizedBox(width: 8),
                                      Text('حذف',
                                          style: TextStyle(
                                              color: AppColors.destructive)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Post Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        post.content,
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Post Image
                    if (post.hasImage && post.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: AppColors.muted,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildActionButton(
                            context,
                            viewModel: viewModel,
                            post: post,
                            currentUserId: currentUserId,
                          ),
                          const SizedBox(width: 24),
                          _buildCommentButton(context, post),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required CommunityViewModel viewModel,
    required post,
    required String currentUserId,
  }) {
    final isLiked = post.isLikedBy(currentUserId);

    return InkWell(
      onTap: () async {
        if (currentUserId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يجب تسجيل الدخول للتفاعل'),
              backgroundColor: AppColors.destructive,
            ),
          );
          return;
        }

        if (isLiked) {
          await viewModel.unlikePost(post.id, currentUserId);
        } else {
          await viewModel.likePost(post.id, currentUserId);

          // Send notification to post owner
          if (context.mounted && post.userId != currentUserId) {
            context.read<NotificationProvider>().sendPostLikeNotification(
                  postId: post.id,
                  postOwnerId: post.userId,
                  likerName:
                      context.read<AuthProvider>().currentUser?.name ?? '',
                );
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              size: 20,
              color:
                  isLiked ? AppColors.destructive : AppColors.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              post.likesCount.toString(),
              style: TextStyle(
                color:
                    isLiked ? AppColors.destructive : AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, post) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.postDetail,
          arguments: post.id,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.comment_outlined,
              size: 20,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              post.commentsCount.toString(),
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
