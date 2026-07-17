import 'package:cts/domain/usecases/get_initial_route_usecase.dart';
import 'package:flutter/material.dart';

/// Manages splash startup state and the post-splash destination route.
class SplashProvider with ChangeNotifier {
  SplashProvider(this._getInitialRouteUseCase);

  final GetInitialRouteUseCase _getInitialRouteUseCase;

  bool _isLoading = true;
  String? _initialRoute;

  bool get isLoading => _isLoading;
  String? get initialRoute => _initialRoute;

  Future<void> determineInitialRoute() async {
    _isLoading = true;
    notifyListeners();

    _initialRoute = await _getInitialRouteUseCase();

    _isLoading = false;
    notifyListeners();
  }
}
