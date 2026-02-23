import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  FirebaseAuth? _auth;

  FirebaseAuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth instance not available: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Get user stream
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream.value(null);

  // Get user ID
  String? get currentUserId => _auth?.currentUser?.uid;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw FirebaseAuthException(
          code: 'app-not-initialized', message: 'Firebase not initialized');
    }
    try {
      return await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw FirebaseAuthException(
          code: 'app-not-initialized', message: 'Firebase not initialized');
    }
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth?.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) return;
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      if (_auth?.currentUser == null) return;
      await _auth!.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    if (_auth == null) return;
    try {
      await _auth!.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (_auth == null) return;
    try {
      await _auth!.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Re-authenticate user
  Future<void> reauthenticateUser({
    required String email,
    required String password,
  }) async {
    if (_auth == null) return;
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth!.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    if (_auth == null) return;
    try {
      await _auth!.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth?.currentUser?.emailVerified ?? false;

  // Reload user
  Future<void> reloadUser() async {
    await _auth?.currentUser?.reload();
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور خاطئة';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث';
      default:
        return e.message ?? 'حدث خطأ غير معروف';
    }
  }
}
