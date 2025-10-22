import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Provider pour gérer les fichiers associés à chaque preset
class PresetFilesNotifier extends StateNotifier<Map<String, List<String>>> {
  PresetFilesNotifier() : super({});

  // Charger les données depuis SharedPreferences
  Future<void> loadFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesJson = prefs.getString('preset_files');
      if (filesJson != null) {
        final Map<String, dynamic> filesMap = jsonDecode(filesJson);
        state = filesMap.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    } catch (e) {
      print('Erreur lors du chargement des fichiers: $e');
    }
  }

  // Sauvegarder les données dans SharedPreferences
  Future<void> _saveFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preset_files', jsonEncode(state));
    } catch (e) {
      print('Erreur lors de la sauvegarde des fichiers: $e');
    }
  }

  // Ajouter un fichier à un preset
  Future<void> addFileToPreset(String presetId, String filePath) async {
    final currentFiles = state[presetId] ?? [];
    if (!currentFiles.contains(filePath)) {
      state = {
        ...state,
        presetId: [...currentFiles, filePath],
      };
      await _saveFiles();
    }
  }

  // Supprimer un fichier d'un preset
  Future<void> removeFileFromPreset(String presetId, String filePath) async {
    final currentFiles = state[presetId] ?? [];
    if (currentFiles.contains(filePath)) {
      state = {
        ...state,
        presetId: currentFiles.where((file) => file != filePath).toList(),
      };
      await _saveFiles();
    }
  }

  // Obtenir les fichiers d'un preset
  List<String> getFilesForPreset(String presetId) {
    return state[presetId] ?? [];
  }

  // Obtenir les fichiers PDF d'un preset (filtre les extensions d'images)
  List<String> getPdfFilesForPreset(String presetId) {
    final files = getFilesForPreset(presetId);
    return files.where((file) => 
      !file.toLowerCase().endsWith('.jpg') && 
      !file.toLowerCase().endsWith('.jpeg') && 
      !file.toLowerCase().endsWith('.png')
    ).toList();
  }

  // Obtenir les fichiers image d'un preset
  List<String> getImageFilesForPreset(String presetId) {
    final files = getFilesForPreset(presetId);
    return files.where((file) => 
      file.toLowerCase().endsWith('.jpg') || 
      file.toLowerCase().endsWith('.jpeg') || 
      file.toLowerCase().endsWith('.png')
    ).toList();
  }
}

final presetFilesProvider = StateNotifierProvider<PresetFilesNotifier, Map<String, List<String>>>((ref) {
  return PresetFilesNotifier();
});

// Provider pour obtenir les fichiers PDF d'un preset spécifique
final presetPdfFilesProvider = Provider.family<List<String>, String>((ref, presetId) {
  final presetFiles = ref.watch(presetFilesProvider);
  return presetFiles[presetId]?.where((file) => 
    !file.toLowerCase().endsWith('.jpg') && 
    !file.toLowerCase().endsWith('.jpeg') && 
    !file.toLowerCase().endsWith('.png')
  ).toList() ?? [];
});

// Provider pour obtenir les fichiers image d'un preset spécifique
final presetImageFilesProvider = Provider.family<List<String>, String>((ref, presetId) {
  final presetFiles = ref.watch(presetFilesProvider);
  return presetFiles[presetId]?.where((file) => 
    file.toLowerCase().endsWith('.jpg') || 
    file.toLowerCase().endsWith('.jpeg') || 
    file.toLowerCase().endsWith('.png')
  ).toList() ?? [];
});