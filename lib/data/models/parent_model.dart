import '../../core/enums/user_role.dart';
import 'user_model.dart';

class ParentModel extends UserModel {
  final String childName;
  final int childAge;
  final String? childGender;
  final String? childMedicalCondition;
  final List<String> connectedDoctorIds;
  final String? emergencyContact;
  final String? address;
  final List<String> allergies;
  final List<String> medications;
  final String? childPhotoUrl; // Added

  const ParentModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    super.bio,
    super.phone,
    required super.createdAt,
    required super.updatedAt,
    super.followersCount,
    super.followingCount,
    super.isVerified,
    super.isActive,
    required this.childName,
    required this.childAge,
    this.childGender,
    this.childMedicalCondition,
    this.connectedDoctorIds = const [],
    this.emergencyContact,
    this.address,
    this.allergies = const [],
    this.medications = const [],
    this.childPhotoUrl,
  }) : super(role: UserRole.parent);

  // Factory constructor from JSON
  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      childName: json['child_name'] as String,
      childAge: json['child_age'] as int,
      childGender: json['child_gender'] as String?,
      childMedicalCondition: json['child_medical_condition'] as String?,
      connectedDoctorIds: (json['connected_doctor_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emergencyContact: json['emergency_contact'] as String?,
      address: json['address'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      childPhotoUrl: json['child_photo_url'] as String?,
    );
  }

  // Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'child_name': childName,
      'child_age': childAge,
      'child_gender': childGender,
      'child_medical_condition': childMedicalCondition,
      'connected_doctor_ids': connectedDoctorIds,
      'emergency_contact': emergencyContact,
      'address': address,
      'allergies': allergies,
      'medications': medications,
      'child_photo_url': childPhotoUrl,
    });
    return json;
  }

  // CopyWith method
  @override
  ParentModel copyWith({
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
    String? childName,
    int? childAge,
    String? childGender,
    String? childMedicalCondition,
    List<String>? connectedDoctorIds,
    String? emergencyContact,
    String? address,
    List<String>? allergies,
    List<String>? medications,
    String? childPhotoUrl,
  }) {
    return ParentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      childGender: childGender ?? this.childGender,
      childMedicalCondition:
          childMedicalCondition ?? this.childMedicalCondition,
      connectedDoctorIds: connectedDoctorIds ?? this.connectedDoctorIds,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      childPhotoUrl: childPhotoUrl ?? this.childPhotoUrl,
    );
  }

  // Helper getters
  int get connectedDoctorsCount => connectedDoctorIds.length;
  bool get hasConnectedDoctors => connectedDoctorIds.isNotEmpty;
  bool get hasAllergies => allergies.isNotEmpty;
  bool get hasMedications => medications.isNotEmpty;
  bool get hasMedicalCondition =>
      childMedicalCondition != null && childMedicalCondition!.isNotEmpty;

  String get childAgeText {
    if (childAge == 0) return 'أقل من سنة';
    if (childAge == 1) return 'سنة واحدة';
    if (childAge == 2) return 'سنتان';
    if (childAge <= 10) return '$childAge سنوات';
    return '$childAge سنة';
  }

  @override
  String toString() {
    return 'ParentModel(id: $id, name: $name, child: $childName, age: $childAge)';
  }
}
