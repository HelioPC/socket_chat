import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_test/constants/storage_keys.dart';
import 'package:socket_test/constants/urls.dart';
import 'package:socket_test/exceptions/api_exception.dart';
import 'package:socket_test/models/user.dart';
import 'package:socket_test/utils/rest_client.dart';
import 'package:socket_test/utils/storage.dart';

import 'auth_repository.dart';

final authRepositoryProvider = Provider.family<AuthRepository, List<Storage>?>(
      (ref, storages) {
    if (storages != null) {
      assert(storages.length == 2);
    }

    if (storages != null) {
      return AuthRepositoryImpl(
        client: ref.read(restClientProvider(storages[0])),
        secureStorage: storages[0],
        normalStorage: storages[1],
      );
    }

    final secureStorage = ref.read(storageProvider);
    final normalStorage = ref.read(storageProvider);

    return AuthRepositoryImpl(
      client: ref.read(restClientProvider(null)),
      secureStorage: secureStorage,
      normalStorage: normalStorage,
    );
  },
);

class AuthRepositoryImpl implements AuthRepository {
  final RestClient client;
  final Storage secureStorage;
  final Storage normalStorage;

  AuthRepositoryImpl({
    required this.client,
    required this.secureStorage,
    required this.normalStorage,
  }) {
    _userStream.stream.listen((event) {
      _user = event;
    });
    _userStream.sink.add(null);
  }

  User? _user;

  @override
  User? get user => _user;

  final _userStream = StreamController<User?>.broadcast(sync: true);

  @override
  Future<void> autoLogin() async {
    final accessToken = await secureStorage.read(StorageKeys.accessToken);
    final refreshToken = await secureStorage.read(StorageKeys.refreshToken);
    final expiresIn = await normalStorage.read(StorageKeys.expiresIn);

    if (accessToken != null && refreshToken != null && expiresIn != null) {
      final now = DateTime.now();
      final expires = DateTime.parse(expiresIn);

      if (now.isBefore(expires)) {
        final userFromStorage = await getCurrentUserInfoFromStorage();

        if (userFromStorage != null) {
          _userStream.sink.add(userFromStorage);
        } else {
          getCurrentUserInfo();
        }
      } else {
        final refreshTokenExpiresIn =
        await normalStorage.read(StorageKeys.refreshTokenExpiresIn);

        if (refreshTokenExpiresIn != null) {
          final refreshTokenExpires = DateTime.parse(refreshTokenExpiresIn);

          if (now.isBefore(refreshTokenExpires)) {
            final response = await client.unAuth.postRequest(
              path: UrlsConstants.refreshTokenUrl,
              body: {
                'refresh_token': refreshToken,
              },
            );

            if (response.statusCode == 200) {
              final body = jsonDecode(response.body);

              if (body['access_token'] != null &&
                  body['refresh_token'] != null) {
                await Future.wait([
                  secureStorage.store(
                    StorageKeys.accessToken,
                    body['access_token'] ?? '',
                  ),
                  secureStorage.store(
                    StorageKeys.refreshToken,
                    body['refresh_token'] ?? '',
                  ),
                  normalStorage.store(
                    StorageKeys.expiresIn,
                    DateTime.now()
                        .add(const Duration(minutes: 990))
                        .toIso8601String(),
                  ),
                  normalStorage.store(
                    StorageKeys.refreshTokenExpiresIn,
                    DateTime.now()
                        .add(const Duration(minutes: 4990))
                        .toIso8601String(),
                  ),
                ]);

                getCurrentUserInfo();
              }
            }
          }
        }
      }
    }
  }

  Future<User?> getCurrentUserInfoFromStorage() async {
    final userInfo = await normalStorage.read(StorageKeys.userInfo);

    if (userInfo != null) {
      return User.fromJson(userInfo);
    }

    return null;
  }

  @override
  Future<Either<ApiException, User?>> getCurrentUserInfo() async {
    try {
      final response =
      await client.auth.getRequest(path: UrlsConstants.userInfoUrl);

      switch (response.statusCode) {
        case 400:
          return Left(ApiException(code: 400));
        case 401:
          return Left(ApiException(code: 401));
        case 403:
          return Left(ApiException(code: 403));
        case 200:
          late User? apiUser;

          try {
            apiUser = User.fromJson(response.body);
          } catch (e) {
            return Left(ApiException(code: 999, message: e.toString()));
          }

          await normalStorage.store(
            StorageKeys.userInfo,
            apiUser.toJson(),
          );

          _userStream.sink.add(apiUser);

          return Right(apiUser);
        default:
          return Left(ApiException(code: response.statusCode));
      }
    } catch (e) {
      return Left(ApiException(code: 999, message: e.toString()));
    }
  }

  @override
  Stream<User?> onAuthStateChanged() {
    return _userStream.stream;
  }

  @override
  Future<Either<ApiException, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.unAuth.postRequest(
        path: UrlsConstants.loginUrl,
        body: {
          'email': email,
          'password': password,
        },
      );

      switch (response.statusCode) {
        case 400:
          return Left(ApiException(code: 400));
        case 401:
          return Left(ApiException(code: 401));
        case 200:
          final body = jsonDecode(response.body);

          if (body['access_token'] != null && body['refresh_token'] != null) {
            await Future.wait([
              secureStorage.store(
                StorageKeys.accessToken,
                body['access_token'] ?? '',
              ),
              secureStorage.store(
                StorageKeys.refreshToken,
                body['refresh_token'] ?? '',
              ),
              normalStorage.store(
                StorageKeys.expiresIn,
                DateTime.now()
                    .add(const Duration(minutes: 990))
                    .toIso8601String(),
              ),
              normalStorage.store(
                StorageKeys.refreshTokenExpiresIn,
                DateTime.now()
                    .add(const Duration(minutes: 4990))
                    .toIso8601String(),
              ),
            ]);

            getCurrentUserInfo();
          } else {
            return Left(
              ApiException(
                code: 999,
                message: 'Authentification failed',
              ),
            );
          }

          return const Right(null);
        default:
          return Left(ApiException(code: response.statusCode));
      }
    } catch (e) {
      return Left(ApiException(code: 999, message: e.toString()));
    }
  }

  @override
  Future<void> signOut() {
    return Future.wait([
      secureStorage.delete(StorageKeys.accessToken),
      secureStorage.delete(StorageKeys.refreshToken),
      normalStorage.delete(StorageKeys.expiresIn),
      normalStorage.delete(StorageKeys.refreshTokenExpiresIn),
      normalStorage.delete(StorageKeys.userInfo),
    ]).then((value) {
      _userStream.sink.add(null);
    });
  }

  @override
  Future<Either<ApiException, void>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.unAuth.postRequest(
        path: UrlsConstants.registerUrl,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      switch (response.statusCode) {
        case 400:
          return Left(ApiException(code: 400));
        case 201:
          final body = jsonDecode(response.body);

          if (body['access_token'] != null && body['refresh_token'] != null) {
            await Future.wait([
              secureStorage.store(
                StorageKeys.accessToken,
                body['access_token'] ?? '',
              ),
              secureStorage.store(
                StorageKeys.refreshToken,
                body['refresh_token'] ?? '',
              ),
              normalStorage.store(
                StorageKeys.expiresIn,
                DateTime.now()
                    .add(const Duration(minutes: 990))
                    .toIso8601String(),
              ),
              normalStorage.store(
                StorageKeys.refreshTokenExpiresIn,
                DateTime.now()
                    .add(const Duration(minutes: 4990))
                    .toIso8601String(),
              ),
            ]);

            getCurrentUserInfo();
          } else {
            return Left(
              ApiException(
                code: 999,
                message: 'User created but authentification failed',
              ),
            );
          }

          return const Right(null);
        default:
          return Left(ApiException(code: response.statusCode));
      }
    } catch (e) {
      return Left(ApiException(code: 999, message: e.toString()));
    }
  }
}
