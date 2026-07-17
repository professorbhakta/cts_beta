import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Thin helpers so call sites can migrate off [Navigator.pushNamed].
extension CtsGoRouterNav on BuildContext {
  void goClear(String location) => go(location);

  Future<T?> pushRoute<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    return push<T>(location, extra: extra);
  }

  void replaceRoute(String location, {Object? extra}) {
    pushReplacement(location, extra: extra);
  }
}
