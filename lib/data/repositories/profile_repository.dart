import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
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

  ProfileRepository(this._firebaseDataSource, this._localDataSource);

  // ==================== USER PROFILE ====================

  Future<UserModel?> getUserProfile(String userId) async {
    final userData = await _firebaseDataSource.getUserById(userId);
    if (userData == null) return null;

    final role = UserRole.fromString(userData['role'] as String);
    if (role == UserRole.doctor) {
      return DoctorModel.fromJson(userData);
    } else {
      return ParentModel.fromJson(userData);
    }
  }

  Stream<UserModel?> streamUserProfile(String userId) {
    return _firebaseDataSource.streamUser(userId).map((userData) {
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
    required String userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? childPhotoUrl,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (phone != null) updateData['phone'] = phone;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (childPhotoUrl != null) updateData['child_photo_url'] = childPhotoUrl;

    // 1. Try to update on Firebase (Network)
    try {
      await _firebaseDataSource.updateUser(userId, updateData);
    } catch (e) {
      // Ignore network errors for demo purposes
      // debugPrint('Firebase update failed: $e');
    }

    // 2. Fetch latest data (Network) OR fallback to local + updates
    Map<String, dynamic>? latestUserData;
    try {
      latestUserData = await _firebaseDataSource.getUserById(userId);
    } catch (e) {
      // Ignore network errors
    }

    // 3. If network fetch failed, use local cache and apply updates manually
    if (latestUserData == null) {
      final currentLocal = _localDataSource.getCurrentUser();
      if (currentLocal != null) {
        // Create a mutable copy and apply updates
        latestUserData = Map<String, dynamic>.from(currentLocal);
        latestUserData.addAll(updateData);
      }
    }

    if (latestUserData == null) {
      throw Exception('Could not update profile: No local data found');
    }

    // 4. Save to local storage (Persistence)
    await _localDataSource.saveCurrentUser(latestUserData);

    // 5. Return the updated model
    final role = UserRole.fromString(latestUserData['role'] as String);
    if (role == UserRole.doctor) {
      return DoctorModel.fromJson(latestUserData);
    } else {
      return ParentModel.fromJson(latestUserData);
    }
  }

  Future<String> uploadAvatar(String userId, String filePath) async {
    return await _firebaseDataSource.uploadUserAvatar(userId, filePath);
  }

  // ==================== FOLLOW SYSTEM ====================

  Future<void> followUser(String followerId, String followingId) async {
    await _firebaseDataSource.followUser(followerId, followingId);
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    await _firebaseDataSource.unfollowUser(followerId, followingId);
  }

  // ==================== DOCTOR CODE SYSTEM ====================

  Future<DoctorCodeModel> generateDoctorCode(
      String doctorId, String doctorName) async {
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
    required String parentId,
    required String parentName,
    String? parentAvatarUrl,
    required String childName,
    required int childAge,
    required String doctorId,
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
      String requestId, String doctorId, String parentId) async {
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
      String doctorId) {
    return _firebaseDataSource.streamDoctorConnectionRequests(doctorId).map(
          (requestsList) => requestsList
              .map(
                  (requestData) => ConnectionRequestModel.fromJson(requestData))
              .toList(),
        );
  }
}
