import 'package:dartz/dartz.dart';
import 'package:socket_test/exceptions/api_exception.dart';
import 'package:socket_test/models/user.dart';

abstract class AuthRepository {
  User? get user;

  Future<Either<ApiException, User?>> getCurrentUserInfo();

  Future<Either<ApiException, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<ApiException, void>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> autoLogin();

  Stream<User?> onAuthStateChanged();
}
