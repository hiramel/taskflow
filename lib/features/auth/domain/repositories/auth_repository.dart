import '../entities/app_user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Returns the currently signed-in user, or null if there is no session.
  AppUser? getCurrentUser();

  /// Signs in with email and password.
  Future<AppUser> login(String email, String password);

  /// Registers a new user with email and password.
  Future<AppUser> register(String email, String password);

  /// Signs the current user out.
  Future<void> logout();
}
