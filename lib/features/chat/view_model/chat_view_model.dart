import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';
import '../../../core/services/firebase_auth_service.dart';

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
  final FirebaseAuthService _firebaseAuthService;

  ChatViewModel(this._chatRepository, this._firebaseAuthService);

  bool _isDisposed = false;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<ChatRoomModel?>? _roomSubscription;

  @override
  void dispose() {
    _isDisposed = true;
    _messagesSubscription?.cancel();
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  final List<ChatRoomModel> _chatRooms = [];
  final List<MessageModel> _messages = [];
  ChatRoomModel? _currentChatRoom;
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<MessageModel> get messages => _messages;
  ChatRoomModel? get currentChatRoom => _currentChatRoom;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  /// Authenticate with Firebase using Laravel custom token
  Future<bool> authenticateFirebase() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final token = await _chatRepository.getFirebaseToken();
      await _firebaseAuthService.signInWithCustomToken(token);
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Firebase Auth Failed: ${e.toString()}";
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  /// Load chat rooms for user
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final rooms = await _chatRepository.getMyChats();
      _chatRooms.clear();
      _chatRooms.addAll(rooms);
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Load messages for chat room
  Future<void> loadMessages(String chatRoomId) async {
    _isLoading = true;
    _errorMessage = null;

    // Load cached messages first
    _messages.clear();
    _messages.addAll(_chatRepository.getCachedMessages(chatRoomId));
    _safeNotifyListeners();

    try {
      // Stream Room Metadata (typing, etc)
      await _roomSubscription?.cancel();
      _roomSubscription = _chatRepository.streamChatRoom(chatRoomId).listen(
        (room) {
          _currentChatRoom = room;
          _safeNotifyListeners();
        },
      );

      // Stream Messages
      await _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.streamMessages(chatRoomId).listen(
        (messagesList) {
          _messages.clear();
          _messages.addAll(messagesList);
          _isLoading = false;
          _safeNotifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          _isLoading = false;
          _safeNotifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Send message
  Future<bool> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String senderName,
    required String content,
    String? senderAvatarUrl,
  }) async {
    _isSending = true;
    _safeNotifyListeners();

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
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSending = false;
      _safeNotifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void clearState() {
    _chatRooms.clear();
    _messages.clear();
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _errorMessage = null;
    _isLoading = false;
    _isSending = false;
    _safeNotifyListeners();
  }
}
