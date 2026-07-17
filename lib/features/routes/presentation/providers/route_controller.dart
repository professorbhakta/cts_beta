import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/routes/domain/repositories/route_repository.dart';
import 'package:cts/models/route_model.dart';
import 'package:flutter/foundation.dart';

class RouteController with ChangeNotifier {
  final RouteRepository _routeRepository;

  RouteController(this._routeRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RouteModel> _routes = [];
  List<RouteModel> get routes => _routes;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchRoutes() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _routeRepository.getRoutes();

      if (result.isSuccess) {
        _routes = result.data ?? [];
        _state = ViewState.success;
      } else {
        _errorMessage = result.failure?.message;
        _state = ViewState.error;
      }
      notifyListeners();
    } finally {
      _isFetching = false; // Reset flag even if error occurs
    }
  }
  
  // Method to reset state (useful for logout)
  void reset() {
    _routes = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createRoute(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _routeRepository.createRoute(data);

    if (result.isSuccess) {
      await fetchRoutes();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoute(int id, Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _routeRepository.updateRoute(id, data);

    if (result.isSuccess && result.data != null) {
      // Use the returned route data to update the local state directly
      // This provides immediate UI feedback without needing to fetch all routes
      final updatedRoute = result.data!;
      final index = _routes.indexWhere((route) => route.id == id);
      if (index != -1) {
        _routes[index] = updatedRoute;
        _state = ViewState.success;
        notifyListeners();
        return true;
      } else {
        // If route not found in local list, fetch all routes to sync
        await fetchRoutes();
        return state == ViewState.success;
      }
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoute(int id) async {
    // Optimistic update: Remove from UI immediately
    RouteModel? removedRoute;
    final index = _routes.indexWhere((route) => route.id == id);
    if (index != -1) {
      removedRoute = _routes[index];
      _routes.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _routeRepository.deleteRoute(id);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedRoute != null && index != -1) {
        _routes.insert(index, removedRoute);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}

