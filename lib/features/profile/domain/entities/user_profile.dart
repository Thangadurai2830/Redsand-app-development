import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;
  final String kycStatus;
  final bool aadhaarVerified;
  final bool panVerified;
  final String verificationMessage;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
    required this.kycStatus,
    required this.aadhaarVerified,
    required this.panVerified,
    required this.verificationMessage,
  });

  bool get isKycComplete => aadhaarVerified && panVerified;

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        address,
        avatarUrl,
        kycStatus,
        aadhaarVerified,
        panVerified,
        verificationMessage,
      ];
}
