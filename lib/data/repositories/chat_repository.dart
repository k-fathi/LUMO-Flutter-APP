
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../datasources/remote/chat_remote_data_source.dart';
import '../../core/enums/message_status.dart';

class ChatRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;
  final ChatRemoteDataSource _chatRemoteDataSource;

  ChatRepository(
    this._firebaseDataSource,
    this._localDataSource,
    this._chatRemoteDataSource,
  );

  // ==================== CHAT ROOM OPERATIONS ====================

  Future<ChatRoomModel> createChatRoom({
    required List<int> participantIds,
    required Map<String, String> participantNames,
    required Map<String, String?> participantAvatars,
  }) async {
    final now = DateTime.now();

    final chatRoomData = {
      'participant_ids': participantIds.map((id) => id.toString()).toList(),
      'participant_names': participantNames,
      'participant_avatars': participantAvatars,
      'last_message': null,
      'last_message_sender_id': null,
      'last_message_timestamp': null,
      'unread_counts': {for (var id in participantIds) id.toString(): 0},
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_active': true,
      'typing_status': {for (var id in participantIds) id.toString(): false},
    };

    final chatRoomId = await _firebaseDataSource.createChatRoom(chatRoomData);
    chatRoomData['id'] = chatRoomId;

    return ChatRoomModel.fromJson(chatRoomData);
  }

  Future<ChatRoomModel> startChat(int receiverId) async {
    return await _chatRemoteDataSource.startChat(receiverId);
  }

  Future<String> getFirebaseToken() async {
    return await _chatRemoteDataSource.getFirebaseToken();
  }

  Future<List<ChatRoomModel>> getMyChats() async {
    try {
      final List<dynamic> chatsData = await _chatRemoteDataSource.getMyChats();
      // Cache for offline/restart persistence
      await _localDataSource.cacheChats(chatsData.cast<Map<String, dynamic>>());
      return chatsData.map((json) => ChatRoomModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('REST getMyChats failed, falling back to cache: $e');
      return getCachedChats();
    }
  }

  List<ChatRoomModel> getCachedChats() {
    final cachedData = _localDataSource.getCachedChats();
    if (cachedData != null) {
      return cachedData.map((data) => ChatRoomModel.fromJson(data)).toList();
    }
    return [];
  }

  Future<List<MessageModel>> getChatHistoryFromApi(String chatRoomId, [int? receiverId]) async {
    try {
      final messages = await _chatRemoteDataSource.getChatHistory(chatRoomId: chatRoomId, receiverId: receiverId);
      if (messages.isNotEmpty) {
        final cachedMessages = getCachedMessages(chatRoomId);
        final existingIds = cachedMessages.map((m) => m.id).toSet();
        
        final newMessages = messages.where((m) => !existingIds.contains(m.id)).toList();
        if (newMessages.isNotEmpty) {
          cachedMessages.addAll(newMessages);
          cachedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          await _localDataSource.cacheMessages(chatRoomId, cachedMessages.map((m) => m.toJson()).toList());
        }
      }
      return messages;
    } catch (e) {
      debugPrint("API History fetch failed: $e");
      return [];
    }
  }

  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async {
    final chatRoomData = await _firebaseDataSource.getChatRoom(chatRoomId);
    return chatRoomData != null ? ChatRoomModel.fromJson(chatRoomData) : null;
  }

  Stream<ChatRoomModel?> streamChatRoom(String chatRoomId) {
    return _firebaseDataSource.streamChatRoom(chatRoomId).map(
          (chatRoomData) => chatRoomData != null
              ? ChatRoomModel.fromJson(chatRoomData)
              : null,
        );
  }

  Stream<List<ChatRoomModel>> streamUserChats(int userId) {
    return _firebaseDataSource.streamUserChats(userId.toString()).map(
          (chatsList) => chatsList
              .map((chatData) => ChatRoomModel.fromJson(chatData))
              .toList(),
        );
  }

  // ==================== MESSAGE OPERATIONS ====================

  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String senderName,
    String? senderAvatarUrl,
    required String content,
    required int receiverId, // ✅ أضف
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    final now = DateTime.now();

    final messageData = {
      'chat_room_id': chatRoomId,
      'sender_id': senderId.toString(),
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'content': content,
      'status': 'sent',
      'timestamp': FieldValue.serverTimestamp(),
      'image_url': imageUrl,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'is_deleted': false,
      'read_at': null,
      'delivered_at': now.toIso8601String(),
    };

    // ✅ FIX C-6: مش محتاجين نجيب الـ room من Firebase — عندنا الـ participants
    final participantIds = [senderId.toString(), receiverId.toString()];
    final participantNames = {senderId.toString(): senderName};
    final participantAvatars = {senderId.toString(): senderAvatarUrl};

    String messageId = '';
    try {
      messageId = await _firebaseDataSource.sendMessage(
        chatRoomId: chatRoomId,
        messageData: messageData,
        participantIds: participantIds,
        participantNames: participantNames,
        participantAvatars: participantAvatars,
        receiverId: receiverId.toString(),
      );
    } catch (e) {
      debugPrint('Firebase sendMessage failed (Likely unsupported platform like Linux): $e');
      messageId = 'local_${now.millisecondsSinceEpoch}';
    }
    messageData['id'] = messageId;
    
    await _localDataSource.clearChatDraft(chatRoomId);

    // Sync to Laravel regardless of Firebase success (Crucial for Linux testing)
    await _syncToLaravel(chatRoomId, senderId, receiverId, content);

    final sentMessage = MessageModel.fromJson(messageData);
    
    // Manually cache message so it persists across restarts on Linux
    final cachedMessages = getCachedMessages(chatRoomId);
    cachedMessages.add(sentMessage);
    await _localDataSource.cacheMessages(chatRoomId, cachedMessages.map((m) => m.toJson()).toList());

    // Update room list cache too, so the 'last message' and room existence persist on Linux
    await _updateLocalRoomCache(
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatarUrl,
      content: content,
      timestamp: now,
      receiverId: receiverId,
    );

    return sentMessage;
  }

  /// Syncs an individual message's effect to the local rooms list cache.
  Future<void> _updateLocalRoomCache({
    required String chatRoomId,
    required int senderId,
    required String senderName,
    required String? senderAvatar,
    required String content,
    required DateTime timestamp,
    required int receiverId,
  }) async {
    final rooms = getCachedChats();
    final index = rooms.indexWhere((r) => r.id == chatRoomId);
    
    if (index != -1) {
      final updated = rooms[index].copyWith(
        lastMessage: content,
        lastMessageSenderId: senderId.toString(),
        lastMessageTimestamp: timestamp,
        updatedAt: timestamp,
      );
      rooms[index] = updated;
    } else {
      // Room doesn't exist in cache (likely newly started on Linux)
      // Create a mock room entry to keep it in the list
      final newRoom = ChatRoomModel(
        id: chatRoomId,
        participantIds: [senderId.toString(), receiverId.toString()],
        participantNames: {senderId.toString(): senderName},
        participantAvatars: {senderId.toString(): senderAvatar},
        lastMessage: content,
        lastMessageSenderId: senderId.toString(),
        lastMessageTimestamp: timestamp,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      rooms.add(newRoom);
    }
    
    await _localDataSource.cacheChats(rooms.map((r) => r.toJson()).toList());
  }

  /// BUG FIX #11: Robust silent sync to Laravel with improved receiver detection
  Future<void> _syncToLaravel(
    String chatRoomId,
    int senderId,
    int receiverId,
    String content,
  ) async {
    try {
      await _chatRemoteDataSource.updateLastMessage(
        senderId: senderId,
        receiverId: receiverId,
        message: content,
      );
    } catch (e) {
      debugPrint('Laravel sync failed (non-critical): $e');
    }
  }

  Stream<List<MessageModel>> streamMessages(String chatRoomId) {
    return _firebaseDataSource.streamMessages(chatRoomId).map(
      (messagesList) {
        // Cache messages locally
        _localDataSource.cacheMessages(chatRoomId, messagesList);

        return messagesList
            .map((messageData) => MessageModel.fromJson(messageData))
            .toList();
      },
    ).handleError((error) {
      debugPrint('Firebase streamMessages error (falling back to cache): $error');
      // On platforms where Firebase isn't supported (e.g. Linux),
      // return cached messages so the UI isn't left empty.
      return getCachedMessages(chatRoomId);
    });
  }

  List<MessageModel> getCachedMessages(String chatRoomId) {
    final cachedData = _localDataSource.getCachedMessages(chatRoomId);
    if (cachedData != null) {
      return cachedData.map((data) => MessageModel.fromJson(data)).toList();
    }
    return [];
  }

  Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
    await _firebaseDataSource.markMessageAsRead(chatRoomId, messageId);
  }

  Future<void> markChatAsRead(String chatRoomId, int userId) async {
    await _firebaseDataSource.markChatAsRead(chatRoomId, userId.toString());
  }

  /// Batch-mark all visible unread messages from the OTHER user as 'read'.
  Future<void> markVisibleMessagesAsRead(
      String chatRoomId, List<MessageModel> messages, int currentUserId) async {
    final unreadIds = messages
        .where((m) =>
            m.senderId != currentUserId &&
            m.status != MessageStatus.read)
        .map((m) => m.id)
        .toList();
    if (unreadIds.isEmpty) return;
    await _firebaseDataSource.markVisibleMessagesAsRead(chatRoomId, unreadIds);
  }

  Future<void> updateTypingStatus(
      String chatRoomId, int userId, bool isTyping) async {
    await _firebaseDataSource.updateTypingStatus(
        chatRoomId, userId.toString(), isTyping);
  }

  // ==================== DRAFT OPERATIONS ====================

  Future<void> saveChatDraft(String chatRoomId, String message) async {
    await _localDataSource.saveChatDraft(chatRoomId, message);
  }

  String? getChatDraft(String chatRoomId) {
    return _localDataSource.getChatDraft(chatRoomId);
  }

  Future<void> clearChatDraft(String chatRoomId) async {
    await _localDataSource.clearChatDraft(chatRoomId);
  }
}
