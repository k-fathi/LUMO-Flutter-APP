import '../../core/services/mock_api_service.dart';
import '../../core/utils/mock_delay.dart';

class MockDataSource {
  final MockApiService _mockApi;

  MockDataSource(this._mockApi);

  // ==================== MOCK USER DATA ====================

  Future<Map<String, dynamic>> getMockUser(String userId) async {
    await MockDelay.short();
    return {
      'id': userId,
      'email': 'user$userId@example.com',
      'name': 'مستخدم تجريبي',
      'role': 'parent',
      'avatar_url': null,
      'bio': 'هذا حساب تجريبي للاختبار',
      'phone': '+966500000000',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'followers_count': 42,
      'following_count': 15,
      'is_verified': false,
      'is_active': true,
    };
  }

  Future<List<Map<String, dynamic>>> getMockUsers(int count) async {
    await MockDelay.short();
    return List.generate(count, (i) => {
      'id': 'user_$i',
      'email': 'user$i@example.com',
      'name': 'مستخدم ${i + 1}',
      'role': i % 3 == 0 ? 'doctor' : 'parent',
      'avatar_url': null,
      'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'followers_count': (i * 10),
      'following_count': (i * 5),
      'is_verified': i % 5 == 0,
      'is_active': true,
    });
  }

  // ==================== MOCK POST DATA ====================

  Future<List<Map<String, dynamic>>> getMockPosts(int count) async {
    await MockDelay.short();
    return List.generate(count, (i) => {
      'id': 'post_$i',
      'user_id': 'user_${i % 5}',
      'user_name': 'مستخدم ${(i % 5) + 1}',
      'user_avatar_url': null,
      'content': 'منشور تجريبي رقم $i - هذا محتوى للاختبار فقط',
      'image_url': i % 3 == 0 ? 'https://picsum.photos/400/300?random=$i' : null,
      'status': 'published',
      'created_at': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
      'updated_at': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
      'likes_count': i * 5,
      'comments_count': i * 2,
      'shares_count': i,
      'liked_by_user_ids': [],
      'tags': [],
      'is_pinned': i == 0,
    });
  }

  // ==================== MOCK COMMENT DATA ====================

  Future<List<Map<String, dynamic>>> getMockComments(String postId, int count) async {
    await MockDelay.short();
    return List.generate(count, (i) => {
      'id': 'comment_$i',
      'post_id': postId,
      'user_id': 'user_${i % 3}',
      'user_name': 'مستخدم ${(i % 3) + 1}',
      'user_avatar_url': null,
      'content': 'تعليق تجريبي رقم $i',
      'created_at': DateTime.now().subtract(Duration(minutes: i * 10)).toIso8601String(),
      'updated_at': DateTime.now().subtract(Duration(minutes: i * 10)).toIso8601String(),
      'likes_count': i,
      'liked_by_user_ids': [],
      'parent_comment_id': null,
    });
  }

  // ==================== MOCK CHAT DATA ====================

  Future<List<Map<String, dynamic>>> getMockChats(String userId, int count) async {
    await MockDelay.short();
    return List.generate(count, (i) {
      final otherId = 'user_${i + 1}';
      return {
        'id': 'chat_$i',
        'participant_ids': [userId, otherId],
        'participant_names': {
          userId: 'أنا',
          otherId: 'مستخدم ${i + 1}',
        },
        'participant_avatars': {
          userId: null,
          otherId: null,
        },
        'last_message': 'آخر رسالة في المحادثة $i',
        'last_message_sender_id': i % 2 == 0 ? userId : otherId,
        'last_message_timestamp': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        'unread_counts': {
          userId: i % 3,
          otherId: 0,
        },
        'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'updated_at': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        'is_active': true,
        'typing_status': {
          userId: false,
          otherId: false,
        },
      };
    });
  }

  Future<List<Map<String, dynamic>>> getMockMessages(String chatId, int count) async {
    await MockDelay.short();
    return List.generate(count, (i) => {
      'id': 'message_$i',
      'chat_room_id': chatId,
      'sender_id': i % 2 == 0 ? 'current_user' : 'other_user',
      'sender_name': i % 2 == 0 ? 'أنا' : 'المستخدم الآخر',
      'sender_avatar_url': null,
      'content': 'رسالة تجريبية رقم $i',
      'status': i % 2 == 0 ? 'read' : 'sent',
      'timestamp': DateTime.now().subtract(Duration(minutes: (count - i) * 5)).toIso8601String(),
      'image_url': null,
      'file_url': null,
      'file_name': null,
      'file_size': null,
      'is_deleted': false,
      'read_at': i % 2 == 0 ? DateTime.now().toIso8601String() : null,
      'delivered_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== MOCK ANALYSIS DATA ====================

  Future<List<Map<String, dynamic>>> getMockAnalyses(String parentId, int count) async {
    await MockDelay.short();
    final states = ['critical', 'bad', 'moderate', 'good', 'excellent'];

    return List.generate(count, (i) {
      final currentState = states[i % states.length];
      return {
        'id': 'analysis_$i',
        'parent_id': parentId,
        'parent_name': 'ولي الأمر',
        'child_name': 'الطفل',
        'doctor_id': 'doctor_1',
        'doctor_name': 'د. أحمد',
        'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'notes': i % 2 == 0 ? 'ملاحظات تجريبية رقم $i' : null,
        'current_state': currentState,
        'states': states.asMap().entries.map((e) => {
          'state': e.value,
          'label': _getStateLabel(e.value),
          'description': null,
          'is_current': e.value == currentState,
        }).toList(),
        'attachment_url': null,
        'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'updated_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      };
    });
  }

  String _getStateLabel(String state) {
    switch (state) {
      case 'critical': return 'حرج';
      case 'bad': return 'سيء';
      case 'moderate': return 'متوسط';
      case 'good': return 'جيد';
      case 'excellent': return 'ممتاز';
      default: return 'متوسط';
    }
  }

  // ==================== MOCK DOCTOR CODE DATA ====================

  Future<Map<String, dynamic>> generateMockDoctorCode(String doctorId) async {
    await MockDelay.short();
    final code = 'DOC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    return {
      'id': 'code_${DateTime.now().millisecondsSinceEpoch}',
      'code': code,
      'doctor_id': doctorId,
      'doctor_name': 'د. أحمد',
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      'is_active': true,
      'usage_count': 0,
      'max_usage': 100,
    };
  }

  // ==================== MOCK CONNECTION REQUESTS ====================

  Future<List<Map<String, dynamic>>> getMockConnectionRequests(String doctorId, int count) async {
    await MockDelay.short();
    final statuses = ['pending', 'accepted', 'rejected'];

    return List.generate(count, (i) => {
      'id': 'request_$i',
      'parent_id': 'parent_$i',
      'parent_name': 'ولي أمر $i',
      'parent_avatar_url': null,
      'child_name': 'طفل $i',
      'child_age': 3 + i,
      'doctor_id': doctorId,
      'doctor_name': 'د. أحمد',
      'doctor_avatar_url': null,
      'doctor_code': 'DOC12345',
      'status': statuses[i % statuses.length],
      'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      'updated_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      'responded_at': i % 3 != 0 ? DateTime.now().subtract(Duration(days: i - 1)).toIso8601String() : null,
      'rejection_reason': null,
    });
  }

  // ==================== MOCK AI MESSAGES ====================

  Future<String> sendMockAIMessage(String message) async {
    return await _mockApi.sendAIMessage(message);
  }

  // ==================== MOCK NOTIFICATIONS ====================

  Future<List<Map<String, dynamic>>> getMockNotifications(String userId, int count) async {
    await MockDelay.short();
    final types = ['newMessage', 'newComment', 'newLike', 'newFollower', 'connectionRequest'];

    return List.generate(count, (i) => {
      'id': 'notification_$i',
      'user_id': userId,
      'type': types[i % types.length],
      'title': 'إشعار تجريبي $i',
      'body': 'محتوى الإشعار التجريبي رقم $i',
      'image_url': null,
      'action_id': 'action_$i',
      'action_type': 'post',
      'is_read': i % 3 == 0,
      'created_at': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
    });
  }

  // ==================== SEARCH ====================

  Future<List<Map<String, dynamic>>> searchMockUsers(String query) async {
    return await _mockApi.searchUsers(query);
  }

  Future<List<Map<String, dynamic>>> searchMockPosts(String query) async {
    return await _mockApi.searchPosts(query);
  }
}