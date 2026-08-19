import 'package:cts/app/router/route_names.dart';

/// Pure redirect resolver for go_router — extracted for unit tests.
String? resolveAuthRedirect({
  required String location,
  required bool authReady,
  required bool loggedIn,
  required String? userType,
}) {
  final isPublic = RouteName.isPublicLocation(location);

  if (location == RouteName.splashScreen) return null;
  if (!authReady) return null;

  if (location == RouteName.signUp) {
    return RouteName.signIn;
  }

  if (!loggedIn) {
    if (isPublic) return null;
    return RouteName.signIn;
  }

  if (location == RouteName.signIn) {
    return RouteName.homeForRole(userType);
  }

  if (_matchesAny(location, RouteName.adminOnlyPrefixes) &&
      userType != 'ADMIN') {
    return RouteName.homeForRole(userType);
  }

  if (_matchesAny(location, RouteName.driverOnlyPrefixes) &&
      userType != 'DRIVER' &&
      userType != 'ADMIN') {
    return RouteName.homeForRole(userType);
  }

  if (_matchesAny(location, RouteName.commuterOnlyPrefixes) &&
      userType != 'COMMUTER' &&
      userType != 'ADMIN') {
    return RouteName.homeForRole(userType);
  }

  return null;
}

bool _matchesAny(String location, Set<String> prefixes) {
  for (final prefix in prefixes) {
    if (location == prefix || location.startsWith('$prefix/')) {
      return true;
    }
  }
  return false;
}
