import 'package:cts/api/api_result.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ApiExceptionHandler {
  static ApiFailure handle(dynamic error) {
    if (error is DioException) {
      return _mapDioException(error);
    } else if (error is SocketException) {
      return ApiFailure(
        type: ApiFailureType.network,
        message: 'No internet connection. Please check your network settings and try again.',
      );
    } else if (error is FormatException) {
      return ApiFailure(
        type: ApiFailureType.parsing,
        message: 'Data format error. Please try refreshing the page.',
      );
    }
    // Fallback for any other type of exception
    return ApiFailure(
      type: ApiFailureType.unexpected,
      message: 'Something went wrong. Please try again later.',
    );
  }

  static ApiFailure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiFailure(
          type: ApiFailureType.timeout,
          message: 'Request timed out. Please check your connection and try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final userMessage = _getUserFriendlyMessage(statusCode, error.response);
        return ApiFailure(
          type: _failureTypeFromStatus(statusCode),
          statusCode: statusCode,
          message: userMessage,
        );
      case DioExceptionType.connectionError:
        return ApiFailure(
          type: ApiFailureType.network,
          message: 'Unable to connect to the server. Please check your internet connection.',
        );
      case DioExceptionType.cancel:
        return ApiFailure(
          type: ApiFailureType.cancelled,
          message: 'Request was cancelled.',
        );
      case DioExceptionType.unknown:
        return ApiFailure(
          type: ApiFailureType.unexpected,
          message: 'Something went wrong. Please try again later.',
        );
      case DioExceptionType.badCertificate:
        return ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: 'Security certificate error. Please contact support.',
        );
    }
  }

  /// Get user-friendly error messages based on status code
  static String _getUserFriendlyMessage(int? statusCode, Response? response) {
    // First try to get message from response
    final responseMessage = _messageFromResponse(response);
    
    // If we have a status code, provide context-specific messages
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return responseMessage.isNotEmpty && responseMessage != 'An unknown error occurred.'
              ? responseMessage
              : 'Invalid request. Please check your input and try again.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 403:
          return 'You don\'t have permission to perform this action.';
        case 404:
          return 'The requested resource was not found.';
        case 409:
          return 'This action conflicts with existing data. Please check and try again.';
        case 422:
          return responseMessage.isNotEmpty && responseMessage != 'An unknown error occurred.'
              ? responseMessage
              : 'Validation error. Please check your input.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
          return 'Server error. Our team has been notified. Please try again later.';
        case 502:
        case 503:
        case 504:
          return 'Service temporarily unavailable. Please try again in a few moments.';
        default:
          if (statusCode >= 400 && statusCode < 500) {
            return responseMessage.isNotEmpty && responseMessage != 'An unknown error occurred.'
                ? responseMessage
                : 'Request error. Please check your input and try again.';
          } else if (statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
      }
    }
    
    // Fallback to response message or generic message
    return responseMessage.isNotEmpty && responseMessage != 'An unknown error occurred.'
        ? responseMessage
        : 'An error occurred. Please try again.';
  }

  static ApiFailureType _failureTypeFromStatus(int? statusCode) {
    if (statusCode == null) return ApiFailureType.unexpected;
    if (statusCode == 401 || statusCode == 403) {
      return ApiFailureType.unauthorized;
    }
    if (statusCode >= 400 && statusCode < 500) {
      return ApiFailureType.invalidRequest;
    }
    if (statusCode >= 500) {
      return ApiFailureType.server;
    }
    return ApiFailureType.unexpected;
  }

  static String _messageFromResponse(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      // Check for common error keys first.
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('msg')) return data['msg'].toString();

      // If no common key is found, convert the whole map to a string for debugging.
      return data.toString();
    }
    // Fallback for non-map data or null response.
    return response?.statusMessage ?? 'An unknown error occurred.';
  }
}

