import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': username.trim(), 'password': password.trim()},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw FailureMapper.fromException('Failed to authenticate');
      }
    } on DioException catch (e) {
      throw FailureMapper.fromDioException(e);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }
}
