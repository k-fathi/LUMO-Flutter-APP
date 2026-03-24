import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';

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
    return response.data['chats'];
  }

  @override
  Future<String> startChat(int receiverId) async {
    final response = await _dioClient.post(
      ApiConstants.startChat,
      data: {'receiver_id': receiverId},
    );
    final data = response.data as Map<String, dynamic>;
    
    // ✅ Backend بيرجع الـ chatRoomId الثابت — تأكد من الـ key مع الـ backend
    final roomId = data['chat_room_id']?.toString() ??
        data['room']?['id']?.toString() ??
        data['id']?.toString();
        
    if (roomId == null) {
      throw Exception('Backend لم يرجع chat_room_id');
    }
    
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
