import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/repositories/ai_repository.dart';
import '../../../data/models/ai_message_model.dart';

class AIViewModel extends ChangeNotifier {
  final AIRepository _aiRepository;

  AIViewModel(this._aiRepository);

  final List<AIMessageModel> _messages = [];
  bool _isSending = false;
  String? _errorMessage;

  List<AIMessageModel> get messages => _messages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // Load chat history
  Future<void> loadChatHistory(int userId) async {
    try {
      final history = await _aiRepository.getChatHistory(userId);
      _messages.clear();

      if (history.isEmpty) {
        // Add welcome message if history is empty
        _messages.add(
          AIMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 0,
            content:
                'مرحباً! أنا مساعد Lumo AI الذكي. يمكنني مساعدتك في الإجابة عن أسئلتك المتعلقة بصحة الأطفال والرعاية الطبية. كيف يمكنني مساعدتك اليوم؟',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _messages.addAll(history);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage(int userId, String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AIMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Add loading message
    final loadingMessage = AIMessageModel(
      id: '${DateTime.now().millisecondsSinceEpoch + 1}',
      userId: 0,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    _messages.add(loadingMessage);
    _isSending = true;
    notifyListeners();

    try {
      // Send to AI
      final aiResponse = await _aiRepository.sendMessage(
        userId,
        content,
      );

      // Remove loading message
      _messages.removeLast();

      // Add AI response
      _messages.add(aiResponse);
      _isSending = false;
      notifyListeners();
    } catch (e) {
      // Remove loading message
      _messages.removeLast();

      // Add error message
      final errorMessage = AIMessageModel(
        id: '${DateTime.now().millisecondsSinceEpoch + 2}',
        userId: 0,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        error: 'عذراً، حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى.',
      );
      _messages.add(errorMessage);
      _errorMessage = e.toString();
      _isSending = false;
      notifyListeners();
    }
  }

  // Clear chat history
  Future<void> clearChatHistory(int userId) async {
    await _aiRepository.clearChatHistory(userId);
    _messages.clear();
    await loadChatHistory(userId); // Add welcome message again
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetState() {
    _messages.clear();
    _isSending = false;
    _errorMessage = null;
    notifyListeners();
  }
}
