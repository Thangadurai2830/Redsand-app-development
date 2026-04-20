import '../../domain/entities/register_user.dart';

class RegisterRequestModel {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory RegisterRequestModel.fromEntity(RegisterUser entity) {
    return RegisterRequestModel(
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      password: entity.password,
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      };
}
