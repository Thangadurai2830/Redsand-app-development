import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/auth/data/models/auth_token_model.dart';
import 'package:flutter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_app/features/auth/domain/entities/user_role.dart';

import '../../../../../helpers/test_fakes.dart';

void main() {
  late FakeAuthLocalDataSource localDataSource;
  late FakeAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeAuthLocalDataSource();
    remoteDataSource = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  test('login stores token locally and returns it', () async {
    final token = AuthTokenModel(
      accessToken: 'access',
      refreshToken: 'refresh',
      role: UserRole.user,
      expiresAt: DateTime.parse('2030-01-01T00:00:00.000Z'),
    );
    remoteDataSource.loginToken = token;

    final result = await repository.login('user@example.com', 'secret');

    final returnedToken = result.fold(
      (failure) => fail('Expected successful login, got $failure'),
      (value) => value,
    );
    expect(returnedToken, token);
    expect(localDataSource.token, token);
  });

  test('getStoredToken returns a cache failure when local read fails', () async {
    localDataSource.throwOnGet = true;

    final result = await repository.getStoredToken();

    result.fold(
      (failure) => expect(failure, isA<CacheFailure>()),
      (_) => fail('Expected cache failure'),
    );
  });

  test('clearToken deletes token locally', () async {
    localDataSource.token = AuthTokenModel(
      accessToken: 'access',
      refreshToken: 'refresh',
      role: UserRole.user,
      expiresAt: DateTime.parse('2030-01-01T00:00:00.000Z'),
    );

    final result = await repository.clearToken();

    result.fold(
      (failure) => fail('Expected successful clearToken, got $failure'),
      (_) {},
    );
    expect(localDataSource.token, isNull);
  });
}
