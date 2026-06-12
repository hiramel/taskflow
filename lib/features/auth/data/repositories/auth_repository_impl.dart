import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase Auth implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  AppUser _mapUser(User user) {
    final Map<String, dynamic>? metadata = user.userMetadata;
    final String? metadataName = _readDisplayName(metadata);

    return AppUser(
      id: user.id,
      name: metadataName,
      email: user.email,
    );
  }

  String? _readDisplayName(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return null;
    }

    final Object? value = metadata['name'] ?? metadata['full_name'] ?? metadata['username'];
    final String? name = value?.toString().trim();
    if (name == null || name.isEmpty) {
      return null;
    }

    return name;
  }

  @override
  AppUser? getCurrentUser() {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }

    return _mapUser(user);
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final User? user = response.user ?? Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Login succeeded but no user session was returned.');
    }

    return _mapUser(user);
  }

  @override
  Future<AppUser> register(String email, String password) async {
    final AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = response.user ?? Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Registration succeeded but no user session was returned.');
    }

    return _mapUser(user);
  }

  @override
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
