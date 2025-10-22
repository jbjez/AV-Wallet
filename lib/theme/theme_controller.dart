import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.dark) { _load(); }
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    // Forcer le mode nuit par défaut - effacer toute valeur sauvegardée
    await sp.remove('themeMode');
    state = ThemeMode.dark; // Mode nuit par défaut
  }
  Future<void> set(ThemeMode mode) async {
    state = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('themeMode', mode.toString());
  }
  Future<void> toggle() async =>
      set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
