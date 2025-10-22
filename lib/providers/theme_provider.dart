import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';
  late SharedPreferences _prefs;
  
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Forcer le mode nuit par défaut - effacer toute valeur sauvegardée
      await _prefs.remove(_key);
      state = ThemeMode.dark; // Mode nuit par défaut
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      await _prefs.setString(_key, newTheme.toString());
      state = newTheme;
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    try {
      await _prefs.setString(_key, theme.toString());
      state = theme;
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

