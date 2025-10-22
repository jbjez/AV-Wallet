import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sound_page_state.dart';
import '../models/catalogue_item.dart';

class SoundPageNotifier extends StateNotifier<SoundPageState> {
  SoundPageNotifier() : super(const SoundPageState()) {
    _loadState();
  }

  static const String _storageKey = 'sound_page_state';

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_storageKey);
      if (stateJson != null) {
        final stateMap = json.decode(stateJson) as Map<String, dynamic>;
        state = SoundPageState.fromJson(stateMap);
      }
    } catch (e) {
      // En cas d'erreur, garder l'état par défaut
      print('Erreur lors du chargement de l\'état de la page son: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = json.encode(state.toJson());
      await prefs.setString(_storageKey, stateJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'état de la page son: $e');
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _saveState();
  }

  void updateSelectedSpeaker(String? speaker) {
    state = state.copyWith(selectedSpeaker: speaker);
    _saveState();
  }

  void updateSpeakerQuantity(int quantity) {
    state = state.copyWith(speakerQuantity: quantity);
    _saveState();
  }

  void updateSelectedSpeakers(List<Map<String, dynamic>> speakers) {
    state = state.copyWith(selectedSpeakers: speakers);
    _saveState();
  }

  void updateSearchResults(List<CatalogueItem> results) {
    state = state.copyWith(searchResults: results);
    _saveState();
  }

  void updateCalculationResult(String? result) {
    state = state.copyWith(calculationResult: result);
    _saveState();
  }

  void clearCalculationResult() {
    state = state.copyWith(calculationResult: null);
    _saveState();
  }

  void updateSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _saveState();
  }

  void updateSelectedBrand(String? brand) {
    state = state.copyWith(selectedBrand: brand);
    _saveState();
  }

  void resetState() {
    state = const SoundPageState();
    _saveState();
  }
}

final soundPageProvider = StateNotifierProvider<SoundPageNotifier, SoundPageState>((ref) {
  return SoundPageNotifier();
});
