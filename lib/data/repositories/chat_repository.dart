import 'package:flutter/foundation.dart';
import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../datasources/remote/chat_remote_data_source.dart';

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

  Future<void> startChat(int receiverId) async {
    await _chatRemoteDataSource.startChat(receiverId);
  }

  Future<String> getFirebaseToken() async {
    return await _chatRemoteDataSource.getFirebaseToken();
  }

  Future<List<ChatRoomModel>> getMyChats() async {
    final List<dynamic> chatsData = await _chatRemoteDataSource.getMyChats();
    return chatsData.map((json) => ChatRoomModel.fromJson(json)).toList();
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
      'timestamp': now.toIso8601String(),
      'image_url': imageUrl,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'is_deleted': false,
      'read_at': null,
      'delivered_at': now.toIso8601String(),
    };

    try {
      // Get room to find participants
      final chatRoom = await getChatRoom(chatRoomId);
      final participantIds = chatRoom?.participantIds ?? 
          [senderId.toString(), (await _firebaseDataSource.getChatRoom(chatRoomId))?['receiver_id']?.toString() ?? 'unknown']
          .where((id) => id != 'unknown').toList();
      
      final participantNames = chatRoom?.participantNames ?? {senderId.toString(): senderName};
      final participantAvatars = chatRoom?.participantAvatars ?? {senderId.toString(): senderAvatarUrl};

      // 1. Write to Firebase first (Primary real-time data)
      final messageId = await _firebaseDataSource.sendMessage(
        chatRoomId: chatRoomId,
        messageData: messageData,
        participantIds: participantIds.cast<String>(),
        participantNames: participantNames,
        participantAvatars: participantAvatars,
      );
      messageData['id'] = messageId;
      
      // 2. Clear local draft
      await _localDataSource.clearChatDraft(chatRoomId);

      // 3. SILENT BACKGROUND SYNC to Laravel Backend
      _syncToLaravel(chatRoomId, senderId, senderName, content);

      return MessageModel.fromJson(messageData);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// BUG FIX #11: Robust silent sync to Laravel with improved receiver detection
  Future<void> _syncToLaravel(String chatRoomId, int senderId, String senderName, String content) async {
    try {
      // Get room to find receiverId
      final chatRoom = await getChatRoom(chatRoomId);

      if (chatRoom != null) {
        final receiverIdStr = chatRoom.getOtherParticipantId(senderId.toString());
        final receiverId = int.tryParse(receiverIdStr);

        if (receiverId != null) {
        await _chatRemoteDataSource.updateLastMessage(
          senderId: senderId,
          receiverId: receiverId,
          message: content,
        );
      }
      } else {
        debugPrint('Chat room $chatRoomId not found for Laravel sync.');
      }
    } catch (e) {
      debugPrint('Laravel sync failed: $e');
      // We don't rethrow here as Firebase was already successful
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
    );
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
