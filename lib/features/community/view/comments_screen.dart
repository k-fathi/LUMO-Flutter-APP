import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/enums/user_role.dart';


/// CommentsScreen — shows a list of dummy comments + input field.
class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityViewModel>().fetchComments(widget.postId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final viewModel = context.read<CommunityViewModel>();
    final success = await viewModel.addComment(widget.postId, text);

    if (success && mounted) {
      _controller.clear();
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: Text(
          'التعليقات',
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Column(
        children: [
          // ── Comments List ───────────────────────────────────
          Expanded(
            child: Consumer<CommunityViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (viewModel.comments.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد تعليقات بعد',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                }

                // Group comments: top-level + their immediate replies
                // Note: Currently displaying them in flat list with indentation if it's a reply
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.comments.length,
                  itemBuilder: (context, index) {
                    final c = viewModel.comments[index];
                    final isReply = c.isReply;
                    
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: 12,
                        start: isReply ? 45.0 : 0.0, // Proper indentation using start
                      ),
                      child: _CommentTile(
                        comment: c,
                        onReply: () {
                          viewModel.setReplyingTo(c);
                          _focusNode.requestFocus();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Reply Bar ─────────────────────────────────────
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.replyingToComment == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'الرد على ${viewModel.replyingToComment!.userName}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => viewModel.setReplyingTo(null),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Input Bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقاً...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Consumer<CommunityViewModel>(
                      builder: (context, viewModel, child) {
                        return IconButton(
                          onPressed: viewModel.isLoading ? null : _addComment,
                          icon: viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onReply;

  const _CommentTile({required this.comment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? 0;
    final isLiked = comment.isLikedBy(currentUserId);
    final viewModel = context.read<CommunityViewModel>();
    // Note: We don't have isDoctor locally on CommentModel, backend doesn't seem to pass it yet.
    // For now we assume a fallback or standard icon.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                size: 32,
                fallbackIcon: Icons.person_rounded, // fallback
                imageUrl: comment.userAvatarUrl,
                onTap: () => _navigateToProfile(context, comment),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(context, comment),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        DateFormatter.formatRelativeTime(comment.createdAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: AppTextStyles.body.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _CommentActionButton(
                icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                label: comment.likesCount > 0 ? '${comment.likesCount}' : 'إعجاب',
                color: isLiked ? Colors.red : AppColors.mutedForeground,
                onTap: () => viewModel.toggleCommentLike(comment.id, currentUserId),
              ),
              const SizedBox(width: 16),
              _CommentActionButton(
                icon: Icons.reply_rounded,
                label: 'رد',
                color: AppColors.mutedForeground,
                onTap: onReply,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, CommentModel comment) {
    Navigator.pushNamed(
      context,
      RouteNames.profile,
      arguments: {
        'userId': comment.userId,
        'user': UserModel(
          id: comment.userId,
          name: comment.userName,
          avatarUrl: comment.userAvatarUrl,
          email: '',
          role: UserRole.parent,
        ),
      },
    );
  }
}

class _CommentActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CommentActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
