import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/enums/user_role.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/parent_model.dart';
import '../../models/doctor_model.dart';
import '../../models/comment_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> getHomeFeed({int page = 1});
  Future<List<PostModel>> getMyPosts({int page = 1});
  Future<PostModel> createPost(String content, {String? imagePath});
  Future<PostModel> updatePost(String postId, String content,
      {String? imagePath});
  Future<void> deletePost(String postId);
  Future<void> toggleLike(String postId);
  Future<void> addComment(String postId, String comment, {int? parentId});
  Future<List<CommentModel>> getComments(String postId);
  Future<void> toggleCommentLike(String commentId);
  Future<void> toggleFollow(String userId);
  Future<List<UserModel>> getFollowingUsers();
  Future<List<UserModel>> searchUsers(String query, {String? role});
  Future<PostModel> getPostById(String postId);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final DioClient _dioClient;

  CommunityRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PostModel>> getHomeFeed({int page = 1}) async {
    final response = await _dioClient.get(
      ApiConstants.homeFeed,
      queryParameters: {'page': page},
    );
    return _parsePostList(response.data);
  }

  @override
  Future<List<PostModel>> getMyPosts({int page = 1}) async {
    final response = await _dioClient.get(
      ApiConstants.myPosts,
      queryParameters: {'page': page},
    );
    return _parsePostList(response.data);
  }

  List<PostModel> _parsePostList(dynamic responseData) {
    List<dynamic> data = [];

    if (responseData is Map<String, dynamic>) {
      final rawData = responseData['posts'] ?? responseData['data'] ?? responseData['results'];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        final innerData = rawData['posts'] ?? rawData['data'] ?? rawData['results'] ?? [];
        if (innerData is List) {
          data = innerData;
        }
      } else {
        // Last resort: check if the map itself has a 'results' key or similar
        data = [];
      }
    } else if (responseData is List) {
      data = responseData;
    }

    return data.map((json) {
      try {
        return PostModel.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }).whereType<PostModel>().toList();
  }

  @override
  Future<PostModel> createPost(String content, {String? imagePath}) async {
    final formData = FormData.fromMap({
      'content': content,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dioClient.post(
      ApiConstants.createPost,
      data: formData,
    );

    final dynamic responseData = response.data;
    if (responseData == null) {
      throw ApiException('لم يتم استلام بيانات من السيرفر');
    }

    final Map<String, dynamic> data =
        responseData is Map<String, dynamic> ? responseData : {};
    final postData = data['post'] ?? data['data'] ?? data;

    if (postData == null || postData is! Map<String, dynamic>) {
      throw ApiException('تنسيق بيانات المنشور غير صالح');
    }

    return PostModel.fromJson(postData);
  }

  @override
  Future<PostModel> updatePost(String postId, String content,
      {String? imagePath}) async {
    final formData = FormData.fromMap({
      'content': content,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dioClient.post(
      ApiConstants.updatePost.replaceAll('{id}', postId) + '?_method=PUT',
      data: formData,
    );

    final dynamic responseData = response.data;
    if (responseData == null) {
      throw ApiException('لم يتم استلام بيانات من السيرفر');
    }

    final Map<String, dynamic> data =
        responseData is Map<String, dynamic> ? responseData : {};
    final postData = data['post'] ?? data['data'] ?? data;

    if (postData == null || postData is! Map<String, dynamic>) {
      throw ApiException('تنسيق بيانات المنشور غير صالح');
    }

    return PostModel.fromJson(postData);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _dioClient.post(
      ApiConstants.deletePost.replaceAll('{id}', postId) + '?_method=DELETE',
    );
  }

  @override
  Future<void> toggleLike(String postId) async {
    await _dioClient.post(
      ApiConstants.toggleLike.replaceAll('{id}', postId),
    );
  }

  @override
  Future<void> addComment(String postId, String comment, {int? parentId}) async {
    await _dioClient.post(
      ApiConstants.postComments.replaceAll('{id}', postId),
      data: {
        'comment': comment,
        'parent_id': parentId,
        'parent_comment_id': parentId,
        'image': null,
      },
    );
  }

  @override
  Future<void> toggleCommentLike(String commentId) async {
    await _dioClient.post(
      '/posts/comments/$commentId/like',
    );
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final response = await _dioClient.get(
      ApiConstants.postComments.replaceAll('{id}', postId),
    );
    final responseData = response.data;
    List<dynamic> data = [];

    if (responseData is Map<String, dynamic>) {
      data = responseData['comments'] ??
          responseData['data'] ??
          responseData['comment'] ??
          [];
    } else if (responseData is List) {
      data = responseData;
    }

    return data.map((json) {
      try {
        return CommentModel.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }).whereType<CommentModel>().toList();
  }

  @override
  Future<void> toggleFollow(String userId) async {
    await _dioClient.post(
      ApiConstants.toggleFollow.replaceAll('{id}', userId),
    );
  }

  @override
  Future<List<UserModel>> getFollowingUsers() async {
    final response = await _dioClient.get(ApiConstants.getFollowing);
    final List<dynamic> data = response.data['followings'] ?? response.data['data'] ?? [];
    return data.map((json) => _parseUser(json)).toList();
  }

  @override
  Future<List<UserModel>> searchUsers(String query, {String? role}) async {
    final response = await _dioClient.get(
      ApiConstants.searchUsers,
      queryParameters: {
        'query': query,
        if (role != null) 'role': role,
      },
    );
    final List<dynamic> data = response.data['users'] ?? [];
    return data.map((json) => _parseUser(json)).toList();
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await _dioClient.get(
      ApiConstants.showPost.replaceAll('{id}', postId),
    );
    final dynamic responseData = response.data;
    final Map<String, dynamic> data =
        responseData is Map<String, dynamic> ? responseData : {};
    final postData = data['post'] ?? data['data'] ?? data;

    if (postData == null || postData is! Map<String, dynamic>) {
      throw ApiException('تنسيق بيانات المنشور غير صالح');
    }

    return PostModel.fromJson(postData);
  }

  UserModel _parseUser(Map<String, dynamic> json) {
    final role = UserRole.fromString(json['role']?.toString() ?? 'patient');
    if (role == UserRole.parent) {
      return ParentModel.fromJson(json);
    } else if (role == UserRole.doctor) {
      return DoctorModel.fromJson(json);
    }
    return UserModel.fromJson(json);
  }
}
