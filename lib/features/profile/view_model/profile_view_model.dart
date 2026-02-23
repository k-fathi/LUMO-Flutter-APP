import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/profile_repository.dart';

/// Profile View Model - manages profile screen state and logic
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileViewModel({required this.repository});

  UserModel? _user;
  String _userName = '';
  String _userRole = 'parent';
  int _followers = 0;
  int _following = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String get userName => _userName;
  String get userRole => _userRole;
  int get followers => _followers;
  int get following => _following;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user profile
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await repository.getUserProfile(userId);
      if (userData != null) {
        _user = userData;
        _userName = userData.name;
        _userRole = userData.role.name;
        _followers = userData.followersCount;
        _following = userData.followingCount;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل الملف الشخصي: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? childPhotoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.updateProfile(
        userId: userId,
        name: name,
        bio: bio,
        phone: phone,
        avatarUrl: avatarUrl,
        childPhotoUrl: childPhotoUrl,
      );
      _user = updatedUser;
      _userName = updatedUser.name;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحديث الملف الشخصي: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear local state
      _user = null;
      _userName = '';
      _userRole = 'parent';
      _followers = 0;
      _following = 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
