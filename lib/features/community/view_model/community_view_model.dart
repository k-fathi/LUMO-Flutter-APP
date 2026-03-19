import 'package:flutter/material.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/community_repository.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityViewModel(this._repository);

  List<PostModel> _posts = [];
  List<PostModel> _followingPosts = [];
  List<PostModel> _myPosts = [];
  List<CommentModel> _comments = [];
  List<UserModel> _searchResults = [];
  List<int> _followedUserIds = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  CommentModel? _replyingToComment;
  int? _currentUserId;

  List<PostModel> get posts => _posts;
  List<PostModel> get followingPosts => _followingPosts;
  List<PostModel> get myPosts => _myPosts;
  List<CommentModel> get comments => _comments;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  CommentModel? get replyingToComment => _replyingToComment;

  void setReplyingTo(CommentModel? comment) {
    _replyingToComment = comment;
    notifyListeners();
  }

  bool isFollowing(int userId) => _followedUserIds.contains(userId);

  PostModel? findPostById(int id) {
    // Search in all lists
    for (var list in [_posts, _followingPosts, _myPosts]) {
      final index = list.indexWhere((p) => p.id == id);
      if (index != -1) return list[index];
    }
    return null;
  }

  // Fetch all posts/feeds
  Future<void> fetchPosts({bool force = false, int? userId}) async {
    // 1. Check for User Change
    if (userId != null && userId != _currentUserId) {
      _currentUserId = userId;
      _isInitialized = false;
      _posts = [];
      _followingPosts = [];
      _myPosts = [];
      force = true; // Force reload for new user
    } else if (userId != null) {
      _currentUserId = userId;
    }

    // 2. If already initialized and not forcing, don't show full loading again
    if (_isInitialized && !force && _posts.isNotEmpty) {
      // Background refresh
      _loadAllFeeds(rethrowError: false);
      return;
    }

    // Ensure _isInitialized is false if we are here and force is true
    if (force) _isInitialized = false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadAllFeeds(rethrowError: true);
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'فشل تحميل المنشورات: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to load all feeds without individual loading states
  Future<void> _loadAllFeeds({bool rethrowError = false}) async {
    try {
      // 1. Load my posts first so they are available for merging into home feed
      await _loadMyPostsInternal(page: 1);
      
      // 2. Load other feeds in parallel
      await Future.wait([
        _loadHomeFeedInternal(page: 1),
        _loadFollowingFeedInternal(page: 1),
      ]);
    } catch (e) {
      if (rethrowError) rethrow;
    }
  }

  // Internal versions that don't trigger global loading state
  Future<void> _loadHomeFeedInternal({int page = 1}) async {
    final feed = await _repository.getHomeFeed(page: page);
    if (page == 1) {
      final List<PostModel> merged = [...feed];
      for (var myPost in _myPosts) {
        if (!merged.any((p) => p.id == myPost.id)) {
          merged.insert(0, myPost);
        }
      }
      _posts = merged;
    } else {
      _posts.addAll(feed);
    }
  }

  Future<void> _loadFollowingFeedInternal({int page = 1}) async {
    final followingUsers = await _repository.getFollowingUsers();
    _followedUserIds = followingUsers.map((u) => u.id).toList();

    final feed = await _repository.getHomeFeed(page: page);
    final followingOnly = feed
        .where((post) =>
            _followedUserIds.contains(post.userId) ||
            (_currentUserId != null && post.userId == _currentUserId))
        .toList();

    if (page == 1) {
      _followingPosts = followingOnly;
    } else {
      _followingPosts.addAll(followingOnly);
    }
  }

  Future<void> _loadMyPostsInternal({int page = 1}) async {
    final posts = await _repository.getMyPosts(page: page);
    if (page == 1) {
      _myPosts = posts;
    } else {
      _myPosts.addAll(posts);
    }
  }

  // Legacy alias for compatibility if needed
  Future<void> initCommunity(int? userId, {bool force = false}) async {
    return fetchPosts(force: force, userId: userId);
  }

  // Load home feed
  Future<void> loadHomeFeed({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadHomeFeedInternal(page: page);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل الخلاصة: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (rethrowError) rethrow;
    }
  }

  // Load following feed
  Future<void> loadFollowingFeed({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadFollowingFeedInternal(page: page);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل منشورات المتابعة: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (rethrowError) rethrow;
    }
  }

  // Load my posts
  Future<void> loadMyPosts({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadMyPostsInternal(page: page);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل منشوراتي: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (rethrowError) rethrow;
    }
  }

  Future<bool> createPost({
    required String content,
    String? imagePath,
    String? currentUserName,
    String? currentUserAvatar,
    int? currentUserId,
  }) async {
    _currentUserId = currentUserId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final postResponse = await _repository.createPost(
        content: content,
        imagePath: imagePath,
      );

      // Override with local current user info if provided, to ensure immediate sync
      final post = postResponse.copyWith(
        userName: currentUserName ?? postResponse.userName,
        userAvatarUrl: currentUserAvatar ?? postResponse.userAvatarUrl,
        userId: currentUserId ?? postResponse.userId,
      );

      _posts.insert(0, post);
      _myPosts.insert(0, post);

      // Also add to following feed (which includes own posts)
      _followingPosts.insert(0, post);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update author info across all local lists
  void updateAuthorInfoInPosts(int userId, String name, String? avatarUrl) {
    void updateList(List<PostModel> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].userId == userId) {
          list[i] = list[i].copyWith(userName: name, userAvatarUrl: avatarUrl);
        }
      }
    }

    updateList(_posts);
    updateList(_followingPosts);
    updateList(_myPosts);
    notifyListeners();
  }

  // Delete Post - Bug 3
  Future<void> deletePost(int postId) async {
    try {
      await _repository.deletePost(postId);
      _removePostEverywhere(postId);
    } catch (e) {
      _errorMessage = 'فشل حذف المنشور';
      notifyListeners();
    }
  }

  // Update Post - Bug 3
  Future<void> updatePost(int postId, String newContent, {String? imagePath}) async {
    try {
      final updated = await _repository.updatePost(postId, content: newContent, imagePath: imagePath);
      _updatePostEverywhere(updated);
    } catch (e) {
      _errorMessage = 'فشل تعديل المنشور';
      notifyListeners();
    }
  }
  // Toggle Like - Bug 2
  Future<void> toggleLike(int postId) async {
    // 1. Find the post in any list
    PostModel? post = findPostById(postId);
    if (post == null) return;

    final wasLiked = post.isLiked;

    // 2. Optimistic update — flip immediately in UI
    final updatedPost = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    _updatePostEverywhere(updatedPost);
    notifyListeners();

    // 3. Call the API
    try {
      await _repository.toggleLike(postId);
      // API call succeeded — optimistic update stays
    } catch (e) {
      // 4. Rollback on failure
      _updatePostEverywhere(post); // restore original
      _errorMessage = 'فشل تسجيل الإعجاب، حاول مرة أخرى';
      notifyListeners();
    }
  }

  // Comments
  Future<void> fetchPostById(int postId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final post = await _repository.getPostById(postId);
      _updatePostEverywhere(post); // Update local lists if post is already there or was missing
      
      // If the post wasn't in any list, _updatePostEverywhere won't add it.
      // We should ensure it's at least available for findPostById.
      if (findPostById(postId) == null) {
        _posts.add(post);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل المنشور: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _comments = await _repository.getComments(postId);
    } catch (e) {
      _errorMessage = 'فشل تحميل التعليقات: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment(int postId, String content) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addComment(postId, content, parentId: _replyingToComment?.id);
      
      // Clear reply state after successful comment
      _replyingToComment = null;

      // Refresh comments
      await fetchComments(postId);

      // Update comment count in all post lists
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final updatedPost = _posts[postIndex].copyWith(
          commentsCount: _posts[postIndex].commentsCount + 1,
        );
        _updatePostEverywhere(updatedPost);
      }

      return true;
    } catch (e) {
      _errorMessage = 'فشل إضافة التعليق: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Comment Like
  Future<void> toggleCommentLike(int commentId, int currentUserId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = _comments[index];
    final isLiked = comment.isLikedBy(currentUserId);
    
    try {
      // Optimistic Update
      final updatedComment = comment.copyWith(
        isLiked: !isLiked,
        likesCount: !isLiked ? comment.likesCount + 1 : comment.likesCount - 1,
      );
      
      _comments[index] = updatedComment;
      notifyListeners();

      await _repository.toggleCommentLike(commentId);
    } catch (e) {
      _errorMessage = 'فشل التفاعل مع التعليق: ${e.toString()}';
      
      // Revert optimistic update
      _comments[index] = comment;
      notifyListeners();
    }
  }

  // ==================== HELPERS ====================

  void _updatePostEverywhere(PostModel updatedPost) {
    void updateList(List<PostModel> list) {
      final index = list.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        list[index] = updatedPost;
      }
    }

    updateList(_posts);
    updateList(_followingPosts);
    updateList(_myPosts);
    notifyListeners();
  }

  void _removePostEverywhere(int postId) {
    void removeFromList(List<PostModel> list) {
      list.removeWhere((p) => p.id == postId);
    }

    removeFromList(_posts);
    removeFromList(_followingPosts);
    removeFromList(_myPosts);
    notifyListeners();
  }

  // Social
  Future<void> toggleFollow(int userId, {int? currentUserId}) async {
    final isFollowing = _followedUserIds.contains(userId);
    try {
      // 1. Optimistic update for local list
      if (isFollowing) {
        _followedUserIds.remove(userId);
      } else {
        _followedUserIds.add(userId);
      }
      notifyListeners();

      // 2. Call REST API (with Firebase sync if currentUserId is provided)
      await _repository.toggleFollow(userId, currentUserId: currentUserId);

      // 3. Background refresh of following feed to ensure UI consistency
      _loadFollowingFeedInternal(page: 1);
    } catch (e) {
      // Revert optimistic update
      if (isFollowing) {
        _followedUserIds.add(userId);
      } else {
        _followedUserIds.remove(userId);
      }
      _errorMessage = 'فشل متابعة المستخدم: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query, {String? role}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _searchResults = await _repository.searchUsers(query, role: role);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل البحث: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
