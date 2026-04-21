import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.fullName,
    required super.email,
    required super.phone,
    required super.address,
    required super.avatarUrl,
    required super.kycStatus,
    required super.aadhaarVerified,
    required super.panVerified,
    required super.verificationMessage,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      fullName: _stringValue(profile, const ['full_name', 'name', 'fullName'], 'Guest User'),
      email: _stringValue(profile, const ['email'], ''),
      phone: _stringValue(profile, const ['phone', 'mobile', 'phone_number'], ''),
      address: _stringValue(profile, const ['address', 'location', 'address_line'], ''),
      avatarUrl: _stringValue(profile, const ['avatar_url', 'avatar', 'photo_url'], ''),
      kycStatus: _stringValue(profile, const ['kyc_status', 'status'], 'pending'),
      aadhaarVerified: _boolValue(profile, const ['aadhaar_verified', 'aadhaarVerified', 'is_aadhaar_verified']),
      panVerified: _boolValue(profile, const ['pan_verified', 'panVerified', 'is_pan_verified']),
      verificationMessage: _stringValue(
        profile,
        const ['verification_message', 'message', 'detail'],
        'Profile loaded successfully',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
      };

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  static bool _boolValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
          return true;
        }
        if (normalized == 'false' || normalized == 'no' || normalized == '0') {
          return false;
        }
      }
    }
    return false;
  }
}
