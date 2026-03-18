import '../../core/enums/connection_status.dart';

class ConnectionRequestModel {
  final String id;
  final String parentId;
  final String parentName;
  final String? parentAvatarUrl;
  final String childName;
  final int childAge;
  final String doctorId;
  final String doctorName;
  final String? doctorAvatarUrl;
  final String doctorCode;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;
  final String? rejectionReason;

  const ConnectionRequestModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    this.parentAvatarUrl,
    required this.childName,
    required this.childAge,
    required this.doctorId,
    required this.doctorName,
    this.doctorAvatarUrl,
    required this.doctorCode,
    this.status = ConnectionStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
    this.rejectionReason,
  });

  // Factory constructor from JSON
  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle nested doctor/patient objects from backend
    final doctorData = json['doctor'] is Map<String, dynamic> ? json['doctor'] as Map<String, dynamic> : null;
    final patientData = json['patient'] is Map<String, dynamic> ? json['patient'] as Map<String, dynamic> : null;

    return ConnectionRequestModel(
      id: json['id']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? patientData?['id']?.toString() ?? json['patient_id']?.toString() ?? '',
      parentName: json['parent_name']?.toString() ?? patientData?['name']?.toString() ?? json['patient_name']?.toString() ?? '',
      parentAvatarUrl: json['parent_avatar_url']?.toString() ?? patientData?['profile_image']?.toString() ?? patientData?['avatar_url']?.toString(),
      childName: json['child_name']?.toString() ?? patientData?['child_name']?.toString() ?? '',
      childAge: json['child_age'] is int
          ? json['child_age']
          : int.tryParse(json['child_age']?.toString() ?? patientData?['child_age']?.toString() ?? '0') ?? 0,
      doctorId: json['doctor_id']?.toString() ?? doctorData?['id']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ?? doctorData?['name']?.toString() ?? '',
      doctorAvatarUrl: json['doctor_avatar_url']?.toString() ?? doctorData?['profile_image']?.toString() ?? doctorData?['avatar_url']?.toString(),
      doctorCode: json['doctor_code']?.toString() ?? doctorData?['doctor_number']?.toString() ?? '',
      status: ConnectionStatus.fromString(json['status']?.toString() ?? 'pending'),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'parent_name': parentName,
      'parent_avatar_url': parentAvatarUrl,
      'child_name': childName,
      'child_age': childAge,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_avatar_url': doctorAvatarUrl,
      'doctor_code': doctorCode,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  // CopyWith method
  ConnectionRequestModel copyWith({
    String? id,
    String? parentId,
    String? parentName,
    String? parentAvatarUrl,
    String? childName,
    int? childAge,
    String? doctorId,
    String? doctorName,
    String? doctorAvatarUrl,
    String? doctorCode,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
    String? rejectionReason,
  }) {
    return ConnectionRequestModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      parentAvatarUrl: parentAvatarUrl ?? this.parentAvatarUrl,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorAvatarUrl: doctorAvatarUrl ?? this.doctorAvatarUrl,
      doctorCode: doctorCode ?? this.doctorCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Helper methods
  bool get isPending => status.isPending;
  bool get isAccepted => status.isAccepted;
  bool get isRejected => status.isRejected;
  bool get hasResponse => respondedAt != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConnectionRequestModel(id: $id, parent: $parentId, doctor: $doctorId, status: ${status.name})';
  }
}