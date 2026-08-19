import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/routes/repositories/route_repository.dart';
import 'package:cts/models/route_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<RouteModel>>> getRoutes() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminRouteUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final routes = response
            .map((json) => RouteModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResult.success(routes);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Invalid response format',
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> createRoute(Map<String, dynamic> data) async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final requestData = {...data, 'adminCode': adminCode};

      final response = await _apiService.postApi(requestData, ApiUrl.routeUrl);

      if (response != null && response.toString() == 'ROUTE CREATED') {
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Create route failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<RouteModel>> updateRoute(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.patchApi(id, data, ApiUrl.routeUrl);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('id') &&
            response.containsKey('routeName') &&
            response['id'] == id) {
          final updatedRoute = RouteModel.fromJson(response);
          return ApiResult.success(updatedRoute);
        }

        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message:
                'Invalid response format. Expected route data with id and routeName.',
          ),
        );
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.parsing,
          message: response?.toString() ?? 'Update route failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteRoute(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.routeUrl);

      if (response != null &&
          response.toString().toUpperCase().contains('DELETED')) {
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Delete route failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
