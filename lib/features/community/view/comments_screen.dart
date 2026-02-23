import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/community_provider.dart';
import 'package:provider/provider.dart';

/// CommentsScreen — shows a list of dummy comments + input field.
class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  final List<_Comment> _comments = [
    _Comment(
      author: 'د. سارة أحمد',
      text: 'معلومات رائعة ومفيدة جداً، شكراً للمشاركة! 👏',
      timeAgo: 'منذ ساعة',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isDoctor: true,
    ),
    _Comment(
      author: 'محمد خالد',
      text: 'هل يمكنك مشاركة المزيد من التفاصيل؟',
      timeAgo: 'منذ ساعتين',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isDoctor: false,
    ),
    _Comment(
      author: 'فاطمة علي',
      text: 'تجربة ملهمة، شكراً لك ❤️',
      timeAgo: 'منذ 3 ساعات',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isDoctor: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final userName = userProvider.user?.name ?? 'أنت';
    final userRole = userProvider.user?.role.name ?? 'parent';
    final isDoctor = userRole == 'doctor';

    setState(() {
      _comments.insert(
        0,
        _Comment(
          author: userName,
          text: text,
          timeAgo: 'الآن',
          timestamp: DateTime.now(),
          isDoctor: isDoctor,
        ),
      );
    });

    // Update the counter in the main mock feed
    context.read<CommunityProvider>().addCommentToPost(
          widget.postId,
          authorName: userName,
          content: text,
          isDoctor: isDoctor,
        );

    _controller.clear();
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
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد تعليقات بعد',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return _CommentTile(comment: c);
                    },
                  ),
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
                    child: IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                      padding: EdgeInsets.zero,
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

// ── Comment Data ──────────────────────────────────────────────

class _Comment {
  final String author;
  final String text;
  final String timeAgo;
  final DateTime timestamp;
  final bool isDoctor;

  const _Comment({
    required this.author,
    required this.text,
    required this.timeAgo,
    required this.timestamp,
    required this.isDoctor,
  });
}

// ── Comment Tile ─────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                fallbackIcon: comment.isDoctor
                    ? Icons.medical_services_rounded
                    : Icons.person_rounded,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (comment.isDoctor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'طبيب',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      comment.timeAgo,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: AppTextStyles.body.copyWith(fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
