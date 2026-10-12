import 'package:dio/dio.dart';
import 'app_failure.dart';

class FailureMapper {
  FailureMapper._();

  static AppFailure fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          final message =
              e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Invalid credentials or session expired.';
          return UnauthorizedFailure(message ?? 'Invalid credentials.');
        } else if (statusCode == 404) {
          return const NotFoundFailure('The requested resource was not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(
            'Server error ($statusCode). Please try again.',
            statusCode,
          );
        } else {
          final message =
              e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Request failed with status $statusCode.';
          return ServerFailure(message ?? 'Request failed', statusCode);
        }
      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Security verification failed.');
      case DioExceptionType.unknown:
      default:
        return NetworkFailure(e.message ?? 'Network connection error.');
    }
  }

  static AppFailure fromException(Object e) {
    if (e is AppFailure) return e;
    if (e is DioException) return fromDioException(e);
    if (e is FormatException || e is TypeError) {
      return const ParsingFailure('Data processing error.');
    }
    return UnknownFailure(e.toString());
  }
}
