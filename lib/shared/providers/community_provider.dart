import 'package:flutter/material.dart';
import '../../features/community/models/mock_post.dart';

class CommunityProvider with ChangeNotifier {
  final List<MockPost> _posts = [
    MockPost(
      id: '1',
      authorName: 'د. سارة أحمد',
      authorRole: 'doctor',
      timeAgo: 'منذ ساعتين',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      content:
          'نصائح مهمة لتطوير مهارات النطق لدى الأطفال: \n١- التحدث مع الطفل باستمرار\n٢- قراءة القصص المصورة\n٣- تشجيع الطفل على التعبير عن احتياجاته',
      likesCount: 24,
      commentsCount: 5,
      isLiked: true,
    ),
    MockPost(
      id: '2',
      authorName: 'أم محمد',
      authorRole: 'parent',
      timeAgo: 'منذ ٤ ساعات',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      content:
          'ابني يواجه صعوبة في التواصل البصري، هل من تمارين منزلية مقترحة؟ شكراً لكم جميعاً 🌸',
      likesCount: 12,
      commentsCount: 8,
    ),
    MockPost(
      id: '3',
      authorName: 'د. خالد العمري',
      authorRole: 'doctor',
      timeAgo: 'منذ يوم',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      content:
          'سعيد جداً بنتايج الأطفال هذا الشهر. التقدم ملحوظ والاستجابة للجلسات ممتازة. استمروا في المتابعة المنزلية فهي أساس العلاج.',
      imageUrl: 'placeholder_image',
      likesCount: 56,
      commentsCount: 14,
    ),
  ];

  List<MockPost> get posts => _posts;

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      notifyListeners();
    }
  }

  void addComment(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        commentsCount: post.commentsCount + 1,
      );
      notifyListeners();
    }
  }

  void addCommentToPost(String postId,
      {required String authorName,
      required String content,
      required bool isDoctor}) {
    // In a real app we'd add the comment to a subcollection.
    // Here we just increment the counter to mock it, as MockPost doesn't store comment arrays.
    addComment(postId);
  }

  void clearState() {
    _posts.clear();
    notifyListeners();
  }

  void addPost({
    required String authorName,
    required String authorRole,
    required String content,
    String? imageUrl,
  }) {
    final newPost = MockPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: authorName,
      authorRole: authorRole,
      timeAgo: 'الآن',
      timestamp: DateTime.now(),
      content: content,
      imageUrl: imageUrl,
      likesCount: 0,
      commentsCount: 0,
    );
    _posts.insert(0, newPost);
    notifyListeners();
  }
}
