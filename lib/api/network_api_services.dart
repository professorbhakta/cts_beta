import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cts/api/api_list.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/api/logging_interceptor.dart';
import 'package:dio/dio.dart';

import 'package:cts/api/base_api_services.dart';

/// Dio client with JWT Bearer auth and single refresh-on-401 retry.
///
/// CSRF / session cookies are not used for Flutter JWT calls.
class NetworkApiServices extends BaseApiServices {
  NetworkApiServices({
    String? baseUrl,
    Future<void> Function()? onUnauthorized,
  }) : this._(baseUrl, onUnauthorized);

  NetworkApiServices._(String? baseUrl, this._onUnauthorized)
      : _sessionManager = SessionManager(),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConfig.instance.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: const {
              'Connection': 'Keep-Alive',
              'content-type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      const LoggingInterceptor(
        logRequestHeaders: true,
        logRequestBody: true,
        logResponseHeaders: false,
        logResponseBody: true,
        logErrors: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isAuthExemptPath(options.path)) {
            final access = await _sessionManager.getAccessToken();
            if (access != null && access.isNotEmpty) {
              options.headers[HttpHeaders.authorizationHeader] =
                  'Bearer $access';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final request = error.requestOptions;

          if (status != 401 ||
              _isAuthExemptPath(request.path) ||
              request.extra[_retriedExtraKey] == true) {
            return handler.next(error);
          }

          try {
            final refreshed = await _refreshAccessToken();
            if (!refreshed) {
              await _handleUnauthorized();
              return handler.next(error);
            }

            final access = await _sessionManager.getAccessToken();
            final opts = request.copyWith(
              headers: Map<String, dynamic>.from(request.headers)
                ..[HttpHeaders.authorizationHeader] = 'Bearer $access',
              extra: Map<String, dynamic>.from(request.extra)
                ..[_retriedExtraKey] = true,
            );
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          } catch (_) {
            await _handleUnauthorized();
            return handler.next(error);
          }
        },
      ),
    );
  }

  static const String _retriedExtraKey = 'jwt_retried';

  final Dio _dio;
  final SessionManager _sessionManager;
  final Future<void> Function()? _onUnauthorized;
  bool _clearingSession = false;

  Completer<bool>? _refreshCompleter;

  bool _isAuthExemptPath(String path) {
    final normalized = path.toLowerCase();
    return normalized.endsWith(ApiUrl.loginUrl) ||
        normalized.contains('/${ApiUrl.loginUrl}') ||
        normalized.endsWith(ApiUrl.refreshUrl) ||
        normalized.contains('/${ApiUrl.refreshUrl}');
  }

  /// One in-flight refresh shared by concurrent 401s.
  Future<bool> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refresh = await _sessionManager.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }

      // Bare Dio call — no interceptor — avoids refresh recursion.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          sendTimeout: _dio.options.sendTimeout,
          headers: const {
            'content-type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiUrl.refreshUrl,
        data: {'refresh': refresh},
      );

      final data = response.data;
      final access = data is Map ? data['access']?.toString() : null;
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          access != null &&
          access.isNotEmpty) {
        await _sessionManager.setAccessToken(access);
        completer.complete(true);
        return true;
      }

      completer.complete(false);
      return false;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _handleUnauthorized() async {
    if (_clearingSession) return;
    _clearingSession = true;
    try {
      await AppManager.instance.clearLocalSession();
      await _onUnauthorized?.call();
    } finally {
      _clearingSession = false;
    }
  }

  @override
  Future<dynamic> getApi(String url) async {
    log('ApiUrl: $url', name: 'API_CALL');
    final response = await _dio.get(url);
    return returnResponse(response);
  }

  @override
  Future<dynamic> postApi(dynamic data, String url) async {
    log('ApiUrl: $url', name: 'API_CALL');
    log('ApiData: ${jsonEncode(data)}', name: 'API_CALL');
    final response = await _dio.post(url, data: data);
    return returnResponse(response);
  }

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) async {
    final fullUrl = '$url/$id';
    log('ApiUrl: $fullUrl', name: 'API_CALL');
    log('ApiData: ${jsonEncode(data)}', name: 'API_CALL');
    final response = await _dio.patch(fullUrl, data: data);
    return returnResponse(response);
  }

  @override
  Future<dynamic> deleteApi(int id, String url) async {
    final fullUrl = '$url/$id';
    log('ApiUrl: $fullUrl', name: 'API_CALL');
    final response = await _dio.delete(fullUrl);
    return returnResponse(response);
  }

  dynamic returnResponse(Response<dynamic> response) {
    log('ApiResponse: ${response.data}', name: 'API_CALL');
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid status code: $statusCode',
        type: DioExceptionType.badResponse,
      );
    }
  }
}
