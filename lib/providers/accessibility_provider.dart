import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider with ChangeNotifier {
  static const String _fontSizeScaleKey = 'fontSizeScale';
  static const String _highContrastModeKey = 'highContrastMode';

  double _fontSizeScale = 1.0;
  bool _highContrastMode = false;

  double get fontSizeScale => _fontSizeScale;
  bool get highContrastMode => _highContrastMode;

  AccessibilityProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
    _highContrastMode = prefs.getBool(_highContrastModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeScaleKey, scale);
    notifyListeners();
  }

  Future<void> setHighContrastMode(bool enabled) async {
    _highContrastMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastModeKey, enabled);
    notifyListeners();
  }
}
