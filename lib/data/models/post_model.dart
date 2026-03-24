import '../../core/enums/post_status.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/date_formatter.dart';

class PostModel {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String? imageUrl;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<int> likedByUserIds;
  final List<String> tags;
  final bool isPinned;
  final bool isLiked;
  final UserRole? userRole;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    this.status = PostStatus.published,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedByUserIds = const [],
    this.tags = const [],
    this.isPinned = false,
    this.isLiked = false,
    this.userRole,
  });

  // Factory constructor from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? userMap = json['user'] is Map<String, dynamic>
        ? json['user']
        : (json['author'] is Map<String, dynamic> ? json['author'] : null);

    final String rawRole = json['user_role']?.toString() ??
        userMap?['role']?.toString() ??
        json['role']?.toString() ??
        '';
    final UserRole? userRole = rawRole.trim().isEmpty
        ? null
        : UserRole.fromString(rawRole);

    final int parsedId = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final int parsedUserId = int.tryParse(
            json['user_id']?.toString() ?? userMap?['id']?.toString() ?? '0') ??
        0;

    // --- الفلتر السحري لتنظيف الاسم من الـ null ---
    String rawName = json['user_name']?.toString() ??
        userMap?['name']?.toString() ??
        userMap?['full_name']?.toString() ??
        json['name']?.toString() ??
        '';

    // بنمسح كلمة null لو الباك إند باعت كنص أو أي قيم تانية غير مرغوب فيها
    rawName = rawName.replaceAll('null', '').replaceAll('NULL', '').trim();
    if (rawName.isEmpty || rawName == 'مستخدم') {
      rawName = 'مستخدم'; // القيمة الاحتياطية النضيفة
    }
    // ------------------------------------------------

    return PostModel(
      id: parsedId,
      userId: parsedUserId,
      userName: rawName,
      userAvatarUrl: json['user_avatar_url']?.toString() ??
          userMap?['avatar_url']?.toString() ??
          userMap?['profile_image']?.toString(),
      content:
          (json['content'] ?? json['body'] ?? json['text'])?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      status: PostStatus.fromString(json['status']?.toString() ?? 'published'),
      createdAt:
          DateFormatter.parseServerDateTime(json['created_at']?.toString()),
      updatedAt:
          DateFormatter.parseServerDateTime(json['updated_at']?.toString()),
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      commentsCount:
          int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0,
      sharesCount: int.tryParse(json['shares_count']?.toString() ?? '0') ?? 0,
      likedByUserIds: json['liked_by_user_ids'] is List
          ? (json['liked_by_user_ids'] as List)
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList()
          : [],
      tags: json['tags'] is List
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : [],
      userRole: userRole,
      isPinned: json['is_pinned']?.toString() == 'true' ||
          json['is_pinned'] == 1 ||
          json['is_pinned'] == true,
      isLiked: json['is_liked']?.toString() == 'true' ||
          json['is_liked'] == 1 ||
          json['is_liked'] == true ||
          json['liked_by_me']?.toString() == 'true' ||
          json['liked_by_me'] == 1 ||
          json['liked_by_me'] == true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'liked_by_user_ids': likedByUserIds,
      'tags': tags,
      'is_pinned': isPinned,
      'is_liked': isLiked,
      'user_role': userRole?.name,
    };
  }

  // CopyWith method
  PostModel copyWith({
    int? id,
    int? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    String? imageUrl,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<int>? likedByUserIds,
    List<String>? tags,
    bool? isPinned,
    bool? isLiked,
    UserRole? userRole,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isLiked: isLiked ?? this.isLiked,
      userRole: userRole ?? this.userRole,
    );
  }

  // Helper methods
  bool isLikedBy(int userId) {
    if (likedByUserIds.isNotEmpty) {
      return likedByUserIds.contains(userId);
    }
    return isLiked;
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  bool get isPublished => status.isPublished;
  bool get isDraft => status.isDraft;

  // Engagement rate (for analytics)
  double get engagementRate {
    if (likesCount + commentsCount + sharesCount == 0) return 0.0;
    return (likesCount + commentsCount * 2 + sharesCount * 3) / 100.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostModel(id: $id, userId: $userId, content: ${content.length} chars, likes: $likesCount)';
  }
}
