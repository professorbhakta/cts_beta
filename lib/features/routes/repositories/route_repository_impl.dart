import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/admin_bootstrap/admin_bootstrap_list_source.dart';
import 'package:cts/features/admin_bootstrap/mappers/admin_bootstrap_list_mapper.dart';
import 'package:cts/features/routes/repositories/route_repository.dart';
import 'package:cts/models/route_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<RouteModel>>> getRoutes() async {
    final luggage = await AdminBootstrapListSource.ensureLuggage();
    if (luggage != null) {
      return ApiResult.success(AdminBootstrapListMapper.routes(luggage));
    }
    return ApiResult.failure(AdminBootstrapListSource.catalogUnavailableFailure());
  }

  @override
  Future<ApiResult<void>> createRoute(Map<String, dynamic> data) async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final requestData = {...data, 'adminCode': adminCode};

      final response = await _apiService.postApi(requestData, ApiUrl.routeUrl);

      if (response != null && response.toString() == 'ROUTE CREATED') {
        AdminBootstrapListSource.refreshInBackground();
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
          AdminBootstrapListSource.refreshInBackground();
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
        AdminBootstrapListSource.refreshInBackground();
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
