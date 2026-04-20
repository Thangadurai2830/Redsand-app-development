import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserRole role;
  final DateTime expiresAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, role, expiresAt];
}
