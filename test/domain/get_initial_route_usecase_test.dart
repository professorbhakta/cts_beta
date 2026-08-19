import 'package:cts/app/router/route_names.dart';
import 'package:cts/domain/repositories/session_repository.dart';
import 'package:cts/domain/usecases/get_initial_route_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSessionRepository implements SessionRepository {
  _FakeSessionRepository({
    required this.loggedIn,
    this.userType,
  });

  final bool loggedIn;
  final String? userType;

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<String?> getUserType() async => userType;
}

void main() {
  group('GetInitialRouteUseCase', () {
    test('guest goes to signIn', () async {
      final useCase = GetInitialRouteUseCase(
        _FakeSessionRepository(loggedIn: false),
      );

      expect(await useCase(), RouteName.signIn);
    });

    test('admin session routes to admin home', () async {
      final useCase = GetInitialRouteUseCase(
        _FakeSessionRepository(loggedIn: true, userType: 'ADMIN'),
      );

      expect(await useCase(), RouteName.adminHomeScreen);
    });

    test('unknown role falls back to signIn', () async {
      final useCase = GetInitialRouteUseCase(
        _FakeSessionRepository(loggedIn: true, userType: 'UNKNOWN'),
      );

      expect(await useCase(), RouteName.signIn);
    });
  });
}
