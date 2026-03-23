import 'package:flutter/material.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/di/dependency_injection.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityViewModel(this._repository);

  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  List<PostModel> _posts = [];
  List<PostModel> _explorePosts = [];
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
  List<PostModel> get explorePosts => _explorePosts;
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
    _safeNotify();
  }

  bool isFollowing(int userId) => _followedUserIds.contains(userId);

  PostModel? findPostById(int id) {
    // Search in all lists
    for (var list in [_explorePosts, _posts, _followingPosts, _myPosts]) {
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
      _explorePosts = [];
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
    _safeNotify();

    try {
      await _loadAllFeeds(rethrowError: true);
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'فشل تحميل المنشورات: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // Helper to load all feeds without individual loading states
  Future<void> _loadAllFeeds({bool rethrowError = false}) async {
    try {
      // 1. Load my posts first so they are available for merging into home feed
      await _loadMyPostsInternal(page: 1);
      
      // 2. Load other feeds in parallel
      await Future.wait([
        _loadHomeFeedInternal(page: 1), // Legacy /home
        _loadExploreFeedInternal(page: 1), // New /home/all
        _loadFollowingFeedInternal(page: 1), // New /home
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

  Future<void> _loadExploreFeedInternal({int page = 1}) async {
    final feed = await _repository.getExploreFeed(page: page);
    if (page == 1) {
      _explorePosts = feed;
      // Keep _posts in sync with explore if _posts is used as the default feed
      _posts = feed;
    } else {
      _explorePosts.addAll(feed);
      _posts.addAll(feed);
    }
  }

  Future<void> _loadFollowingFeedInternal({int page = 1}) async {
    // The backend now provides a filtered /home feed for following
    final feed = await _repository.getHomeFeed(page: page);
    
    if (page == 1) {
      _followingPosts = feed;
    } else {
      _followingPosts.addAll(feed);
    }
    _safeNotify();
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

  // Load explore feed
  Future<void> loadExploreFeed({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await _loadExploreFeedInternal(page: page);
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل تحميل الاستكشاف: ${e.toString()}';
      _isLoading = false;
      _safeNotify();
      if (rethrowError) rethrow;
    }
  }

  // Alias for task requirement
  Future<void> fetchExplorePosts() => loadExploreFeed();

  // Load home feed (Legacy/Compatibility)
  Future<void> loadHomeFeed({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await _loadHomeFeedInternal(page: page);
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل تحميل الخلاصة: ${e.toString()}';
      _isLoading = false;
      _safeNotify();
      if (rethrowError) rethrow;
    }
  }

  // Load following feed
  Future<void> loadFollowingFeed({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await _loadFollowingFeedInternal(page: page);
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل تحميل منشورات المتابعة: ${e.toString()}';
      _isLoading = false;
      _safeNotify();
      if (rethrowError) rethrow;
    }
  }

  // Load my posts
  Future<void> loadMyPosts({int page = 1, bool rethrowError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await _loadMyPostsInternal(page: page);
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل تحميل منشوراتي: ${e.toString()}';
      _isLoading = false;
      _safeNotify();
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
    _safeNotify();
    try {
      final postResponse = await _repository.createPost(
        content: content,
        imagePath: imagePath,
      );

      // 1. Get current user from AuthProvider if not provided via arguments
      String? finalName = currentUserName;
      String? finalAvatar = currentUserAvatar;
      int? finalId = currentUserId;

      if (finalName == null || finalId == null) {
        try {
          final authProvider = getIt<AuthProvider>();
          final user = authProvider.currentUser;
          if (user != null) {
            finalName ??= user.name;
            finalAvatar ??= user.avatarUrl;
            finalId ??= user.id;
          }
        } catch (e) {
          debugPrint('Could not get AuthProvider for post injection: $e');
        }
      }

      // 2. Override with local current user info to ensure immediate sync and fix naming issues
      final post = postResponse.copyWith(
        userName: (finalName != null && finalName.isNotEmpty) 
            ? finalName 
            : (postResponse.userName.isEmpty ? 'مستخدم' : postResponse.userName),
        userAvatarUrl: finalAvatar ?? postResponse.userAvatarUrl,
        userId: finalId ?? postResponse.userId,
      );

      _posts.insert(0, post);
      _explorePosts.insert(0, post);
      _myPosts.insert(0, post);
      _followingPosts.insert(0, post);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
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
    _safeNotify();
  }

  // Delete Post - Bug 3
  Future<void> deletePost(int postId) async {
    try {
      await _repository.deletePost(postId);
      _removePostEverywhere(postId);
    } catch (e) {
      _errorMessage = 'فشل حذف المنشور';
      _safeNotify();
    }
  }

  // Update Post - Bug 3
  Future<void> updatePost(int postId, String newContent, {String? imagePath}) async {
    try {
      final updated = await _repository.updatePost(postId, content: newContent, imagePath: imagePath);
      _updatePostEverywhere(updated);
    } catch (e) {
      _errorMessage = 'فشل تعديل المنشور';
      _safeNotify();
    }
  }
  // Toggle Like - Bug 2: Fix logic and double-check counters
  Future<void> toggleLike(int postId) async {
    // 1. Find the post in any list
    PostModel? post = findPostById(postId);
    if (post == null || _currentUserId == null || _currentUserId == 0) return;

    final wasLiked = post.isLikedBy(_currentUserId!);
    final List<int> newLikedByUserIds = List.from(post.likedByUserIds);
    
    if (wasLiked) {
      newLikedByUserIds.remove(_currentUserId);
    } else {
      if (!newLikedByUserIds.contains(_currentUserId)) {
        newLikedByUserIds.add(_currentUserId!);
      }
    }

    // 2. Optimistic update — flip immediately in UI
    final int newCount = wasLiked 
        ? (post.likesCount > 0 ? post.likesCount - 1 : 0) 
        : post.likesCount + 1;

    final updatedPost = post.copyWith(
      isLiked: !wasLiked,
      likesCount: newCount,
      likedByUserIds: newLikedByUserIds,
    );
    _updatePostEverywhere(updatedPost);
    _safeNotify();

    // 3. Call the API
    try {
      await _repository.toggleLike(postId);
      // API call succeeded — optimistic update stays
    } catch (e) {
      // 4. Rollback on failure
      _updatePostEverywhere(post); // restore original
      _errorMessage = 'فشل تسجيل الإعجاب، حاول مرة أخرى';
      _safeNotify();
    }
  }

  // Comments
  Future<void> fetchPostById(int postId) async {
    _isLoading = true;
    _safeNotify();
    try {
      final post = await _repository.getPostById(postId);
      _updatePostEverywhere(post); // Update local lists if post is already there or was missing
      
      // If the post wasn't in any list, _updatePostEverywhere won't add it.
      // We should ensure it's at least available for findPostById.
      if (findPostById(postId) == null) {
        _posts.add(post);
      }
      
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل تحميل المنشور: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    _safeNotify();
    try {
      _comments = await _repository.getComments(postId);
      _sortCommentsAsTree();
    } catch (e) {
      _errorMessage = 'فشل تحميل التعليقات: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Sort comments into tree order: each parent followed by its replies
  void _sortCommentsAsTree() {
    final topLevel = _comments.where((c) => c.isTopLevel).toList();
    final replies = _comments.where((c) => c.isReply).toList();

    // Group replies by parentCommentId
    final Map<int, List<CommentModel>> replyMap = {};
    for (final reply in replies) {
      final parentId = reply.parentCommentId!;
      replyMap.putIfAbsent(parentId, () => []);
      replyMap[parentId]!.add(reply);
    }

    // Sort each group by createdAt
    for (final entry in replyMap.entries) {
      entry.value.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    // Build the final sorted list
    final List<CommentModel> sorted = [];
    for (final parent in topLevel) {
      sorted.add(parent);
      if (replyMap.containsKey(parent.id)) {
        sorted.addAll(replyMap[parent.id]!);
      }
    }

    // Add any orphaned replies (parent not in current page)
    for (final reply in replies) {
      if (!sorted.contains(reply)) {
        sorted.add(reply);
      }
    }

    _comments = sorted;
  }

  Future<bool> addComment(int postId, String content) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();
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
      _safeNotify();
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
      _safeNotify();

      await _repository.toggleCommentLike(commentId);
    } catch (e) {
      _errorMessage = 'فشل التفاعل مع التعليق: ${e.toString()}';
      
      // Revert optimistic update
      _comments[index] = comment;
      _safeNotify();
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
    updateList(_explorePosts);
    updateList(_followingPosts);
    updateList(_myPosts);
    _safeNotify();
  }

  void _removePostEverywhere(int postId) {
    void removeFromList(List<PostModel> list) {
      list.removeWhere((p) => p.id == postId);
    }

    removeFromList(_posts);
    removeFromList(_explorePosts);
    removeFromList(_followingPosts);
    removeFromList(_myPosts);
    _safeNotify();
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
      _safeNotify();

      // 2. Call REST API (with Firebase sync if currentUserId is provided)
      await _repository.toggleFollow(userId, currentUserId: currentUserId);

      // 3. Delayed background refresh — give backend time to propagate
      //    Keep a snapshot of the optimistic state so we don't overwrite it
      final optimisticIds = List<int>.from(_followedUserIds);
      Future.delayed(const Duration(seconds: 2), () async {
        if (_isDisposed) return;
        try {
          final followingUsers = await _repository.getFollowingUsers();
          if (_isDisposed) return;
          final serverIds = followingUsers.map((u) => u.id).toList();
          
          // Merge: use server data but preserve any optimistic adds not yet reflected
          _followedUserIds = serverIds;
          // If we optimistically added userId and server doesn't have it yet, keep it
          for (final id in optimisticIds) {
            if (!_followedUserIds.contains(id)) {
              _followedUserIds.add(id);
            }
          }

          final feed = await _repository.getHomeFeed(page: 1);
          if (_isDisposed) return;
          _followingPosts = feed
              .where((post) =>
                  _followedUserIds.contains(post.userId) ||
                  (_currentUserId != null && post.userId == _currentUserId))
              .toList();
          _safeNotify();
        } catch (_) {
          // Silently fail — the optimistic state is still valid
        }
      });
    } catch (e) {
      // Revert optimistic update
      if (isFollowing) {
        _followedUserIds.add(userId);
      } else {
        _followedUserIds.remove(userId);
      }
      _errorMessage = 'فشل متابعة المستخدم: ${e.toString()}';
      _safeNotify();
    }
  }

  Future<void> searchUsers(String query, {String? role}) async {
    _isLoading = true;
    _safeNotify();
    try {
      _searchResults = await _repository.searchUsers(query, role: role);
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _errorMessage = 'فشل البحث: ${e.toString()}';
      _isLoading = false;
      _safeNotify();
    }
  }

  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  /// Explicitly reset the state for logout or user change
  void resetState() {
    _posts = [];
    _followingPosts = [];
    _myPosts = [];
    _isInitialized = false;
    _currentUserId = null;
    _errorMessage = null;
    _isLoading = false;
    _safeNotify();
  }
}
