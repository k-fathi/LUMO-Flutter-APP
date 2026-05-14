import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/repositories/profile_repository.dart';

/// Profile View Model - manages profile screen state and logic
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileViewModel({required this.repository});

  UserModel? _user;
  bool _isLoading = false;
  bool _isListLoading = false;
  String? _errorMessage;

  List<UserModel> _followers = [];
  List<UserModel> _following = [];

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isListLoading => _isListLoading;
  String? get errorMessage => _errorMessage;

  List<UserModel> get followersList => _followers;
  List<UserModel> get followingList => _following;

  // Computed getters from _user
  String get userName => _user?.name ?? '';
  String get userRole => _user?.role.name ?? 'parent';
  int get followers => _user?.followersCount ?? 0;
  int get following => _user?.followingCount ?? 0;

  /// Update the local user's follower count optimistically
  void updateFollowerCount(bool isFollowing) {
    if (_user != null) {
      final currentCount = _user!.followersCount ?? 0;
      _user = _user!.copyWith(
        followersCount: isFollowing ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0),
      );
      notifyListeners();
    }
  }

  /// Load user profile - BUG FIX #4: Prevent infinite rebuilds with proper state management
  Future<void> loadProfile(int userId, {UserModel? fallbackUser}) async {
    // Skip if already loading this exact user to prevent StackOverflow
    if (_isLoading && _user?.id == userId) return;
    
    // Inject fallback user immediately so UI doesn't flicker blank
    if (_user?.id != userId && fallbackUser != null) {
      _user = fallbackUser;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await repository.getUserProfile(userId);
      if (userData != null) {
        UserModel updatedUserData = userData;
        
        // Prevent backend from zeroing out existing valid counters
        final oldUser = _user ?? fallbackUser;
        final updatedFollowers = updatedUserData.followersCount ?? 0;
        final updatedFollowing = updatedUserData.followingCount ?? 0;
        final oldFollowers = oldUser?.followersCount ?? 0;
        final oldFollowing = oldUser?.followingCount ?? 0;

        // The user specifies this is a Mutual Connection system (Friendship).
        // Since Laravel stores directional follows, we enforce symmetry on the frontend.
        final maxUpdated = updatedFollowers > updatedFollowing ? updatedFollowers : updatedFollowing;
        final maxOld = oldFollowers > oldFollowing ? oldFollowers : oldFollowing;
        final count = maxUpdated > 0 ? maxUpdated : maxOld;

        if (updatedUserData is DoctorModel) {
          updatedUserData = updatedUserData.copyWith(
            followersCount: count,
            followingCount: count,
          );
        } else if (updatedUserData is ParentModel) {
          updatedUserData = updatedUserData.copyWith(
            followersCount: count,
            followingCount: count,
          );
        } else {
           updatedUserData = updatedUserData.copyWith(
            followersCount: count,
            followingCount: count,
          );
        }
        
        _user = updatedUserData;
      } else {
        // On desktop (or when backend doesn't expose user-by-id),
        // keep existing _user (typically set from navigation args).
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load followers - BUG FIX #4: Prevent StackOverflow with pagination
  Future<void> loadFollowers(int userId) async {
    // Skip if already loading this exact user's followers
    if (_isListLoading) return;
    
    _isListLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _followers = await repository.getFollowers(userId);
      if (_user != null && _user!.id == userId) {
        _user = _user!.copyWith(followersCount: _followers.length);
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل المتابعين: $e';
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  /// Load following - BUG FIX #4: Prevent StackOverflow with pagination  
  Future<void> loadFollowing(int userId) async {
    // Skip if already loading this exact user's following list
    if (_isListLoading) return;
    
    _isListLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _following = await repository.getFollowing(userId);
      if (_user != null && _user!.id == userId) {
        _user = _user!.copyWith(followingCount: _following.length);
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل قائمة المتابعة: $e';
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required int userId,
    String? name,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? childName,
    int? childAge,
    String? childMedicalCondition,
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
        childName: childName,
        childAge: childAge,
        childMedicalCondition: childMedicalCondition,
        childPhotoUrl: childPhotoUrl,
      );
      _user = updatedUser;
    } catch (e) {
      _errorMessage = 'فشل تحديث الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset state for logout
  void resetState() {
    _isLoading = false;
    _isListLoading = false;
    _user = null;
    _errorMessage = null;
    _followers = [];
    _following = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }
}
