class DoctorCodeModel {
  final String id;
  final String code;
  final String doctorId;
  final String doctorName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int usageCount;
  final int maxUsage;

  const DoctorCodeModel({
    required this.id,
    required this.code,
    required this.doctorId,
    required this.doctorName,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.usageCount = 0,
    this.maxUsage = 100,
  });

  // Factory constructor from JSON
  factory DoctorCodeModel.fromJson(Map<String, dynamic> json) {
    return DoctorCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      usageCount: json['usage_count'] as int? ?? 0,
      maxUsage: json['max_usage'] as int? ?? 100,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'usage_count': usageCount,
      'max_usage': maxUsage,
    };
  }

  // CopyWith method
  DoctorCodeModel copyWith({
    String? id,
    String? code,
    String? doctorId,
    String? doctorName,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    int? usageCount,
    int? maxUsage,
  }) {
    return DoctorCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
      maxUsage: maxUsage ?? this.maxUsage,
    );
  }

  // Helper methods
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => isActive && !isExpired && usageCount < maxUsage;
  bool get isMaxUsageReached => usageCount >= maxUsage;

  int get remainingUsage => maxUsage - usageCount;

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  int get daysUntilExpiry => timeUntilExpiry.inDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorCodeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DoctorCodeModel(code: $code, doctor: $doctorId, valid: $isValid)';
  }
}