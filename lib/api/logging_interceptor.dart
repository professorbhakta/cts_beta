import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive logging interceptor for Dio requests and responses
class LoggingInterceptor extends Interceptor {
  final bool logRequestHeaders;
  final bool logRequestBody;
  final bool logResponseHeaders;
  final bool logResponseBody;
  final bool logErrors;

  const LoggingInterceptor({
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.logErrors = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      return handler.next(options);
    }

    final stopwatch = Stopwatch()..start();
    options.extra['_startTime'] = stopwatch;

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ 🌐 API REQUEST');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ${options.method} ${options.uri}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    if (logRequestHeaders && options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'cookie' ||
            key.toLowerCase() == 'authorization' ||
            key.toLowerCase() == 'x-csrftoken') {
          buffer.writeln('│   $key: [REDACTED]');
        } else {
          final headerValue = value.toString();
          if (headerValue.length > 100) {
            buffer.writeln('│   $key: ${headerValue.substring(0, 100)}...');
          } else {
            buffer.writeln('│   $key: $value');
          }
        }
      });
    }

    if (logRequestBody && options.data != null) {
      buffer.writeln('│ Request Body:');
      try {
        final data = options.data;
        String formattedData;

        if (data is FormData) {
          formattedData = 'FormData with ${data.fields.length} fields';
          if (data.files.isNotEmpty) {
            formattedData += ' and ${data.files.length} files';
          }
        } else if (data is Map || data is List) {
          formattedData = const JsonEncoder.withIndent('  ').convert(data);
        } else {
          formattedData = data.toString();
        }

        // Limit body size for readability
        if (formattedData.length > 2000) {
          formattedData =
              '${formattedData.substring(0, 2000)}...\n[Truncated ${formattedData.length - 2000} characters]';
        }

        final lines = formattedData.split('\n');
        for (final line in lines) {
          buffer.writeln('│   $line');
        }
      } catch (e) {
        buffer.writeln('│   [Unable to format request body: $e]');
      }
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );
    log(buffer.toString(), name: 'API_LOGGER');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      return handler.next(response);
    }

    final stopwatch = response.requestOptions.extra['_startTime'] as Stopwatch?;
    final duration = stopwatch?.elapsedMilliseconds ?? 0;
    stopwatch?.stop();

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ✅ API RESPONSE');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln(
      '│ ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    buffer.writeln(
      '│ Status: ${response.statusCode} ${response.statusMessage ?? ""}',
    );
    buffer.writeln('│ Duration: ${duration}ms');

    if (logResponseHeaders && response.headers.map.isNotEmpty) {
      buffer.writeln('│ Response Headers:');
      response.headers.map.forEach((key, values) {
        final value = values.join(', ');
        if (value.length > 100) {
          buffer.writeln('│   $key: ${value.substring(0, 100)}...');
        } else {
          buffer.writeln('│   $key: $value');
        }
      });
    }

    if (logResponseBody && response.data != null) {
      buffer.writeln('│ Response Body:');
      try {
        String formattedData;

        if (response.data is Map || response.data is List) {
          formattedData = const JsonEncoder.withIndent(
            '  ',
          ).convert(response.data);
        } else if (response.data is String) {
          // Try to parse as JSON for better formatting
          try {
            final json = jsonDecode(response.data as String);
            formattedData = const JsonEncoder.withIndent('  ').convert(json);
          } catch (_) {
            formattedData = response.data as String;
          }
        } else {
          formattedData = response.data.toString();
        }

        // Limit body size for readability
        if (formattedData.length > 2000) {
          formattedData =
              '${formattedData.substring(0, 2000)}...\n[Truncated ${formattedData.length - 2000} characters]';
        }

        final lines = formattedData.split('\n');
        for (final line in lines) {
          buffer.writeln('│   $line');
        }
      } catch (e) {
        buffer.writeln('│   [Unable to format response body: $e]');
        buffer.writeln('│   Raw: ${response.data}');
      }
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );
    log(buffer.toString(), name: 'API_LOGGER');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode || !logErrors) {
      return handler.next(err);
    }

    final stopwatch = err.requestOptions.extra['_startTime'] as Stopwatch?;
    final duration = stopwatch?.elapsedMilliseconds ?? 0;
    stopwatch?.stop();

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ❌ API ERROR');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    buffer.writeln('│ Error Type: ${err.type}');
    buffer.writeln('│ Duration: ${duration}ms');

    if (err.message != null) {
      buffer.writeln('│ Message: ${err.message}');
    }

    if (err.response != null) {
      buffer.writeln('│ Status Code: ${err.response?.statusCode}');
      buffer.writeln(
        '│ Status Message: ${err.response?.statusMessage ?? "N/A"}',
      );

      if (logResponseBody && err.response?.data != null) {
        buffer.writeln('│ Error Response Body:');
        try {
          String formattedData;

          if (err.response!.data is Map || err.response!.data is List) {
            formattedData = const JsonEncoder.withIndent(
              '  ',
            ).convert(err.response!.data);
          } else if (err.response!.data is String) {
            try {
              final json = jsonDecode(err.response!.data as String);
              formattedData = const JsonEncoder.withIndent('  ').convert(json);
            } catch (_) {
              formattedData = err.response!.data as String;
            }
          } else {
            formattedData = err.response!.data.toString();
          }

          if (formattedData.length > 1000) {
            formattedData =
                '${formattedData.substring(0, 1000)}...\n[Truncated ${formattedData.length - 1000} characters]';
          }

          final lines = formattedData.split('\n');
          for (final line in lines) {
            buffer.writeln('│   $line');
          }
        } catch (e) {
          buffer.writeln('│   [Unable to format error body: $e]');
          buffer.writeln('│   Raw: ${err.response?.data}');
        }
      }
    } else {
      buffer.writeln('│ No response received');
    }

    if (err.error != null) {
      buffer.writeln('│ Error Object: ${err.error}');
    }

    buffer.writeln('│ Stack Trace:');
    final stackLines = err.stackTrace.toString().split('\n');
    for (final line in stackLines.take(5)) {
      buffer.writeln('│   $line');
    }
    if (stackLines.length > 5) {
      buffer.writeln('│   ... (${stackLines.length - 5} more lines)');
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );
    log(buffer.toString(), name: 'API_LOGGER', level: 1000); // Error level

    handler.next(err);
  }
}
