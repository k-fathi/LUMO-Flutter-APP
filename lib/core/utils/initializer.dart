import 'package:flutter/material.dart';

import '../di/dependency_injection.dart';
import '../services/notification_service.dart';
import '../services/shared_preferences_service.dart';

class AppInitializer {
  const AppInitializer._();

  static Future<void> initialize() async {
    try {
      // Initialize SharedPreferences first
      final prefs = getIt<SharedPreferencesService>();
      await prefs.init();

      // Initialize Notifications
      final notificationService = getIt<NotificationService>();
      await notificationService.initialize();

      // Request notification permissions (iOS)
      await notificationService.requestPermissions();

      debugPrint('✅ App initialized successfully');
    } catch (e) {
      debugPrint('❌ App initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> reset() async {
    try {
      final prefs = getIt<SharedPreferencesService>();
      await prefs.clear();

      debugPrint('✅ App reset successfully');
    } catch (e) {
      debugPrint('❌ App reset failed: $e');
      rethrow;
    }
  }
}