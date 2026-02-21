enum NotificationType {
  newMessage,
  newComment,
  newLike,
  newFollower,
  connectionRequest,
  connectionAccepted,
  newAnalysis,
  systemNotification;

  String get displayName {
    switch (this) {
      case NotificationType.newMessage:
        return 'رسالة جديدة';
      case NotificationType.newComment:
        return 'تعليق جديد';
      case NotificationType.newLike:
        return 'إعجاب جديد';
      case NotificationType.newFollower:
        return 'متابع جديد';
      case NotificationType.connectionRequest:
        return 'طلب اتصال';
      case NotificationType.connectionAccepted:
        return 'تم قبول الطلب';
      case NotificationType.newAnalysis:
        return 'تحليل جديد';
      case NotificationType.systemNotification:
        return 'إشعار النظام';
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionId; // ID of related entity (post, message, etc.)
  final String? actionType; // Type of action (post, chat, profile, etc.)
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionId,
    this.actionType,
    this.isRead = false,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => NotificationType.systemNotification,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      actionId: json['action_id'] as String?,
      actionType: json['action_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'action_id': actionId,
      'action_type': actionType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // CopyWith method
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    String? actionId,
    String? actionType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionId: actionId ?? this.actionId,
      actionType: actionType ?? this.actionType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool get hasAction => actionId != null && actionType != null;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.name}, isRead: $isRead)';
  }
}