import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/notification_repository.dart';
// Import the InAppNotif data class from app.dart
import '../../app.dart' show InAppNotif;

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final NotificationRepository? _repository;

  NotificationProvider(this._notificationService, [this._repository]);

  bool _notificationsEnabled = true;
  int _unreadCount = 0;
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Non-null when there is a pending in-app notification banner to show.
  InAppNotif? _inAppNotification;

  bool get notificationsEnabled => _notificationsEnabled;
  int get unreadCount => _unreadCount;
  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InAppNotif? get inAppNotification => _inAppNotification;

  // Initialize notifications
  Future<void> init() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    if (_repository != null) {
      await fetchNotifications();
    }
  }

  // Fetch from backend
  Future<void> fetchNotifications() async {
    if (_repository == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _unreadCount = _notifications.where((n) {
        final isRead = n['is_read'];
        return isRead == false || isRead == 0 || isRead == null || n['read_at'] == null;
      }).length;
      _updateAppBadge();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    if (_repository == null) return;

    try {
      await _repository.markNotificationsAsRead();
      _unreadCount = 0;
      _updateAppBadge();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark notifications as read: $e');
    }
  }

  // Delete notifications older than a date
  Future<void> clearNotifications(DateTime date) async {
    if (_repository == null) return;

    try {
      await _repository.deleteNotifications(date);
      await fetchNotifications();
    } catch (e) {
      debugPrint('Failed to delete notifications: $e');
    }
  }

  // Toggle notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Update unread count manually
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  // Increment unread count
  void incrementUnreadCount() {
    _unreadCount++;
    _updateAppBadge();
    notifyListeners();
  }

  // Clear unread count
  void clearUnreadCount() {
    _unreadCount = 0;
    _updateAppBadge();
    notifyListeners();
  }

  /// Updates the app icon badge based on the current unread count.
  void _updateAppBadge() {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (_unreadCount > 0) {
          AppBadgePlus.updateBadge(_unreadCount);
        } else {
          AppBadgePlus.updateBadge(0);
        }
      }
    } catch (e) {
      debugPrint('App badger update failed (platform may not support it): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  In-App Notification Banner
  // ─────────────────────────────────────────────────────────────

  /// Queue a notification to be displayed as an in-app banner.
  void showInAppNotification({
    required String title,
    required String body,
    IconData icon = Icons.notifications_active_rounded,
    Color color = AppColors.primary,
  }) {
    _inAppNotification = InAppNotif(
      title: title,
      body: body,
      icon: icon,
      color: color,
    );
    incrementUnreadCount();
    notifyListeners();
  }

  /// Called by the overlay widget after it reads the notification,
  /// so we don't show the same banner twice.
  void consumeInAppNotification() {
    _inAppNotification = null;
    // DO NOT notifyListeners() here — the overlay handles animation itself
  }

  // ─────────────────────────────────────────────────────────────
  //  Local system notification (flutter_local_notifications)
  // ─────────────────────────────────────────────────────────────

  // Show local notification (system tray / status bar)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      payload: payload,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  High-level notification helpers (backend handles FCM push)
  // ─────────────────────────────────────────────────────────────

  /// Called when the current user likes a post.
  /// The backend sends the FCM push to the post owner.
  /// We only show an in-app banner if the like was on our own post
  /// (edge case where currentUser == postOwner is already excluded by UI).
  Future<void> sendPostLikeNotification({
    required int postId,
    required int postOwnerId,
    required String likerName,
  }) async {
    debugPrint('Like notification for post $postId → backend handles FCM');
    await fetchNotifications();
  }

  /// Called after the parent accepts a connection request.
  Future<void> sendConnectionAcceptedNotification({
    required int doctorId,
    required String patientName,
  }) async {
    debugPrint('Connection accepted → backend handles FCM for doctor $doctorId');
    await fetchNotifications();
  }

  /// Called after a follow action.
  Future<void> sendFollowNotification({
    required int targetUserId,
    required String followerName,
  }) async {
    debugPrint('Follow action → backend handles FCM push to user $targetUserId');
    await fetchNotifications();
  }

  /// Called after a comment is added.
  Future<void> sendCommentNotification({
    required int postId,
    required int postOwnerId,
    required String commenterName,
  }) async {
    debugPrint('Comment by $commenterName on post $postId → backend handles FCM');
  }

  /// Called after a chat message is sent.
  Future<void> sendMessageNotification({
    required int targetUserId,
    required String senderName,
    required String messagePreview,
  }) async {
    debugPrint('Message notification from $senderName to $targetUserId');
    // Show a local system notification for messages as well
    await showNotification(
      title: 'رسالة جديدة من $senderName',
      body: messagePreview,
      payload: 'chat_$targetUserId',
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  FCM Foreground handler (called from auth_provider._setupFcmListeners)
  // ─────────────────────────────────────────────────────────────

  /// Should be called when a Firebase Cloud Messaging message arrives
  /// while the app is in the foreground. Shows both a system notification
  /// and an in-app banner.
  void handleForegroundFcmMessage({
    required String title,
    required String body,
    String? type,
  }) {
    final t = (type ?? '').toLowerCase();

    // Only allow connection requests, approvals, or rejections
    final isConnectionNotification = t.contains('connection') || t.contains('request');
    if (!isConnectionNotification) {
      // Refresh notification list silently without showing banner
      fetchNotifications();
      return;
    }

    // Determine icon & color based on notification type
    IconData icon = Icons.person_add_rounded;
    Color color = const Color(0xFF10B981);

    // Show in-app banner
    showInAppNotification(title: title, body: body, icon: icon, color: color);

    // Refresh notification list silently
    fetchNotifications();
  }
}
