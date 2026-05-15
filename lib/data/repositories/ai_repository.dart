import '../../core/network/dio_client.dart';
import '../../core/network/api_constants.dart';
import '../datasources/local_data_source.dart';
import '../models/ai_message_model.dart';

/// Handles the AI chat flow.
///
/// Sends questions to the AI chatbot via Laravel proxy (/ai/consult)
/// and persists the conversation locally for offline history access.
class AIRepository {
  final LocalDataSource _localDataSource;
  final DioClient _dioClient;

  AIRepository(this._localDataSource, this._dioClient);

  // ==================== AI CHAT ====================

  /// Sends [content] to the live chatbot API and persists both sides of the
  /// conversation to local storage. Returns the AI [AIMessageModel].
  Future<AIMessageModel> sendMessage(int userId, String content) async {
    final userMessage = AIMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // ── Real API call ────────────────────────────────────────────────────────
    String aiResponse = "عذراً، حدث خطأ في معالجة طلبك.";
    try {
      final response = await _dioClient.post(
        ApiConstants.aiConsult,
        data: {
          'message': content,
        },
      );
      
      // Extract the response message depending on the backend format
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is Map && responseData['data'].containsKey('message')) {
            aiResponse = responseData['data']['message'];
        } else if (responseData.containsKey('message')) {
            aiResponse = responseData['message'];
        } else if (responseData.containsKey('answer')) {
            aiResponse = responseData['answer'];
        } else if (responseData.containsKey('response')) {
            aiResponse = responseData['response'];
        } else {
            aiResponse = responseData.toString();
        }
      } else {
        aiResponse = responseData.toString();
      }
    } catch (e) {
      aiResponse = "عذراً، لم نتمكن من الوصول إلى المساعد الذكي حالياً.";
    }
    // ─────────────────────────────────────────────────────────────────────────

    final aiMessage = AIMessageModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );

    // Persist both messages to local cache.
    final history = await getChatHistory(userId);
    history.add(userMessage);
    history.add(aiMessage);
    await _localDataSource.saveAiHistory(
      userId.toString(),
      history.map((e) => e.toJson()).toList(),
    );

    return aiMessage;
  }

  /// Returns persisted chat history for [userId] from local cache.
  Future<List<AIMessageModel>> getChatHistory(int userId) async {
    final cachedData = _localDataSource.getAiHistory(userId.toString());
    if (cachedData != null) {
      return cachedData.map((data) => AIMessageModel.fromJson(data)).toList();
    }
    return [];
  }

  /// Clears all chat history for [userId] from local cache.
  Future<void> clearChatHistory(int userId) async {
    await _localDataSource.remove('ai_history_$userId');
  }
}
