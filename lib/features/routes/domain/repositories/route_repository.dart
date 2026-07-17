import 'package:cts/core/network/api_result.dart';
import 'package:cts/models/route_model.dart';

/// An abstract interface for handling route-related data.
abstract class RouteRepository {
  /// Fetches a list of all routes.
  Future<ApiResult<List<RouteModel>>> getRoutes();

  /// Creates a new route.
  Future<ApiResult<void>> createRoute(Map<String, dynamic> data);

  /// Updates an existing route.
  /// Returns the updated route data from the server.
  Future<ApiResult<RouteModel>> updateRoute(int id, Map<String, dynamic> data);

  /// Deletes a route by its ID.
  Future<ApiResult<void>> deleteRoute(int id);
}


