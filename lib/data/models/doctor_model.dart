import '../../core/enums/user_role.dart';
import 'user_model.dart';

class DoctorModel extends UserModel {
  final String specialization;
  final String licenseNumber;
  final int yearsOfExperience;
  final String? clinicAddress;
  final String? clinicPhone;
  final List<String> patientIds;
  final String? generatedCode;
  final DateTime? codeExpiresAt;
  final double rating;
  final int reviewsCount;

  const DoctorModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    super.bio,
    super.phone,
    super.createdAt,
    super.updatedAt,
    super.followersCount,
    super.followingCount,
    super.isVerified,
    super.isActive,
    required this.specialization,
    required this.licenseNumber,
    this.yearsOfExperience = 0,
    this.clinicAddress,
    this.clinicPhone,
    this.patientIds = const [],
    this.generatedCode,
    this.codeExpiresAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
  }) : super(role: UserRole.doctor);

  // Factory constructor from JSON
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl:
          json['avatar_url']?.toString() ?? json['profile_image']?.toString(),
      bio: json['bio']?.toString(),
      phone: json['phone']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      followersCount:
          int.tryParse(json['followers_count']?.toString() ?? '') ?? 0,
      followingCount:
          int.tryParse(json['following_count']?.toString() ?? '') ?? 0,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == null,
      specialization: json['specialization']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      yearsOfExperience:
          int.tryParse(json['years_of_experience']?.toString() ?? '') ?? 0,
      clinicAddress: json['clinic_address']?.toString(),
      clinicPhone: json['clinic_phone']?.toString(),
      patientIds: (json['patient_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      generatedCode: json['generated_code']?.toString(),
      codeExpiresAt: json['code_expires_at'] != null
          ? DateTime.tryParse(json['code_expires_at'].toString())
          : null,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
    );
  }

  // Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'specialization': specialization,
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'clinic_address': clinicAddress,
      'clinic_phone': clinicPhone,
      'patient_ids': patientIds,
      'generated_code': generatedCode,
      'code_expires_at': codeExpiresAt?.toIso8601String(),
      'rating': rating,
      'reviews_count': reviewsCount,
    });
    return json;
  }

  // CopyWith method
  @override
  DoctorModel copyWith({
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
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    String? clinicAddress,
    String? clinicPhone,
    List<String>? patientIds,
    String? generatedCode,
    DateTime? codeExpiresAt,
    double? rating,
    int? reviewsCount,
  }) {
    return DoctorModel(
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
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      patientIds: patientIds ?? this.patientIds,
      generatedCode: generatedCode ?? this.generatedCode,
      codeExpiresAt: codeExpiresAt ?? this.codeExpiresAt,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  // Helper getters
  int get patientsCount => patientIds.length;
  bool get hasActiveCode =>
      generatedCode != null &&
      codeExpiresAt != null &&
      codeExpiresAt!.isAfter(DateTime.now());

  String get experienceText {
    if (yearsOfExperience == 0) return 'أقل من سنة';
    if (yearsOfExperience == 1) return 'سنة واحدة';
    if (yearsOfExperience == 2) return 'سنتان';
    if (yearsOfExperience <= 10) return '$yearsOfExperience سنوات';
    return '$yearsOfExperience سنة';
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialization: $specialization, patients: $patientsCount)';
  }
}
