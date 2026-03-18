import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatHistory();
  Future<String> askAiConsultation(String question);
  Future<String> getFirebaseToken();
  Future<List<dynamic>> getMyChats();
  Future<void> startChat(int receiverId);
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
  Future<void> startChat(int receiverId) async {
    await _dioClient.post(
      ApiConstants.startChat,
      data: {'receiver_id': receiverId},
    );
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
