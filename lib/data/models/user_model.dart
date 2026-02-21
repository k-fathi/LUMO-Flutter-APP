import '../../core/enums/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    this.isActive = true,
  });

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_verified': isVerified,
      'is_active': isActive,
    };
  }

  // CopyWith method
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? avatarUrl,
    String? bio,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: ${role.name})';
  }
}