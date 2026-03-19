import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../view_model/community_view_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import 'comment_input_widget.dart';

/// PostDetailScreen (CommentsScreen) - Pixel-perfect match to React CommentsScreen
class PostDetailScreen extends StatefulWidget {
  final int postId;
  final PostModel? initialPost;

  const PostDetailScreen({super.key, required this.postId, this.initialPost});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CommunityViewModel>();
      viewModel.fetchComments(widget.postId);
      
      // If post is not found locally, fetch it
      if (viewModel.findPostById(widget.postId) == null && widget.initialPost == null) {
        viewModel.fetchPostById(widget.postId);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final viewModel = context.read<CommunityViewModel>();
    final success = await viewModel.addComment(widget.postId, content);

    if (success && mounted) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة التعليق بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'فشل إضافة التعليق'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final int currentUserId = currentUser?.id ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GradientAppBar(title: 'التعليقات'),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          final post = viewModel.findPostById(widget.postId) ?? widget.initialPost;
          
          if (post == null) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ?? 'لم يتم العثور على المنشور',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchPostById(widget.postId);
                        viewModel.fetchComments(widget.postId);
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Original Post
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFE3F2FD),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AvatarWidget(
                                    imageUrl: post.userAvatarUrl,
                                    name: post.userName,
                                    size: 40,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.profile,
                                        arguments: {
                                        'userId': post.userId,
                                        'user': UserModel(
                                          id: post.userId,
                                          name: post.userName,
                                          avatarUrl: post.userAvatarUrl,
                                          email: '',
                                          role: UserRole.parent,
                                        ),
                                      },
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.profile,
                                          arguments: {
                                            'userId': post.userId,
                                            'user': UserModel(
                                              id: post.userId,
                                              name: post.userName,
                                              avatarUrl: post.userAvatarUrl,
                                              email: '',
                                              role: UserRole.parent,
                                            ),
                                          },
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.userName,
                                            style: AppTextStyles.body.copyWith(
                                              color: const Color(0xFF1A1A2E),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormatter.formatRelativeTime(
                                                post.createdAt),
                                            style: AppTextStyles.caption.copyWith(
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                post.content,
                                style: AppTextStyles.body.copyWith(
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              if (post.hasImage && post.imageUrl != null) ...[
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    post.imageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Actions Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            _buildActionButton(
                               icon: post.isLikedBy(currentUserId)
                                   ? Icons.favorite_rounded
                                   : Icons.favorite_outline_rounded,
                               label: post.likesCount.toString(),
                               color: post.isLikedBy(currentUserId)
                                   ? const Color(0xFFEF4444)
                                   : const Color(0xFF64748B),
                               onTap: () =>
                                   viewModel.toggleLike(post.id),
                            ),
                            const SizedBox(width: 24),
                            _buildActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: post.commentsCount.toString(),
                              color: const Color(0xFF64748B),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFFE3F2FD), height: 1),

                      // Comments Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التعليقات',
                              style: AppTextStyles.h3.copyWith(
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (viewModel.isLoading &&
                                viewModel.comments.isEmpty)
                              const Center(child: CircularProgressIndicator())
                            else if (viewModel.comments.isEmpty)
                              const Center(child: Text('لا توجد تعليقات بعد'))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: viewModel.comments.length,
                                itemBuilder: (context, index) {
                                  final comment = viewModel.comments[index];
                                  final isLiked = comment.likedByUserIds.contains(currentUserId);
                                  final isReply = comment.isReply;

                                  return Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      bottom: 12,
                                      start: isReply ? 45.0 : 0.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isReply) ...[
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Icon(Icons.subdirectory_arrow_left_rounded, size: 16, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        AvatarWidget(
                                          imageUrl: comment.userAvatarUrl,
                                          name: comment.userName,
                                          size: isReply ? 28 : 32,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              RouteNames.profile,
                                              arguments: {'userId': comment.userId},
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () => _navigateToProfile(context, comment),
                                                  behavior: HitTestBehavior.opaque,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        comment.userName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        comment.content,
                                                        style: const TextStyle(fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => viewModel.toggleCommentLike(comment.id, currentUserId),
                                                    child: Text(
                                                      'إعجاب',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                                        color: isLiked ? Colors.blue : const Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  GestureDetector(
                                                    onTap: () {
                                                      viewModel.setReplyingTo(comment);
                                                      _commentFocusNode.requestFocus();
                                                    },
                                                    child: const Text(
                                                      'رد',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text(
                                                    DateFormatter.formatRelativeTime(comment.createdAt),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                  if (comment.likesCount > 0) ...[
                                                    const Spacer(),
                                                    const Icon(Icons.favorite_rounded, size: 12, color: Colors.pink),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${comment.likesCount}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Reply Bar
              if (viewModel.replyingToComment != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Text(
                        'الرد على ${viewModel.replyingToComment!.userName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => viewModel.setReplyingTo(null),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              // Comment Input
              if (currentUser != null)
                CommentInputWidget(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  onSend: _handleAddComment,
                  isLoading: viewModel.isLoading,
                  userAvatar: currentUser.profileImage,
                  userName: currentUser.name,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, dynamic model) {
    final userId = model is PostModel ? model.userId : (model as CommentModel).userId;
    final userName = model is PostModel ? model.userName : (model as CommentModel).userName;
    final userAvatarUrl = model is PostModel ? model.userAvatarUrl : (model as CommentModel).userAvatarUrl;

    Navigator.pushNamed(
      context,
      RouteNames.profile,
      arguments: {
        'userId': userId,
        'user': UserModel(
          id: userId,
          name: userName,
          avatarUrl: userAvatarUrl,
          email: '',
          role: UserRole.parent,
        ),
      },
    );
  }
}
