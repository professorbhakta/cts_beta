import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponseContract.parse', () {
    test('200 + status:error is business failure', () {
      final contract = ApiResponseContract.parse({
        'status': 'error',
        'message': 'not eligible',
      });

      expect(contract.isFailure, isTrue);
      expect(contract.message, 'not eligible');
      expect(contract.status, 'error');
    });

    test('200 + status:added maps success message', () {
      final contract = ApiResponseContract.parse(
        {'status': 'added'},
        statusMessages: ApiResponseContract.returnBatchActionMessages,
        successMessage: 'fallback',
      );

      expect(contract.isSuccess, isTrue);
      expect(contract.message, 'Commuter confirmed for return');
    });

    test('missing fields falls back to successMessage', () {
      final contract = ApiResponseContract.parse(
        {},
        successMessage: 'Done',
      );

      expect(contract.isSuccess, isTrue);
      expect(contract.message, 'Done');
    });

    test('unknown status fails closed with fallback message', () {
      final contract = ApiResponseContract.parse(
        {'status': 'pending_review'},
        failureMessage: 'Request rejected',
      );

      expect(contract.isFailure, isTrue);
      expect(contract.message, 'Request rejected');
    });

    test('unknown code with message uses message', () {
      final contract = ApiResponseContract.parse({
        'status': 'weird',
        'code': 'not_eligible',
        'message': 'Student is not eligible today',
      });

      expect(contract.isFailure, isTrue);
      expect(contract.message, 'Student is not eligible today');
      expect(contract.code, 'not_eligible');
    });

    test('error key without ok status is business failure', () {
      final contract = ApiResponseContract.parse({
        'error': 'overflow_full',
        'message': 'Cab is at capacity for this trip.',
      });

      expect(contract.isFailure, isTrue);
      expect(contract.message, 'Cab is at capacity for this trip.');
    });

    test('status:ok with isComing bool stays success', () {
      final contract = ApiResponseContract.parse({
        'status': 'ok',
        'isComing': true,
      });

      expect(contract.isSuccess, isTrue);
    });

    test('field validation list is business failure', () {
      final contract = ApiResponseContract.parse({
        'isComing': ['This field is required.'],
      });

      expect(contract.isFailure, isTrue);
    });

    test('reads message from msg alias', () {
      final contract = ApiResponseContract.parse({
        'status': 'error',
        'msg': 'Server-side validation failed',
      });

      expect(contract.isFailure, isTrue);
      expect(contract.message, 'Server-side validation failed');
    });

    test('reads status from result alias', () {
      final result = ApiResponseContract.toStringResult(
        {'result': 'added'},
        successMessage: 'fallback',
        statusMessages: ApiResponseContract.returnBatchActionMessages,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, 'Commuter confirmed for return');
    });
  });

  group('ApiResponseContract.toStringResult', () {
    test('200+status:error returns ApiResult.failure', () {
      final result = ApiResponseContract.toStringResult(
        {'status': 'error', 'message': 'already_allocated'},
        successMessage: 'Commuter confirmed',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, ApiFailureType.invalidRequest);
      expect(result.failure?.message, 'already_allocated');
    });

    test('success path returns mapped string', () {
      final result = ApiResponseContract.toStringResult(
        {'status': 'removed'},
        successMessage: 'Removed',
        statusMessages: ApiResponseContract.returnBatchActionMessages,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, 'Commuter removed from return list');
    });
  });

  group('ApiResponseContract.toVoidResult', () {
    test('status:error returns failure for end trip', () {
      final result = ApiResponseContract.toVoidResult(
        {'status': 'error', 'message': 'Trip already ended'},
        failureMessage: 'Could not end return trip',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.message, 'Trip already ended');
    });
  });

  group('ApiExceptionHandler HTTP errors', () {
    test('4xx maps to invalidRequest with body message', () {
      final failure = ApiExceptionHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 409,
            data: {'status': 'error', 'message': 'already_allocated'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure.type, ApiFailureType.invalidRequest);
      expect(failure.statusCode, 409);
      expect(failure.message, 'already_allocated');
    });

    test('5xx maps to server failure', () {
      final failure = ApiExceptionHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            data: {'message': 'Internal error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure.type, ApiFailureType.server);
      expect(failure.statusCode, 500);
    });

    test('missing body fields uses status-specific fallback', () {
      final failure = ApiExceptionHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure.type, ApiFailureType.invalidRequest);
      expect(
        failure.message,
        'Invalid request. Please check your input and try again.',
      );
    });
  });
}
