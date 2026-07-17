import 'package:cts/core/network/api_exceptions_handler.dart';
import 'package:cts/core/network/api_list.dart';
import 'package:cts/core/network/api_result.dart';
import 'package:cts/core/network/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/routes/domain/repositories/route_repository.dart';
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

      if (response != null) {
        if (response.toString() == "ROUTE CREATED") {
          SnackBarService.showsSuccessSnackbar(
            "Route created successfully!",
            "",
          );
          return ApiResult.success(null);
        } else {
          // If response is not "ROUTE CREATED", treat as error
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.server,
              message: response.toString(),
            ),
          );
        }
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message:
                response?.toString() ??
                "Create route failed. No response from server.",
          ),
        );
      }
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
      // A successful update returns the updated object as a Map:
      // { "id": 25, "routeName": "D4td", "adminCode": "..." }

      if (response != null && response is Map<String, dynamic>) {
        // Check if response contains id and routeName (valid route data)
        if (response.containsKey("id") &&
            response.containsKey("routeName") &&
            response["id"] == id) {
          // Parse the updated route data
          final updatedRoute = RouteModel.fromJson(response);
          SnackBarService.showsSuccessSnackbar(
            "Route updated successfully!",
            "",
          );
          return ApiResult.success(updatedRoute);
        } else {
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.parsing,
              message:
                  "Invalid response format. Expected route data with id and routeName.",
            ),
          );
        }
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message:
                response?.toString() ??
                "Update route failed. No response from server.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteRoute(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.routeUrl);
      // Check if response contains "DELETED" (case-insensitive)
      if (response != null) {
        final responseStr = response.toString().toUpperCase();
        if (responseStr.contains("DELETED")) {
          SnackBarService.showsSuccessSnackbar(
            "Route deleted successfully!",
            "",
          );
          return ApiResult.success(null);
        } else {
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.server,
              message: response.toString(),
            ),
          );
        }
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: "Delete route failed. No response from server.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}

