class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final List<String> likedByUserIds;
  final String? parentCommentId; // For nested comments/replies

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.likedByUserIds = const [],
    this.parentCommentId,
  });

  // Factory constructor from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      likedByUserIds: (json['liked_by_user_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      parentCommentId: json['parent_comment_id'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'liked_by_user_ids': likedByUserIds,
      'parent_comment_id': parentCommentId,
    };
  }

  // CopyWith method
  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    List<String>? likedByUserIds,
    String? parentCommentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }

  // Helper methods
  bool isLikedBy(String userId) => likedByUserIds.contains(userId);
  bool get isReply => parentCommentId != null;
  bool get isTopLevel => parentCommentId == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CommentModel(id: $id, postId: $postId, userId: $userId, content: ${content.length} chars)';
  }
}