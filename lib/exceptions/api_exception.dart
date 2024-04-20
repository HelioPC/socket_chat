class ApiException implements Exception {
  static const Map<int, String> _defaultMessages = {
    400: 'Invalid data provided',
    401: 'Invalid credentials provided',
    403: 'You cannot access this resource',
    404: 'Resource not found',
    500: 'An unexpected error occurred',
  };

  final int code;
  final String? message;

  ApiException({
    required this.code,
    this.message,
  });

  factory ApiException.fromStatusCode(int code) {
    return ApiException(
      code: code,
      message: _defaultMessages[code],
    );
  }

  @override
  String toString() {
    if (message != null) {
      return message!;
    }

    return _defaultMessages[code] ?? 'An error occurred';
  }
}
