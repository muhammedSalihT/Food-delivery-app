import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient(
    SecureStorageService secureStorage, {
    void Function()? onUnauthorized,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: ApiConstants.baseUrl,
           connectTimeout: ApiConstants.connectTimeout,
           receiveTimeout: ApiConstants.receiveTimeout,
           sendTimeout: ApiConstants.sendTimeout,
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.add(
      AuthInterceptor(secureStorage, onUnauthorized: onUnauthorized),
    );
  }

  Dio get dio => _dio;
}
