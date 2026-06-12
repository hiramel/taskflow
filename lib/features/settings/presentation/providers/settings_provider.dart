import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'settings_dark_mode_enabled';

  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  Future<void> loadSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _isDarkModeEnabled = preferences.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkModeEnabled(bool value) async {
    if (_isDarkModeEnabled == value) {
      return;
    }

    _isDarkModeEnabled = value;
    notifyListeners();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, value);
  }
}
