import 'package:flutter/material.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._prefs)
      : _isDarkMode =
            _prefs.getBool(_themeKey) ?? false; // Default to light mode
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;
  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme =>
      _isDarkMode ? OpstechTheme.darkTheme : OpstechTheme.lightTheme;
}
