import '../datasources/remote/notification_remote_data_source.dart';

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<List<dynamic>> getNotifications() async {
    return await _remoteDataSource.getNotifications();
  }

  Future<void> markNotificationsAsRead() async {
    await _remoteDataSource.markAsRead();
  }

  Future<void> deleteNotifications(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    await _remoteDataSource.deleteNotifications(dateStr);
  }
}
