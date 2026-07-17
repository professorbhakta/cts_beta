import 'package:cts/appManager/app_class.dart';
import 'package:dio/dio.dart';

class DioFactory {
  /// Creates and configures a Dio instance.
  Dio create() {
    final config = AppConfig.instance;
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Connection': 'Keep-Alive',
          'content-type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    return dio;
  }
}
