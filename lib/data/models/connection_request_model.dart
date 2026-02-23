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
    return ConnectionRequestModel(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      parentName: json['parent_name'] as String,
      parentAvatarUrl: json['parent_avatar_url'] as String?,
      childName: json['child_name'] as String,
      childAge: json['child_age'] as int,
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      doctorAvatarUrl: json['doctor_avatar_url'] as String?,
      doctorCode: json['doctor_code'] as String,
      status: ConnectionStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
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