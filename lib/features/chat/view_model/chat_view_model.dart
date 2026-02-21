import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';

/// Chat ViewModel
///
/// Manages chat rooms and messages state
/// Features:
/// - Load chat rooms
/// - Load messages
/// - Send messages
/// - Real-time updates
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel(this._chatRepository);

  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  final List<ChatRoomModel> _chatRooms = [];
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  /// Load chat rooms for user
  Future<void> loadChatRooms(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Subscribe to stream from repository
      _chatRooms.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load messages for chat room
  Future<void> loadMessages(String chatRoomId) async {
    _isLoading = true;
    _errorMessage = null;

    // Load cached messages first for immediate response
    _messages.clear();
    _messages.addAll(_chatRepository.getCachedMessages(chatRoomId));
    notifyListeners();

    try {
      await _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.streamMessages(chatRoomId).listen(
        (messagesList) {
          _messages.clear();
          _messages.addAll(messagesList);
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderAvatarUrl,
  }) async {
    _isSending = true;
    notifyListeners();

    try {
      final message = await _chatRepository.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        content: content,
      );

      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearState() {
    _chatRooms.clear();
    _messages.clear();
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _errorMessage = null;
    _isLoading = false;
    _isSending = false;
    notifyListeners();
  }
}
