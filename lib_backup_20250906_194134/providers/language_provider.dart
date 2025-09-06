import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('fr'));

  void setLanguage(Locale locale) {
    state = locale;
  }
}
