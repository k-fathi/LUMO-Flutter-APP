import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote/profile_remote_data_source.dart';
import '../models/connection_request_model.dart';
import '../models/doctor_code_model.dart';
import '../models/doctor_model.dart';
import '../models/parent_model.dart';
import '../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/connection_status.dart';
import '../../core/utils/app_constants.dart';

class ProfileRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;
  final ProfileRemoteDataSource? _remoteDataSource;

  ProfileRepository(
    this._firebaseDataSource,
    this._localDataSource, [
    this._remoteDataSource,
  ]);

  // ==================== USER PROFILE ====================

  Future<UserModel?> getUserProfile(int userId) async {
    // Check if this is the current user
    final currentUserData = _localDataSource.getCurrentUser();
    final currentUserId = currentUserData != null
        ? int.tryParse(currentUserData['id']?.toString() ?? '')
        : null;

    final isMyProfile = userId == currentUserId || userId <= 0;

    // 1. Try REST API only for current user
    if (_remoteDataSource != null && isMyProfile) {
      try {
        final profile = await _remoteDataSource!.getProfile();
        // Persist to local cache
        await _localDataSource.saveCurrentUser(profile.toJson());
        return profile;
      } catch (e) {
        final isUnauthenticated =
            e.toString().toLowerCase().contains('unauthenticated') ||
                e.toString().contains('401');

        if (isUnauthenticated) {
          rethrow; // Let AuthProvider handle the 401 and log out
        }
        debugPrint('REST Profile fetch failed: $e. Falling back to Firebase.');
      }
    }

    // 2. FOR TARGET USER (not me): Fetch followers/following to get counts
    if (!isMyProfile && _remoteDataSource != null) {
      try {
        // Fetch followers/following list to get real-time counts
        final followers = await _remoteDataSource!.getFollowers(userId);
        final following = await _remoteDataSource!.getFollowing(userId);

        if (!kIsWeb && !(Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
          try {
            final userData = await _firebaseDataSource.getUserById(userId.toString());
            if (userData != null) {
              final role = UserRole.fromString(userData['role'] as String? ?? 'parent');
              
              // Enrich Firebase data with current counts
              final enriched = Map<String, dynamic>.from(userData);
              enriched['followers_count'] = followers.length;
              enriched['following_count'] = following.length;

              if (role == UserRole.doctor) {
                return DoctorModel.fromJson(enriched);
              } else {
                return ParentModel.fromJson(enriched);
              }
            }
          } catch (e) {
            debugPrint('Firebase fetch failed for target user: $e');
          }
        }

        // Fallback: Build a simple UserModel with calculated counts if Firebase isn't available
        // Note: Name and Avatar will be supplemented by ProfileScreen from nav arguments
        return UserModel(
          id: userId,
          name: '', // Empty name allows ProfileScreen to use its initialName argument
          email: '',
          role: UserRole.parent,
          followersCount: followers.length,
          followingCount: following.length,
        );
      } catch (e) {
        debugPrint('Could not get target user profile data: $e');
      }
    }

    // Default Fallback
    if (userId <= 0) return null;

    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      debugPrint('Skipping Firebase fallback on desktop platforms which may not support it or be initialized.');
      return null;
    }

    try {
      final userData = await _firebaseDataSource.getUserById(userId.toString());
      if (userData == null) return null;

      final role = UserRole.fromString(userData['role'] as String? ?? 'parent');
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(userData);
      } else {
        return ParentModel.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Firebase fetch failed: $e');
      return null;
    }
  }

  Stream<UserModel?> streamUserProfile(int userId) {
    return _firebaseDataSource.streamUser(userId.toString()).map((userData) {
      if (userData == null) return null;
      final role = UserRole.fromString(userData['role'] as String);
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(userData);
      } else {
        return ParentModel.fromJson(userData);
      }
    });
  }

  Future<UserModel> updateProfile({
    required int userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? avatarFilePath,
    String? childName,
    int? childAge,
    String? childMedicalCondition,
    String? childPhotoUrl,
  }) async {
    // 1. Try the real REST API first (preferred path)
    if (_remoteDataSource != null) {
      try {
        final updatedUser = await _remoteDataSource!.updateProfile(
          userId: userId,
          name: name,
          phone: phone,
          bio: bio,
          avatarFilePath: avatarFilePath ?? avatarUrl,
          childName: childName,
          childAge: childAge,
          childMedicalCondition: childMedicalCondition,
          childPhotoUrl: childPhotoUrl,
        );
        // Persist fresh server data locally
        await _localDataSource.saveCurrentUser(updatedUser.toJson());
        return updatedUser;
      } catch (e) {
        // If REST API fails, fall through to local/Firebase path
      }
    }

    // 2. Offline / fallback: apply changes locally
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (phone != null) updateData['phone'] = phone;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (childName != null) updateData['child_name'] = childName;
    if (childAge != null) updateData['child_age'] = childAge;
    if (childMedicalCondition != null) {
      updateData['child_medical_condition'] = childMedicalCondition;
    }
    if (childPhotoUrl != null) updateData['child_photo_url'] = childPhotoUrl;

    Map<String, dynamic>? latestUserData;
    try {
      latestUserData = await _firebaseDataSource.getUserById(userId.toString());
    } catch (_) {}

    if (latestUserData == null) {
      final currentLocal = _localDataSource.getCurrentUser();
      if (currentLocal != null) {
        latestUserData = Map<String, dynamic>.from(currentLocal)
          ..addAll(updateData);
      }
    } else {
      latestUserData.addAll(updateData);
    }

    if (latestUserData == null) {
      throw Exception('Could not update profile: No local data found');
    }

    await _localDataSource.saveCurrentUser(latestUserData);

    final role = UserRole.fromString(latestUserData['role'] as String);
    if (role == UserRole.doctor) {
      return DoctorModel.fromJson(latestUserData);
    } else {
      return ParentModel.fromJson(latestUserData);
    }
  }

  Future<String> uploadAvatar(int userId, String filePath) async {
    return await _firebaseDataSource.uploadUserAvatar(
        userId.toString(), filePath);
  }

  // ==================== FOLLOW SYSTEM ====================

  Future<void> toggleFollow(int userId) async {
    if (_remoteDataSource != null) {
      await _remoteDataSource!.toggleFollow(userId);
    }
  }

  Future<void> followUser(int followerId, int followingId) async {
    await _firebaseDataSource.followUser(
        followerId.toString(), followingId.toString());
  }

  Future<void> unfollowUser(int followerId, int followingId) async {
    await _firebaseDataSource.unfollowUser(
        followerId.toString(), followingId.toString());
  }

  Future<List<UserModel>> getFollowers(int userId) async {
    if (_remoteDataSource != null) {
      try {
        return await _remoteDataSource!.getFollowers(userId);
      } catch (e) {
        debugPrint('REST getFollowers failed: $e');
      }
    }
    return []; // Fallback to empty list if no remote source or it fails
  }

  Future<List<UserModel>> getFollowing(int userId) async {
    if (_remoteDataSource != null) {
      try {
        return await _remoteDataSource!.getFollowing(userId);
      } catch (e) {
        debugPrint('REST getFollowing failed: $e');
      }
    }
    return []; // Fallback to empty list if no remote source or it fails
  }

  // ==================== DOCTOR CODE SYSTEM ====================

  Future<DoctorCodeModel> generateDoctorCode(
      int doctorId, String doctorName) async {
    final now = DateTime.now();
    final codeString =
        'DOC${now.millisecondsSinceEpoch.toString().substring(6)}';

    final codeData = {
      'code': codeString,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'created_at': now.toIso8601String(),
      'expires_at': now.add(AppConstants.doctorCodeExpiry).toIso8601String(),
      'is_active': true,
      'usage_count': 0,
      'max_usage': 100,
    };

    final codeId = await _firebaseDataSource.createDoctorCode(codeData);
    codeData['id'] = codeId;

    // Save locally for quick access
    await _localDataSource.saveDoctorCode(codeString);

    return DoctorCodeModel.fromJson(codeData);
  }

  Future<DoctorCodeModel?> validateDoctorCode(String code) async {
    final codeData = await _firebaseDataSource.getDoctorCodeByCode(code);
    if (codeData == null) return null;

    final codeModel = DoctorCodeModel.fromJson(codeData);

    // Check if valid
    if (!codeModel.isValid) return null;

    return codeModel;
  }

  // ==================== CONNECTION REQUEST SYSTEM ====================

  Future<ConnectionRequestModel> createConnectionRequest({
    required int parentId,
    required String parentName,
    String? parentAvatarUrl,
    required String childName,
    required int childAge,
    required int doctorId,
    required String doctorName,
    String? doctorAvatarUrl,
    required String doctorCode,
  }) async {
    final now = DateTime.now();

    final requestData = {
      'parent_id': parentId,
      'parent_name': parentName,
      'parent_avatar_url': parentAvatarUrl,
      'child_name': childName,
      'child_age': childAge,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_avatar_url': doctorAvatarUrl,
      'doctor_code': doctorCode,
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'responded_at': null,
      'rejection_reason': null,
    };

    final requestId =
        await _firebaseDataSource.createConnectionRequest(requestData);
    requestData['id'] = requestId;

    // Increment code usage
    final codeData = await _firebaseDataSource.getDoctorCodeByCode(doctorCode);
    if (codeData != null) {
      await _firebaseDataSource.incrementCodeUsage(codeData['id'] as String);
    }

    return ConnectionRequestModel.fromJson(requestData);
  }

  Future<void> acceptConnectionRequest(
      String requestId, int doctorId, int parentId) async {
    final updateData = {
      'status': ConnectionStatus.accepted.name,
      'responded_at': DateTime.now().toIso8601String(),
    };

    await _firebaseDataSource.updateConnectionRequest(requestId, updateData);

    // Add to each other's lists
    // TODO: Implement adding parent to doctor's patient list and vice versa
  }

  Future<void> rejectConnectionRequest(String requestId,
      {String? reason}) async {
    final updateData = {
      'status': ConnectionStatus.rejected.name,
      'responded_at': DateTime.now().toIso8601String(),
      'rejection_reason': reason,
    };

    await _firebaseDataSource.updateConnectionRequest(requestId, updateData);
  }

  Stream<List<ConnectionRequestModel>> streamDoctorConnectionRequests(
      int doctorId) {
    return _firebaseDataSource
        .streamDoctorConnectionRequests(doctorId.toString())
        .map(
          (requestsList) => requestsList
              .map(
                  (requestData) => ConnectionRequestModel.fromJson(requestData))
              .toList(),
        );
  }
}
