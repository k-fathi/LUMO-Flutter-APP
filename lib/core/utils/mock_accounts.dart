/// Fixed Mock Accounts for Testing
/// 
/// Use these hardcoded accounts to test the app without backend
/// Email credentials that trigger these accounts:
/// 
/// Doctor Account:
///   Email: doctor@test.com
///   Password: doctor123 (any password works)
/// 
/// User/Parent Account:
///   Email: user@test.com
///   Password: user123 (any password works)

import '../../data/models/doctor_model.dart';
import '../../data/models/parent_model.dart';

class MockAccounts {
  /// Fixed Doctor Account
  static Map<String, dynamic> getDoctorAccount() {
    final now = DateTime.now();
    return {
      'id': 'mock-doctor-001',
      'email': 'doctor@test.com',
      'name': 'د. أحمد محمد',
      'role': 'doctor',
      'avatar_url': null,
      'bio': 'طبيب أطفال متخصص | Pediatrician',
      'phone': '+201001234567',
      'created_at': now.subtract(Duration(days: 365)).toIso8601String(),
      'updated_at': now.toIso8601String(),
      'followers_count': 156,
      'following_count': 42,
      'is_verified': true,
      'is_active': true,
      // Doctor-specific fields
      'specialization': 'أمراض الأطفال | Pediatrics',
      'license_number': 'LIC-2019-12345',
      'years_of_experience': 8,
      'clinic_address': 'القاهرة، مصر | Cairo, Egypt',
      'clinic_phone': '+201012345678',
      'patient_ids': [],
      'generated_code': 'DOC-ADMIN-001',
      'code_expires_at': null,
      'rating': 4.8,
      'reviews_count': 47,
    };
  }

  /// Fixed Parent/User Account
  static Map<String, dynamic> getParentAccount() {
    final now = DateTime.now();
    return {
      'id': 'mock-parent-001',
      'email': 'user@test.com',
      'name': 'فاطمة علي',
      'role': 'parent',
      'avatar_url': null,
      'bio': 'والدة حنون | Caring Mother',
      'phone': '+201009876543',
      'created_at': now.subtract(Duration(days: 180)).toIso8601String(),
      'updated_at': now.toIso8601String(),
      'followers_count': 28,
      'following_count': 15,
      'is_verified': true,
      'is_active': true,
      // Parent-specific fields
      'child_name': 'محمد',
      'child_age': 6,
      'child_gender': 'male',
      'child_medical_condition': null,
      'connected_doctor_ids': [],
      'emergency_contact': '+201101234567',
      'address': 'الجيزة، مصر | Giza, Egypt',
      'allergies': ['Peanuts', 'Shellfish'],
      'medications': [],
      'child_photo_url': null,
    };
  }

  /// Get DoctorModel for fixed doctor account
  static DoctorModel getDoctorModel() {
    return DoctorModel.fromJson(getDoctorAccount());
  }

  /// Get ParentModel for fixed user account
  static ParentModel getParentModel() {
    return ParentModel.fromJson(getParentAccount());
  }

  /// Check if credentials match fixed accounts
  static String? validateFixedAccount(String email, String password) {
    final lowerEmail = email.toLowerCase().trim();
    
    if (lowerEmail == 'doctor@test.com') {
      return 'doctor';
    } else if (lowerEmail == 'user@test.com') {
      return 'parent';
    }
    
    return null;
  }
}
