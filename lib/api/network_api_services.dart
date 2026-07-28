import 'dart:convert'; // Import for jsonEncode
import 'dart:developer';
import 'dart:io';

import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/api/logging_interceptor.dart';
import 'package:dio/dio.dart';

import 'package:cts/api/base_api_services.dart';

const String _csrfCookieName = 'csrftoken';
const String _sessionCookieName = 'sessionid';

class NetworkApiServices extends BaseApiServices {
  NetworkApiServices({String? baseUrl})
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
    // Add comprehensive logging interceptor first (so it logs everything)
    _dio.interceptors.add(
      const LoggingInterceptor(
        logRequestHeaders: true,
        logRequestBody: true,
        logResponseHeaders: false,
        logResponseBody: true,
        logErrors: true,
      ),
    );

    // Add cookie and CSRF token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookies = await _cookieHeader();
          if (cookies.isNotEmpty) {
            options.headers[HttpHeaders.cookieHeader] = cookies;
          }
          
          // Add CSRF token header for state-changing requests (POST, PATCH, DELETE)
          if (options.method == 'POST' || options.method == 'PATCH' || options.method == 'DELETE') {
            final csrfToken = await _sessionManager.getCsrfToken();
            if (csrfToken != null && csrfToken.isNotEmpty) {
              options.headers['X-CSRFToken'] = csrfToken;
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          await _handleSetCookie(response.headers['set-cookie']);
          return handler.next(response);
        },
        onError: (error, handler) async {
          return handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final SessionManager _sessionManager;

  Future<void> _handleSetCookie(List<String>? setCookieHeaders) async {
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;
    for (final header in setCookieHeaders) {
      final pair = _parseCookiePair(header);
      if (pair == null) continue;
      final key = pair.key.toLowerCase();
      if (key == _csrfCookieName) {
        await _sessionManager.setCsrfToken(pair.value);
      } else if (key == _sessionCookieName) {
        await _sessionManager.setSessionId(pair.value);
      }
    }
  }

  Future<String> _cookieHeader() async {
    final cookies = await _sessionManager.buildCookieHeader();
    final entries = cookies.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => '${entry.key}=${entry.value}');
    return entries.join('; ');
  }

  _CookiePair? _parseCookiePair(String header) {
    if (header.isEmpty) return null;
    final firstSegment = header.split(';').first;
    if (!firstSegment.contains('=')) return null;
    final separatorIndex = firstSegment.indexOf('=');
    if (separatorIndex == -1) return null;
    final key = firstSegment.substring(0, separatorIndex).trim();
    final value = firstSegment.substring(separatorIndex + 1).trim();
    if (key.isEmpty || value.isEmpty) return null;
    return _CookiePair(key: key, value: value);
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

class _CookiePair {
  const _CookiePair({required this.key, required this.value});
  final String key;
  final String value;
}

