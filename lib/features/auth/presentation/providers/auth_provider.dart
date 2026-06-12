import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Holds authentication state for the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// Currently signed-in user, if any.
  AppUser? get currentUser => _currentUser;

  /// Whether an authentication action is in progress.
  bool get isLoading => _isLoading;

  /// Error message from the last auth attempt.
  String? get errorMessage => _errorMessage;

  /// Whether the user is authenticated.
  bool get isAuthenticated => _currentUser != null;

  /// Loads the current session user, if any.
  Future<void> getCurrentUser() async {
    _currentUser = _authRepository.getCurrentUser();
    _errorMessage = null;
    notifyListeners();
  }

  /// Signs in with email and password.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user with email and password.
  Future<void> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(email, password);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs the current user out.
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.logout();
      _currentUser = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
