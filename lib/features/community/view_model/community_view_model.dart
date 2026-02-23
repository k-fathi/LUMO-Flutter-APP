import 'package:flutter/material.dart';

import '../../../data/models/post_model.dart';
import '../../../data/repositories/community_repository.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityViewModel(this._repository);

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load posts
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use stream subscription for real-time updates
      _repository.streamPosts().listen((postsList) {
        _posts = postsList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'فشل تحميل المنشورات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create post
  Future<bool> createPost({
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final post = await _repository.createPost(
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        content: content,
        imageUrl: imageUrl,
      );
      _posts.insert(0, post);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إنشاء المنشور: $e';
      notifyListeners();
      return false;
    }
  }

  // Update post
  Future<bool> updatePost({
    required String postId,
    String? content,
    String? imageUrl,
  }) async {
    try {
      await _repository.updatePost(postId,
          content: content, imageUrl: imageUrl);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1 && content != null) {
        _posts[index] = _posts[index].copyWith(content: content);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'فشل تحديث المنشور: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل حذف المنشور: $e';
      notifyListeners();
      return false;
    }
  }

  // Like post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _repository.likePost(postId, userId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final updatedLikedBy = List<String>.from(post.likedByUserIds)
          ..add(userId);
        _posts[index] = post.copyWith(
          likedByUserIds: updatedLikedBy,
          likesCount: post.likesCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'فشل الإعجاب: $e';
      notifyListeners();
    }
  }

  // Unlike post
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _repository.unlikePost(postId, userId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final updatedLikedBy = List<String>.from(post.likedByUserIds)
          ..remove(userId);
        _posts[index] = post.copyWith(
          likedByUserIds: updatedLikedBy,
          likesCount: (post.likesCount - 1).clamp(0, post.likesCount),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'فشل إلغاء الإعجاب: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
