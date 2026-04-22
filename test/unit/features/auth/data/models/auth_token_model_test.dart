import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/auth/data/models/auth_token_model.dart';
import 'package:flutter_app/features/auth/domain/entities/auth_token.dart';
import 'package:flutter_app/features/auth/domain/entities/user_role.dart';

void main() {
  test('parses and serializes auth token JSON', () {
    final json = {
      'access_token': 'access-1',
      'refresh_token': 'refresh-1',
      'role': 'owner',
      'expires_at': '2030-01-01T00:00:00.000Z',
    };

    final model = AuthTokenModel.fromJson(json);

    expect(model.accessToken, 'access-1');
    expect(model.refreshToken, 'refresh-1');
    expect(model.role, UserRole.owner);
    expect(model.expiresAt, DateTime.parse('2030-01-01T00:00:00.000Z'));
    expect(model.toJson(), json);
  });

  test('creates a model from an entity', () {
    final token = AuthToken(
      accessToken: 'token',
      refreshToken: 'refresh',
      role: UserRole.admin,
      expiresAt: DateTime.parse('2031-01-01T00:00:00.000Z'),
    );

    final model = AuthTokenModel.fromEntity(token);

    expect(model, isA<AuthTokenModel>());
    expect(model.accessToken, token.accessToken);
    expect(model.refreshToken, token.refreshToken);
    expect(model.role, token.role);
    expect(model.expiresAt, token.expiresAt);
  });
}

