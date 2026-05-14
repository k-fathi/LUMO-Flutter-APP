import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';
import '../../../core/utils/debug_logger.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatHistory();
  Future<String> askAiConsultation(String question);
  Future<String> getFirebaseToken();
  Future<List<dynamic>> getMyChats();
  Future<String> startChat(int receiverId); // ✅ غيّر من void لـ String
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
    return response.data['token'];
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
  Future<String> startChat(int receiverId) async {
    final response = await _dioClient.post(
      ApiConstants.startChat,
      data: {'receiver_id': receiverId},
    );

    final raw = response.data;
    final Map<String, dynamic> data =
        raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    String? roomId;

    if (data.containsKey('chat') && data['chat'] is Map) {
      roomId = data['chat']['id']?.toString();
    } else if (data.containsKey('chat_room_id')) {
      roomId = data['chat_room_id']?.toString();
    }

    if (roomId == null || roomId == 'null') {
      debugPrint('❌ startChat no room id inside: $data');
      throw Exception('لم يرجع الباك إند ID المحادثة. محتوى الرد: $data');
    }

    debugPrint('✅ startChat roomId: $roomId');
    // #region agent log
    DebugLogger.log(
      runId: 'baseline',
      hypothesisId: 'A',
      location: 'chat_remote_data_source.dart:startChat',
      message: 'startChat parsed roomId',
      data: {
        'receiverId': receiverId,
        'hasChatKey': data.containsKey('chat'),
        'hasChatRoomIdKey': data.containsKey('chat_room_id'),
        'roomId': roomId,
      },
    );
    // #endregion
    // #region agent log
    debugPrint('[ae3196][A] REST startChat parsed roomId=$roomId hasChatKey=${data.containsKey('chat')} hasChatRoomIdKey=${data.containsKey('chat_room_id')}');
    // #endregion
    // #region agent log
    // ignore: avoid_print
    print('[ae3196][A] REST startChat parsed roomId=$roomId hasChatKey=${data.containsKey('chat')} hasChatRoomIdKey=${data.containsKey('chat_room_id')}');
    // #endregion
    return roomId;
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
