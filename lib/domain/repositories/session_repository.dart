/// An abstract interface for managing user session data.
///
/// The domain layer depends on this abstraction, while the data layer
/// will provide a concrete implementation.
abstract class SessionRepository {
  /// Returns `true` if a user is currently logged in.
  Future<bool> isLoggedIn();

  /// Returns the type of the logged-in user (e.g., "ADMIN", "DRIVER").
  /// Returns `null` if no user is logged in.
  Future<String?> getUserType();
}
