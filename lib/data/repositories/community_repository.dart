import '../datasources/remote/community_remote_data_source.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import './profile_repository.dart';

class CommunityRepository {
  final CommunityRemoteDataSource _remoteDataSource;
  final ProfileRepository? _profileRepository;

  CommunityRepository(this._remoteDataSource, [this._profileRepository]);

  // ==================== POST OPERATIONS ====================

  Future<List<PostModel>> getHomeFeed({int page = 1}) async {
    return await _remoteDataSource.getHomeFeed(page: page);
  }

  Future<List<PostModel>> getExploreFeed({int page = 1}) async {
    return await _remoteDataSource.getExploreFeed(page: page);
  }

  Future<PostModel> getPostById(int postId) async {
    return await _remoteDataSource.getPostById(postId.toString());
  }

  Future<List<PostModel>> getMyPosts({int page = 1}) async {
    return await _remoteDataSource.getMyPosts(page: page);
  }

  Future<PostModel> createPost({
    required String content,
    String? imagePath,
  }) async {
    return await _remoteDataSource.createPost(content, imagePath: imagePath);
  }

  Future<PostModel> updatePost(int postId,
      {required String content, String? imagePath}) async {
    return await _remoteDataSource.updatePost(postId.toString(), content,
        imagePath: imagePath);
  }

  Future<void> deletePost(int postId) async {
    await _remoteDataSource.deletePost(postId.toString());
  }

  // ==================== LIKE OPERATIONS ====================

  Future<void> toggleLike(int postId) async {
    await _remoteDataSource.toggleLike(postId.toString());
  }

  // ==================== COMMENT OPERATIONS ====================

  Future<void> addComment(int postId, String content, {int? parentId}) async {
    await _remoteDataSource.addComment(postId.toString(), content, parentId: parentId);
  }

  Future<void> toggleCommentLike(int commentId) async {
    await _remoteDataSource.toggleCommentLike(commentId.toString());
  }

  Future<List<CommentModel>> getComments(int postId) async {
    return await _remoteDataSource.getComments(postId.toString());
  }

  // ==================== SOCIAL OPERATIONS ====================

  Future<void> toggleFollow(int userId, {int? currentUserId}) async {
    // 1. Toggle in REST API
    await _remoteDataSource.toggleFollow(userId.toString());

    // 2. Sync with Firebase for counters if profile repository is available
    if (_profileRepository != null && currentUserId != null) {
      try {
        // Check if currently following to decide whether to follow or unfollow in Firebase
        final following = await _remoteDataSource.getFollowingUsers();
        final isFollowing = following.any((u) => u.id == userId);
        
        if (isFollowing) {
          await _profileRepository!.followUser(currentUserId, userId);
        } else {
          await _profileRepository!.unfollowUser(currentUserId, userId);
        }
      } catch (e) {
        // Log error but don't fail the whole operation as REST call succeeded
        debugPrint('Firebase follow sync error: $e');
      }
    }
  }

  Future<List<UserModel>> getFollowingUsers() async {
    return await _remoteDataSource.getFollowingUsers();
  }

  Future<List<UserModel>> searchUsers(String query, {String? role}) async {
    return await _remoteDataSource.searchUsers(query, role: role);
  }
}
