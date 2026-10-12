/// Typed failure hierarchy for clean and structured error handling across the app.
sealed class AppFailure {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Unable to connect. Please check your internet connection.',
  ]);
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([
    super.message =
        'Session expired or invalid credentials. Please log in again.',
    super.statusCode = 401,
  ]);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Server encountered an issue. Please try again later.',
    super.statusCode,
  ]);
}

class ParsingFailure extends AppFailure {
  const ParsingFailure([
    super.message = 'Failed to process data. Please try again.',
  ]);
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Local storage error occurred.']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([
    super.message = 'Requested recipe or item was not found.',
    super.statusCode = 404,
  ]);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
