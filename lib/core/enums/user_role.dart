enum UserRole {
  parent,
  doctor;

  String get displayName {
    switch (this) {
      case UserRole.parent:
        return 'ولي أمر';
      case UserRole.doctor:
        return 'طبيب';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.doctor:
        return 'Doctor';
    }
  }

  bool get isDoctor => this == UserRole.doctor;
  bool get isParent => this == UserRole.parent;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
          (role) => role.name == value.toLowerCase(),
      orElse: () => UserRole.parent,
    );
  }
}