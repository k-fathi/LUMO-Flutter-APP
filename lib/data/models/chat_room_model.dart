class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantAvatars;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTimestamp;
  final Map<String, int> unreadCounts; // userId -> unread count
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, bool> typingStatus; // userId -> isTyping

  const ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTimestamp,
    this.unreadCounts = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.typingStatus = const {},
  });

  // Factory constructor from JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      participantIds: (json['participant_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantNames: Map<String, String>.from(json['participant_names'] as Map),
      participantAvatars: Map<String, String?>.from(json['participant_avatars'] as Map),
      lastMessage: json['last_message'] as String?,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'] as String)
          : null,
      unreadCounts: Map<String, int>.from(json['unread_counts'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      typingStatus: Map<String, bool>.from(json['typing_status'] as Map? ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'participant_avatars': participantAvatars,
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
      'last_message_timestamp': lastMessageTimestamp?.toIso8601String(),
      'unread_counts': unreadCounts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'typing_status': typingStatus,
    };
  }

  // CopyWith method
  ChatRoomModel copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantAvatars,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, bool>? typingStatus,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }

  // Helper methods
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'مستخدم';
  }

  String? getOtherParticipantAvatar(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantAvatars[otherId];
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  bool hasUnreadMessages(String userId) {
    return getUnreadCount(userId) > 0;
  }

  bool isOtherParticipantTyping(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return typingStatus[otherId] ?? false;
  }

  bool get hasLastMessage => lastMessage != null && lastMessage!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, participants: ${participantIds.length})';
  }
}