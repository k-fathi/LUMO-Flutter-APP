import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';
import '../../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatHistory({int? receiverId, String? chatRoomId});
  Future<String> askAiConsultation(String question);
  Future<String> getFirebaseToken();
  Future<List<dynamic>> getMyChats();
  Future<ChatRoomModel> startChat(int receiverId);
  Future<void> updateLastMessage({
    required int senderId,
    required int receiverId,
    required String message,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<MessageModel>> getChatHistory({int? receiverId, String? chatRoomId}) async {
    final queryParams = <String, dynamic>{};
    if (receiverId != null) queryParams['receiver_id'] = receiverId;
    if (chatRoomId != null) queryParams['chat_room_id'] = chatRoomId;

    try {
      final response = await _dioClient.get(ApiConstants.getChatHistory, queryParameters: queryParams);
      List<dynamic> data = [];
      if (response.data is Map) {
        data = response.data['history'] ?? response.data['data'] ?? response.data['messages'] ?? [];
      } else if (response.data is List) {
        data = response.data;
      }
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('REST history error: $e');
      return [];
    }
  }

  @override
  Future<String> askAiConsultation(String question) async {
    final response = await _dioClient.post(
      ApiConstants.aiConsult,
      data: {'question': question},
    );
    return response.data['answer'];
  }

  @override
  Future<String> getFirebaseToken() async {
    final response = await _dioClient.get(ApiConstants.firebaseToken);
    debugPrint('🔍 getFirebaseToken raw response: ${response.data}');
    final token = response.data['firebase_token'] as String; // ✅ غيرت 'token' لـ 'firebase_token'
    debugPrint('🔑 Extracted token: $token');
    return token;
  }

  @override
  Future<List<dynamic>> getMyChats() async {
    final response = await _dioClient.get(ApiConstants.myChats);
    final data = response.data;
    if (data == null) return [];
    if (data is Map) {
      // API returns { "data": [...] } — try 'data' key first, then 'chats' as fallback
      final chats = data['data'] ?? data['chats'];
      if (chats == null) return [];
      if (chats is List) return chats;
      return [];
    }
    if (data is List) return data;
    return [];
  }

  @override
  Future<ChatRoomModel> startChat(int receiverId) async {
    debugPrint('🚀 startChat called with receiverId: $receiverId');
    final response = await _dioClient.post(
      ApiConstants.startChat,
      data: {'receiver_id': receiverId},
    );

    debugPrint('🔍 startChat raw response: ${response.data}');

    // Handle different possible API wrapper formats
    Map<String, dynamic> chatJson;
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('chat') && data['chat'] is Map) {
        chatJson = Map<String, dynamic>.from(data['chat']);
      } else if (data.containsKey('data') && data['data'] is Map) {
        chatJson = Map<String, dynamic>.from(data['data']);
      } else {
        chatJson = data;
      }
    } else {
      throw Exception('Unexpected response format from startChat API');
    }

    debugPrint('🔍 chatJson extracted: $chatJson');
    debugPrint('✅ chatRoomId from API: ${chatJson['id']}');

    return ChatRoomModel.fromJson(chatJson);
  }

  @override
  Future<void> updateLastMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    await _dioClient.post(
      ApiConstants.updateLastMessage,
      data: {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      },
    );
  }
}
