import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/post_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> getPosts({int page = 1});
  Future<PostModel> createPost(String content, {String? imagePath});
  Future<void> toggleLike(String postId);
  Future<void> addComment(String postId, String comment);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final DioClient _dioClient;

  CommunityRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PostModel>> getPosts({int page = 1}) async {
    final response = await _dioClient.get(
      ApiConstants.getPosts,
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['posts'];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  @override
  Future<PostModel> createPost(String content, {String? imagePath}) async {
    // If imagePath is provided, backend usually expects Multipart/Form-Data
    final response = await _dioClient.post(
      ApiConstants.createPost,
      data: {
        'content': content,
        'image': imagePath, // Replace with MultipartFile in real implementation
      },
    );
    return PostModel.fromJson(response.data['post']);
  }

  @override
  Future<void> toggleLike(String postId) async {
    await _dioClient.post('${ApiConstants.getPosts}/$postId/like');
  }

  @override
  Future<void> addComment(String postId, String comment) async {
    await _dioClient.post(
      ApiConstants.getPostComments.replaceAll('{id}', postId),
      data: {'content': comment},
    );
  }
}
