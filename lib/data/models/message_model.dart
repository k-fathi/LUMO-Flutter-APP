import '../../core/enums/message_status.dart';

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageStatus status;
  final DateTime timestamp;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final bool isDeleted;
  final DateTime? readAt;
  final DateTime? deliveredAt;

  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.isDeleted = false,
    this.readAt,
    this.deliveredAt,
  });

  // Factory constructor from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      senderAvatarUrl: json['sender_avatar_url'] as String?,
      content: json['content'] as String,
      status: MessageStatus.fromString(json['status'] as String? ?? 'sent'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUrl: json['image_url'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'content': content,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'is_deleted': isDeleted,
      'read_at': readAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  // CopyWith method
  MessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageStatus? status,
    DateTime? timestamp,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    bool? isDeleted,
    DateTime? readAt,
    DateTime? deliveredAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isDeleted: isDeleted ?? this.isDeleted,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  // Helper methods
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get hasAttachment => hasImage || hasFile;
  bool get isRead => status.isRead;
  bool get isDelivered => status.isDelivered;
  bool get isSending => status.isSending;
  bool get isFailed => status.isFailed;

  bool isSentBy(String userId) => senderId == userId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, sender: $senderId, status: ${status.name})';
  }
}