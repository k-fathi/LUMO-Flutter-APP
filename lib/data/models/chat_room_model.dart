import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Safely parse a dynamic value that could be a Firestore [Timestamp],
  /// an ISO-8601 [String], or null.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Factory constructor from JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Handle API format: user_one/user_two vs standard participant_ids
    List<String> participantIds;
    if (json['participant_ids'] != null) {
      participantIds = (json['participant_ids'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } else if (json['user_one'] != null && json['user_two'] != null) {
      participantIds = [
        json['user_one'].toString(),
        json['user_two'].toString(),
      ];
    } else {
      participantIds = [];
    }

    // Handle last_message_timestamp: API uses 'last_message_time' key
    DateTime? lastMessageTimestamp;
    final rawTime = json['last_message_time'] ?? json['last_message_timestamp'];
    if (rawTime != null) {
      lastMessageTimestamp = _parseDateTime(rawTime);
    }
    
    // ✅ Ensure participantNames والـ participantAvatars بتحتوي على entries للـ participant_ids
    // حتى لو الـ API ما أرجعها null, عشان نتجنب "مستخدم" في الـ UI
    Map<String, String> participantNames = {};
    if (json['participant_names'] is Map) {
      participantNames = Map<String, String>.from(
        (json['participant_names'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v?.toString() ?? '').isEmpty ? 'مستخدم' : v.toString()),
        ),
      );
    }
    // تأكد إن كل participant_id عنده entry بـ participantNames
    for (final id in participantIds) {
      if (!participantNames.containsKey(id) || (participantNames[id]?.isEmpty ?? true)) {
        participantNames[id] = 'مستخدم';
      }
    }

    Map<String, String?> participantAvatars = {};
    if (json['participant_avatars'] is Map) {
      participantAvatars = Map<String, String?>.from(
        (json['participant_avatars'] as Map).map(
          (k, v) => MapEntry(k.toString(), v?.toString()),
        ),
      );
    }

    return ChatRoomModel(
      id: json['id']?.toString() ?? '',
      participantIds: participantIds,
      participantNames: participantNames,
      participantAvatars: participantAvatars,
      lastMessage: json['last_message'] as String?,
      lastMessageSenderId: json['last_message_sender_id']?.toString(),
      lastMessageTimestamp: lastMessageTimestamp,
      unreadCounts: (json['unread_counts'] as Map?)?.map(
        (k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0),
      ) ?? {},
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
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
  bool _matchesUserId(String candidateId, String currentUserId) {
    final normalizedCurrentUserId = int.tryParse(currentUserId)?.toString() ?? currentUserId;
    final normalizedCandidateId = int.tryParse(candidateId)?.toString() ?? candidateId;
    return normalizedCandidateId == currentUserId ||
        normalizedCandidateId == normalizedCurrentUserId;
  }

  String getOtherParticipantId(String currentUserId) {
    // Return first ID that isn't current user, or fallback to any ID
    return participantIds.firstWhere(
      (id) => !_matchesUserId(id, currentUserId),
      orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
    );
  }

  /// استخرج اسم المستخدم التاني مع fallbacks متعددة
  String getOtherParticipantName(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => !_matchesUserId(id, currentUserId),
      orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
    );
    
    // Fallback chain for name
    final fallbackId = participantIds.isNotEmpty ? participantIds.first : '';
    return participantNames[otherId] ??
        participantNames[fallbackId] ??
        'مستخدم غير معروف';
  }

  /// استخرج صورة المستخدم التاني مع fallbacks متعددة
  String? getOtherParticipantAvatar(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => !_matchesUserId(id, currentUserId),
      orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
    );
    
    final fallbackId = participantIds.isNotEmpty ? participantIds.first : '';
    return participantAvatars[otherId] ?? participantAvatars[fallbackId];
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
  
  /// احصل على (اسم، صورة) المستخدم التاني مع جميع الـ fallbacks
  /// النتيجة: (name, avatar)
  (String, String?) getOtherParticipantData(String currentUserId) {
    final name = getOtherParticipantName(currentUserId);
    final avatar = getOtherParticipantAvatar(currentUserId);
    return (name, avatar);
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