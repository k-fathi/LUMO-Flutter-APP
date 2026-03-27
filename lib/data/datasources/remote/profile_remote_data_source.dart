import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/enums/user_role.dart';
import '../../models/user_model.dart';
import '../../models/parent_model.dart';
import '../../models/doctor_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? bio,
    String? avatarFilePath,
    String? childName,
    int? childAge,
    String? childMedicalCondition,
    String? childPhotoUrl,
  });
  Future<List<UserModel>> getFollowers(int userId);
  Future<List<UserModel>> getFollowing(int userId);
  Future<void> toggleFollow(int userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> getProfile() async {
    final response = await _dioClient.get(ApiConstants.getProfile);
    // The API may return the user under a 'user' or 'data' key
    final data = response.data as Map<String, dynamic>;
    final userData = data['user'] ?? data['data'] ?? data;
    return _parseUser(userData as Map<String, dynamic>);
  }

  @override
  Future<List<UserModel>> getFollowers(int userId) async {
    // If userId is provided, fetch for that user; otherwise defaults to current user
    final response = await _dioClient.get(
      ApiConstants.getMyFollowers,
      queryParameters: userId > 0 ? {'user_id': userId} : null,
    );
    final data = response.data as Map<String, dynamic>;
    final list = (data['followers'] ?? data['data'] ?? []) as List;
    return list
        .map((item) => _parseUser(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UserModel>> getFollowing(int userId) async {
    // If userId is provided, fetch for that user; otherwise defaults to current user
    final response = await _dioClient.get(
      ApiConstants.getMyFollowings,
      queryParameters: userId > 0 ? {'user_id': userId} : null,
    );
    final data = response.data as Map<String, dynamic>;
    final list = (data['followings'] ?? data['data'] ?? []) as List;
    return list
        .map((item) => _parseUser(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleFollow(int userId) async {
    await _dioClient.post(
      ApiConstants.toggleFollow.replaceFirst('{id}', userId.toString()),
    );
  }

  @override
  Future<UserModel> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? bio,
    String? avatarFilePath,
    String? childName,
    int? childAge,
    String? childMedicalCondition,
    String? childPhotoUrl,
  }) async {
    final formData = FormData();

    if (name != null && name.isNotEmpty) {
      formData.fields.add(MapEntry('name', name));
    }
    if (phone != null && phone.isNotEmpty) {
      formData.fields.add(MapEntry('phone', phone));
    }
    if (bio != null && bio.isNotEmpty) {
      formData.fields.add(MapEntry('bio', bio));
    }
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      formData.files.add(MapEntry(
        'profile_image',
        await MultipartFile.fromFile(
          avatarFilePath,
          filename: avatarFilePath.split('/').last,
        ),
      ));
    }
    if (childPhotoUrl != null && childPhotoUrl.isNotEmpty) {
      formData.files.add(MapEntry(
        'child_photo',
        await MultipartFile.fromFile(
          childPhotoUrl,
          filename: childPhotoUrl.split('/').last,
        ),
      ));
    }
    if (childName != null) {
      formData.fields.add(MapEntry('child_name', childName));
    }
    if (childAge != null) {
      formData.fields.add(MapEntry('child_age', childAge.toString()));
    }
    if (childMedicalCondition != null) {
      formData.fields
          .add(MapEntry('child_medical_condition', childMedicalCondition));
    }

    final response = await _dioClient.post(
      '${ApiConstants.updateProfile}?_method=PUT',
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    final userData = data['user'] ?? data['data'] ?? data;
    return _parseUser(userData as Map<String, dynamic>);
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
