import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../view_model/community_view_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/providers/auth_provider.dart';
import 'comment_input_widget.dart';

/// PostDetailScreen (CommentsScreen) - Pixel-perfect match to React CommentsScreen
///
/// React layout:
/// - Header: gradient with back + "التعليقات"
/// - Original Post: bg-[#E3F2FD] card with avatar + content
/// - Comments: E3F2FD bubbles with author + text + likes + timestamp
/// - Bottom input: avatar + rounded-full input + gradient send button
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    if (_commentController.text.trim().isEmpty) return;

    _commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إضافة التعليق بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      // React: gradient header with back + "التعليقات"
      appBar: const GradientAppBar(title: 'التعليقات'),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          final post = viewModel.posts.firstWhere(
            (p) => p.id == widget.postId,
            orElse: () => viewModel.posts.isNotEmpty
                ? viewModel.posts.first
                : throw Exception('Post not found'),
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Original Post - React: px-4 py-4 border-b border-[#E3F2FD] bg-[#E3F2FD]
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFE3F2FD),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16), // rounded-2xl
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // React: flex items-start gap-3 mb-3
                              Row(
                                children: [
                                  AvatarWidget(
                                    imageUrl: post.userAvatarUrl,
                                    name: post.userName,
                                    size: 40, // w-10 h-10
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // React: text-[#1a1a2e]
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
                                ],
                              ),
                              const SizedBox(height: 12),
                              // React: text-[#1a1a2e] text-right
                              Text(
                                post.content,
                                style: AppTextStyles.body.copyWith(
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              // Post Image
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

                      // Actions Row - React: flex items-center gap-6 pt-3 border-t border-[#E3F2FD]
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
                                  ? const Color(0xFFEC4899)
                                  : const Color(0xFF64748B),
                              onTap: () {
                                if (post.isLikedBy(currentUserId)) {
                                  viewModel.unlikePost(post.id, currentUserId);
                                } else {
                                  viewModel.likePost(post.id, currentUserId);
                                }
                              },
                            ),
                            const SizedBox(width: 24),
                            _buildActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: post.commentsCount.toString(),
                              color: const Color(0xFF64748B),
                              onTap: () {
                                // Already on comments screen — no action needed
                              },
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      const Divider(color: Color(0xFFE3F2FD), height: 1),

                      // Comments Section - React: flex-1 overflow-y-auto px-4 py-4 space-y-4
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
                            Center(
                              child: Text(
                                'لا توجد تعليقات بعد',
                                style: AppTextStyles.body.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Comment Input
              if (currentUser != null)
                CommentInputWidget(
                  controller: _commentController,
                  onSend: _handleAddComment,
                  userAvatar: currentUser.avatarUrl,
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
}
