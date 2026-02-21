import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class CommunityRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;

  CommunityRepository(this._firebaseDataSource, this._localDataSource);

  // ==================== POST OPERATIONS ====================

  Future<PostModel> createPost({
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
    String? imageUrl,
  }) async {
    final now = DateTime.now();

    final postData = {
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'image_url': imageUrl,
      'status': 'published',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'likes_count': 0,
      'comments_count': 0,
      'shares_count': 0,
      'liked_by_user_ids': [],
      'tags': [],
      'is_pinned': false,
    };

    final postId = await _firebaseDataSource.createPost(postData);
    postData['id'] = postId;

    return PostModel.fromJson(postData);
  }

  Future<PostModel?> getPostById(String postId) async {
    final postData = await _firebaseDataSource.getPostById(postId);
    return postData != null ? PostModel.fromJson(postData) : null;
  }

  Future<void> updatePost(String postId, {String? content, String? imageUrl}) async {
    final updateData = <String, dynamic>{};
    if (content != null) updateData['content'] = content;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    await _firebaseDataSource.updatePost(postId, updateData);
  }

  Future<void> deletePost(String postId) async {
    await _firebaseDataSource.deletePost(postId);
  }

  Stream<List<PostModel>> streamPosts({int limit = 20}) {
    return _firebaseDataSource.streamPosts(limit: limit).map(
          (postsList) => postsList.map((postData) => PostModel.fromJson(postData)).toList(),
    );
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    // Check cache first
    final cached = _localDataSource.getCachedUserPosts(
      userId,
      maxAge: const Duration(minutes: 5),
    );
    if (cached != null) {
      return cached.map((postData) => PostModel.fromJson(postData)).toList();
    }

    // Fetch from Firebase
    final postsList = await _firebaseDataSource.getUserPosts(userId);

    // Cache the results
    await _localDataSource.cacheUserPosts(userId, postsList);

    return postsList.map((postData) => PostModel.fromJson(postData)).toList();
  }

  // ==================== LIKE OPERATIONS ====================

  Future<void> likePost(String postId, String userId) async {
    await _firebaseDataSource.likePost(postId, userId);
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firebaseDataSource.unlikePost(postId, userId);
  }

  // ==================== COMMENT OPERATIONS ====================

  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
    String? parentCommentId,
  }) async {
    final now = DateTime.now();

    final commentData = {
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'likes_count': 0,
      'liked_by_user_ids': [],
      'parent_comment_id': parentCommentId,
    };

    final commentId = await _firebaseDataSource.addComment(postId, commentData);
    commentData['id'] = commentId;

    return CommentModel.fromJson(commentData);
  }

  Stream<List<CommentModel>> streamComments(String postId) {
    return _firebaseDataSource.streamComments(postId).map(
          (commentsList) => commentsList.map((commentData) => CommentModel.fromJson(commentData)).toList(),
    );
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _firebaseDataSource.deleteComment(postId, commentId);
  }

  // ==================== IMAGE UPLOAD ====================

  Future<String> uploadPostImage(String userId, String postId, String filePath) async {
    return await _firebaseDataSource.uploadPostImage(userId, postId, filePath);
  }
}