import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

abstract class NotificationRemoteDataSource {
  Future<List<dynamic>> getNotifications();
  Future<void> markAsRead();
  Future<void> deleteNotifications(String date);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<dynamic>> getNotifications() async {
    final response = await _dioClient.get(ApiConstants.getNotifications);
    // Based on Postman, it returns { "notifications": [...] } or { "data": [...] }
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['notifications'] ?? data['data'] ?? [];
    }
    return [];
  }

  @override
  Future<void> markAsRead() async {
    await _dioClient.post(ApiConstants.readNotifications);
  }

  @override
  Future<void> deleteNotifications(String date) async {
    await _dioClient.delete(
      '${ApiConstants.deleteNotifications}?date=$date',
    );
  }
}
