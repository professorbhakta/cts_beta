enum ApiFailureType {
  network,
  unauthorized,
  invalidRequest,
  server,
  timeout,
  unexpected,
  parsing,
  cancelled, // Added this missing type
}

class ApiFailure {
  const ApiFailure({required this.type, this.message, this.statusCode});

  final ApiFailureType type;
  final String? message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiFailure(type: $type, statusCode: $statusCode, message: $message)';
}

class ApiResult<T> {
  const ApiResult._({this.data, this.failure});

  final T? data;
  final ApiFailure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  factory ApiResult.success(T data) =>
      ApiResult<T>._(data: data, failure: null);

  factory ApiResult.failure(ApiFailure failure) =>
      ApiResult<T>._(data: null, failure: failure);
}
