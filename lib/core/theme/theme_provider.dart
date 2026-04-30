import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Start the app in light mode by default
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() {
    setDarkMode(!_isDarkMode);
  }
}
