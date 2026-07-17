import 'package:cts/app/router/route_names.dart';
import 'package:cts/domain/repositories/session_repository.dart';

/// Determines the initial route a user should see when the app starts.
class GetInitialRouteUseCase {
  final SessionRepository _sessionRepository;

  GetInitialRouteUseCase(this._sessionRepository);

  /// Checks login status and role to pick the post-splash destination.
  Future<String> call() async {
    final bool loggedIn = await _sessionRepository.isLoggedIn();
    if (!loggedIn) return RouteName.signIn;

    final String? userType = await _sessionRepository.getUserType();
    return RouteName.homeForRole(userType);
  }
}

