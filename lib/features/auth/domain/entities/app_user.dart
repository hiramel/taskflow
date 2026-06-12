/// Lightweight domain representation of an authenticated user.
class AppUser {
  /// Creates a user with a stable id, optional name and optional email.
  const AppUser({
    required this.id,
    this.name,
    this.email,
  });

  /// Unique user identifier from Supabase Auth.
  final String id;

  /// Display name stored in Supabase user metadata, if available.
  final String? name;

  /// User email address, if available.
  final String? email;
}
