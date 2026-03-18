import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final NotificationRepository? _repository;

  NotificationProvider(this._notificationService, [this._repository]);

  bool _notificationsEnabled = true;
  int _unreadCount = 0;
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get notificationsEnabled => _notificationsEnabled;
  int get unreadCount => _unreadCount;
  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      _notifications = await _repository!.getNotifications();
      // Update unread count based on logic (handling both bool and int from backend)
      _unreadCount = _notifications.where((n) {
        final isRead = n['is_read'];
        return isRead == false || isRead == 0 || isRead == null || n['read_at'] == null;
      }).length;
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
      await _repository!.markNotificationsAsRead();
      _unreadCount = 0;
      await fetchNotifications(); // Refresh list
    } catch (e) {
      debugPrint('Failed to mark notifications as read: $e');
    }
  }

  // Delete notifications older than a date
  Future<void> clearNotifications(DateTime date) async {
    if (_repository == null) return;
    
    try {
      await _repository!.deleteNotifications(date);
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
    notifyListeners();
  }

  // Clear unread count
  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  // Show local notification
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

  // Send post like notification (server-side action typically, but kept for compatibility)
  Future<void> sendPostLikeNotification({
    required int postId,
    required int postOwnerId,
    required String likerName,
  }) async {
    debugPrint(
        'Sending like notification for post $postId to owner $postOwnerId');
    // Actual backend handles this when toggleLike is called
  }

  // Send follow notification
  Future<void> sendFollowNotification({
    required int targetUserId,
    required String followerName,
  }) async {
    debugPrint('User $followerName followed $targetUserId');
    // Actual backend handles this when toggleFollow is called
    // We can show a local experimental notification if the user wants to see it work
    await showNotification(
      title: 'متابعة جديدة!',
      body: 'لقد قام $followerName بمتابعتك مؤخراً.',
    );
  }
}
