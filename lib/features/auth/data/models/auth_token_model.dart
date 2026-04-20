import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user_role.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
    required super.role,
    required super.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.user,
      ),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'role': role.name,
        'expires_at': expiresAt.toIso8601String(),
      };

  factory AuthTokenModel.fromEntity(AuthToken token) => AuthTokenModel(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        role: token.role,
        expiresAt: token.expiresAt,
      );
}
