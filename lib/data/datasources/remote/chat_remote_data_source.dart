import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';
import '../../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatHistory();
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
  Future<List<MessageModel>> getChatHistory() async {
    final response = await _dioClient.get(ApiConstants.getChatHistory);
    final List<dynamic> data = response.data['history'];
    return data.map((json) => MessageModel.fromJson(json)).toList();
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
      final chats = data['chats'];
      if (chats == null) return [];
      return chats as List<dynamic>;
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

    // API returns { "message": "...", "chat": { "id": 1, "user_one": 2, "user_two": 1, ... } }
    final chatJson = Map<String, dynamic>.from(response.data['chat']);

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
