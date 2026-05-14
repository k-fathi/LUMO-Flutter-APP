import '../datasources/local_data_source.dart';
import '../models/ai_message_model.dart';
import '../../core/services/lumo_api_service.dart';

/// Handles the AI chat flow.
///
/// Sends questions to Asmaa's medical chatbot (:8000/ask) via [LumoApiService]
/// and persists the conversation locally for offline history access.
class AIRepository {
  final LocalDataSource _localDataSource;
  final LumoApiService _apiService;

  AIRepository(this._localDataSource, this._apiService);

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
    final aiResponse = await _apiService.askChatbot(content);
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
