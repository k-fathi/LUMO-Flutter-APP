import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatHistory();
  Future<String> askAiConsultation(String question);
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
}
