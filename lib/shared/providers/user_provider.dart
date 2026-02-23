import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

import '../../data/repositories/profile_repository.dart';

class UserProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  UserProvider(this._profileRepository);

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _profileRepository.getUserProfile(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileRepository.updateProfile(
        userId: userId,
        name: name,
        bio: bio,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear user
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
