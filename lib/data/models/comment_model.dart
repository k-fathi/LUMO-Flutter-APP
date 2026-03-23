import '../../core/utils/date_formatter.dart';

class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final List<int> likedByUserIds;
  final int? parentCommentId; // For nested comments/replies
  final bool isLiked;

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
    this.isLiked = false,
  });

  // Factory constructor from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Robust parsing for user data (handles nested objects like 'user' or 'author')
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user']
        : (json['author'] is Map<String, dynamic>
            ? json['author']
            : (json['commenter'] is Map<String, dynamic>
                ? json['commenter']
                : (json['member'] is Map<String, dynamic> ? json['member'] : null)));

    final userName = json['user_name']?.toString() ??
        userMap?['name']?.toString() ??
        userMap?['full_name']?.toString() ??
        '';

    final userAvatarUrl = json['user_avatar_url']?.toString() ??
        userMap?['avatar_url']?.toString() ??
        userMap?['profile_image']?.toString() ??
        userMap?['image']?.toString();

    return CommentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      postId: json['post_id'] is int
          ? json['post_id']
          : int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] ?? json['author_id'] ?? userMap?['id'] ?? 0,
      userName: userName.isNotEmpty ? userName : '',
      userAvatarUrl: userAvatarUrl,
      content: (json['content'] ?? json['comment'])?.toString() ?? '',
      createdAt: DateFormatter.parseServerDateTime(json['created_at']?.toString()),
      updatedAt: DateFormatter.parseServerDateTime(json['updated_at']?.toString()),
      likesCount: json['likes_count'] as int? ?? 0,
      likedByUserIds: (json['liked_by_user_ids'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      parentCommentId: (json['parent_comment_id'] ?? json['parent_id']) != null && 
                       (json['parent_comment_id'] ?? json['parent_id']).toString() != '0'
          ? int.tryParse((json['parent_comment_id'] ?? json['parent_id']).toString())
          : null,
      isLiked: json['is_liked'] == true ||
          json['liked'] == true ||
          json['has_liked'] == true ||
          json['is_liked'] == 1 ||
          json['is_liked']?.toString() == 'true',
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
      'is_liked': isLiked,
    };
  }

  // CopyWith method
  CommentModel copyWith({
    int? id,
    int? postId,
    int? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    List<int>? likedByUserIds,
    int? parentCommentId,
    bool? isLiked,
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
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Helper methods
  bool isLikedBy(int userId) => isLiked || likedByUserIds.contains(userId);
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
