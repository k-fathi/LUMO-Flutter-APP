import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;

  ChatRepository(this._firebaseDataSource, this._localDataSource);

  // ==================== CHAT ROOM OPERATIONS ====================

  Future<ChatRoomModel> createChatRoom({
    required List<String> participantIds,
    required Map<String, String> participantNames,
    required Map<String, String?> participantAvatars,
  }) async {
    final now = DateTime.now();

    final chatRoomData = {
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'participant_avatars': participantAvatars,
      'last_message': null,
      'last_message_sender_id': null,
      'last_message_timestamp': null,
      'unread_counts': {for (var id in participantIds) id: 0},
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_active': true,
      'typing_status': {for (var id in participantIds) id: false},
    };

    final chatRoomId = await _firebaseDataSource.createChatRoom(chatRoomData);
    chatRoomData['id'] = chatRoomId;

    return ChatRoomModel.fromJson(chatRoomData);
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

  Stream<List<ChatRoomModel>> streamUserChats(String userId) {
    return _firebaseDataSource.streamUserChats(userId).map(
          (chatsList) => chatsList
              .map((chatData) => ChatRoomModel.fromJson(chatData))
              .toList(),
        );
  }

  // ==================== MESSAGE OPERATIONS ====================

  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
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
      'sender_id': senderId,
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

    final messageId =
        await _firebaseDataSource.sendMessage(chatRoomId, messageData);
    messageData['id'] = messageId;

    // Save draft (empty it after sending)
    await _localDataSource.clearChatDraft(chatRoomId);

    return MessageModel.fromJson(messageData);
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
