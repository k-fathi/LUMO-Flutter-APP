import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Navigate to specific screen based on payload
    }
  }

  // Show simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'lumo_ai_channel',
      'Lumo AI Notifications',
      channelDescription: 'Notifications for Lumo AI app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Request permissions (iOS)
  Future<bool> requestPermissions() async {
    final result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  // Predefined notification types
  Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
    required String chatRoomId,
  }) async {
    await showNotification(
      id: chatRoomId.hashCode,
      title: 'رسالة جديدة من $senderName',
      body: message,
      payload: 'chat:$chatRoomId',
    );
  }

  Future<void> showNewPostLikeNotification({
    required String userName,
    required String postId,
  }) async {
    await showNotification(
      id: postId.hashCode,
      title: 'إعجاب جديد',
      body: 'أعجب $userName بمنشورك',
      payload: 'post:$postId',
    );
  }

  Future<void> showNewCommentNotification({
    required String userName,
    required String comment,
    required String postId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'تعليق جديد من $userName',
      body: comment,
      payload: 'post:$postId',
    );
  }

  Future<void> showNewFollowerNotification({
    required String userName,
    required String userId,
  }) async {
    await showNotification(
      id: userId.hashCode,
      title: 'متابع جديد',
      body: 'بدأ $userName بمتابعتك',
      payload: 'profile:$userId',
    );
  }

  Future<void> showDoctorConnectionRequestNotification({
    required String doctorName,
    required String requestId,
  }) async {
    await showNotification(
      id: requestId.hashCode,
      title: 'طلب اتصال من طبيب',
      body: 'الدكتور $doctorName يريد الاتصال بك',
      payload: 'connection_request:$requestId',
    );
  }

  Future<void> showNewAnalysisNotification({
    required String doctorName,
    required String analysisId,
  }) async {
    await showNotification(
      id: analysisId.hashCode,
      title: 'تحليل جديد',
      body: 'قام الدكتور $doctorName بإضافة تحليل جديد',
      payload: 'analysis:$analysisId',
    );
  }
}
