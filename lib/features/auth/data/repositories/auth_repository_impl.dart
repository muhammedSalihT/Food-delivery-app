import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    await _localDataSource.saveUserSession(userModel);
    return userModel;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _localDataSource.getUserSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasValidToken();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
