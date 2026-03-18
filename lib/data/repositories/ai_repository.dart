import '../datasources/local_data_source.dart';
import '../datasources/mock_data_source.dart';
import '../models/ai_message_model.dart';

class AIRepository {
  final MockDataSource _mockDataSource;
  final LocalDataSource _localDataSource;

  AIRepository(this._mockDataSource, this._localDataSource);

  // ==================== AI CHAT ====================

  Future<AIMessageModel> sendMessage(int userId, String content) async {
    // Send user message
    final userMessage = AIMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Get AI response
    final aiResponse = await _mockDataSource.sendMockAIMessage(content);

    // Create AI message
    final aiMessage = AIMessageModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );

    // Persist to local storage
    final history = await getChatHistory(userId);
    history.add(userMessage);
    history.add(aiMessage);
    await _localDataSource.saveAiHistory(
        userId.toString(), history.map((e) => e.toJson()).toList());

    return aiMessage;
  }

  Future<List<AIMessageModel>> getChatHistory(int userId) async {
    final cachedData = _localDataSource.getAiHistory(userId.toString());
    if (cachedData != null) {
      return cachedData.map((data) => AIMessageModel.fromJson(data)).toList();
    }
    return [];
  }

  Future<void> clearChatHistory(int userId) async {
    await _localDataSource.remove('ai_history_$userId');
  }
}
