import 'package:equatable/equatable.dart';

class ProfileUpdateRequest extends Equatable {
  final String fullName;
  final String phone;
  final String address;

  const ProfileUpdateRequest({
    required this.fullName,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'address': address,
      };

  @override
  List<Object?> get props => [fullName, phone, address];
}
