import '../../core/enums/user_role.dart';

class UserModel {
  final int id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final int? doctorNumber;
  final String? clinicLocation;
  final String? profileImage;
  final DateTime? createdAt;
  final String? avatarUrl;
  final String? bio;
  final DateTime? updatedAt;
  final int? followersCount;
  final int? followingCount;
  final bool? isVerified;
  final bool? isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.doctorNumber,
    this.clinicLocation,
    this.profileImage,
    this.createdAt,
    this.avatarUrl,
    this.bio,
    this.updatedAt,
    this.followersCount,
    this.followingCount,
    this.isVerified,
    this.isActive,
  });

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'patient'),
      phone: json['phone']?.toString(),
      doctorNumber: json['doctor_number'] is int
          ? json['doctor_number']
          : int.tryParse(json['doctor_number']?.toString() ?? ''),
      clinicLocation: json['clinic_location']?.toString(),
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      avatarUrl:
          json['avatar_url']?.toString() ?? json['profile_image']?.toString(),
      bio: json['bio']?.toString(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      followersCount: int.tryParse(json['followers_count']?.toString() ?? ''),
      followingCount: int.tryParse(json['following_count']?.toString() ?? ''),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'doctor_number': doctorNumber,
      'clinic_location': clinicLocation,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': updatedAt?.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_verified': isVerified,
      'is_active': isActive,
    };
  }

  // CopyWith method
  UserModel copyWith({
    int? id,
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
