import 'dart:io';

import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/doctor_model.dart';
import '../models/parent_model.dart';
import '../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/mock_accounts.dart';

class AuthRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;

  AuthRepository(this._firebaseDataSource, this._localDataSource);

  // ==================== SIGN UP ====================

  // ==================== SIGN UP ====================

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    // Doctor-specific fields
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    // Parent-specific fields
    String? childName,
    int? childAge,
    String? childGender,
    File? childPhoto,
    File? profilePhoto,
  }) async {
    final now = DateTime.now();

    final userData = {
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'avatar_url': profilePhoto?.path,
      'bio': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'followers_count': 0,
      'following_count': 0,
      'is_verified': false,
      'is_active': true,
    };

    // Add role-specific fields
    if (role == UserRole.doctor) {
      userData['specialization'] = specialization ?? '';
      userData['license_number'] = licenseNumber ?? '';
      userData['years_of_experience'] = yearsOfExperience ?? 0;
      userData['clinic_address'] = null;
      userData['clinic_phone'] = null;
      userData['patient_ids'] = [];
      userData['generated_code'] = null;
      userData['code_expires_at'] = null;
      userData['rating'] = 0.0;
      userData['reviews_count'] = 0;
    } else if (role == UserRole.parent) {
      userData['child_name'] = childName ?? '';
      userData['child_age'] = childAge ?? 0;
      userData['child_gender'] = childGender;
      userData['child_medical_condition'] = null;
      userData['connected_doctor_ids'] = [];
      userData['emergency_contact'] = null;
      userData['address'] = null;
      userData['allergies'] = [];
      userData['medications'] = [];
      userData['child_photo_url'] =
          childPhoto?.path; // Save local path for demo
    }

    try {
      final result = await _firebaseDataSource.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      // Save to local storage
      await _localDataSource.saveCurrentUser(result);
      await _localDataSource.setLoggedIn(true);

      // Convert to appropriate model
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(result);
      } else {
        return ParentModel.fromJson(result);
      }
    } catch (e) {
      // MOCK FALLBACK
      if (e.toString().contains('no-app') ||
          e.toString().contains('app-not-initialized') ||
          e.toString().contains('channel-error') ||
          e.toString().contains('null')) {
        userData['id'] = 'mock-id-${now.millisecondsSinceEpoch}';

        await _localDataSource.saveCurrentUser(userData);
        await _localDataSource.setLoggedIn(true);

        if (role == UserRole.doctor) {
          return DoctorModel.fromJson(userData);
        } else {
          return ParentModel.fromJson(userData);
        }
      }
      rethrow;
    }
  }

  // ==================== SIGN IN ====================

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Check for fixed test accounts FIRST
    final fixedAccountRole = MockAccounts.validateFixedAccount(email, password);
    if (fixedAccountRole != null) {
      // Use fixed account (password is ignored for testing)
      Map<String, dynamic> userData;
      if (fixedAccountRole == 'doctor') {
        userData = MockAccounts.getDoctorAccount();
      } else {
        userData = MockAccounts.getParentAccount();
      }

      await _localDataSource.saveCurrentUser(userData);
      await _localDataSource.setLoggedIn(true);

      final role = UserRole.fromString(userData['role'] as String);
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(userData);
      } else {
        return ParentModel.fromJson(userData);
      }
    }

    try {
      final userData = await _firebaseDataSource.signIn(
        email: email,
        password: password,
      );

      // Save to local storage
      await _localDataSource.saveCurrentUser(userData);
      await _localDataSource.setLoggedIn(true);

      // Convert to appropriate model based on role
      final role = UserRole.fromString(userData['role'] as String);
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(userData);
      } else {
        return ParentModel.fromJson(userData);
      }
    } catch (e) {
      // MOCK FALLBACK for other emails
      if (e.toString().contains('no-app') ||
          e.toString().contains('app-not-initialized') ||
          e.toString().contains('channel-error') ||
          e.toString().contains('null')) {
        final isDoctor = email.toLowerCase().contains('doctor');
        final now = DateTime.now();

        final mockUser = {
          'id': 'mock-id-signin',
          'email': email,
          'name': isDoctor ? 'دكتور تجريبي' : 'مستخدم تجريبي',
          'role': isDoctor ? 'doctor' : 'parent',
          'avatar_url': null,
          'bio': 'هذا حساب تجريبي للعمل بدون اتصال',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'followers_count': 100,
          'following_count': 50,
          'is_verified': true,
          'is_active': true,
        };

        if (isDoctor) {
          mockUser['specialization'] = 'أطفال';
          mockUser['license_number'] = '12345';
          mockUser['years_of_experience'] = 10;
          mockUser['clinic_address'] = 'القاهرة، مصر';
          mockUser['clinic_phone'] = '0123456789';
          mockUser['patient_ids'] = [];
          mockUser['generated_code'] = 'DOC123';
          mockUser['code_expires_at'] = null;
          mockUser['rating'] = 4.8;
          mockUser['reviews_count'] = 120;
        } else {
          mockUser['child_name'] = 'أحمد';
          mockUser['child_age'] = 5;
          mockUser['child_gender'] = 'male';
          mockUser['child_medical_condition'] = null;
          mockUser['connected_doctor_ids'] = [];
          mockUser['emergency_contact'] = '0100000000';
          mockUser['address'] = 'الجيزة، مصر';
          mockUser['allergies'] = [];
          mockUser['medications'] = [];
        }

        await _localDataSource.saveCurrentUser(mockUser);
        await _localDataSource.setLoggedIn(true);

        if (isDoctor) {
          return DoctorModel.fromJson(mockUser);
        } else {
          return ParentModel.fromJson(mockUser);
        }
      }
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  Future<void> signOut() async {
    await _firebaseDataSource.signOut();
    await _localDataSource.clearCurrentUser();
    await _localDataSource
        .clearAllCache(); // Wipes saved messages, search history, config
    await _localDataSource.setLoggedIn(false);
  }

  // ==================== GET CURRENT USER ====================

  Future<UserModel?> getCurrentUser() async {
    // First check local storage
    final localUser = _localDataSource.getCurrentUser();
    if (localUser != null) {
      final role = UserRole.fromString(localUser['role'] as String);
      if (role == UserRole.doctor) {
        return DoctorModel.fromJson(localUser);
      } else {
        return ParentModel.fromJson(localUser);
      }
    }

    // If not in local, check Firebase
    final userId = _firebaseDataSource.currentUserId;
    if (userId != null) {
      final userData = await _firebaseDataSource.getUserById(userId);
      if (userData != null) {
        await _localDataSource.saveCurrentUser(userData);
        final role = UserRole.fromString(userData['role'] as String);
        if (role == UserRole.doctor) {
          return DoctorModel.fromJson(userData);
        } else {
          return ParentModel.fromJson(userData);
        }
      }
    }

    return null;
  }

  // ==================== CHECK LOGIN STATUS ====================

  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  String? getCurrentUserId() {
    return _localDataSource.getCurrentUserId() ??
        _firebaseDataSource.currentUserId;
  }

  // ==================== PASSWORD RESET ====================

  Future<void> resetPassword(String email) async {
    // This would be implemented with Firebase Auth
    // For now, it's a placeholder
    throw UnimplementedError('Password reset not implemented yet');
  }

  // ==================== UPDATE USER ====================

  Future<UserModel> updateUser({
    required String userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (phone != null) updateData['phone'] = phone;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    await _firebaseDataSource.updateUser(userId, updateData);

    // Get updated user
    final userData = await _firebaseDataSource.getUserById(userId);
    await _localDataSource.saveCurrentUser(userData!);

    final role = UserRole.fromString(userData['role'] as String);
    if (role == UserRole.doctor) {
      return DoctorModel.fromJson(userData);
    } else {
      return ParentModel.fromJson(userData);
    }
  }

  // ==================== DELETE ACCOUNT ====================

  Future<void> deleteAccount(String userId) async {
    await _firebaseDataSource.deleteUser(userId);
    await _localDataSource.clearCurrentUser();
    await _localDataSource.setLoggedIn(false);
  }
}
