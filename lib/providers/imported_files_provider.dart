import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImportedFilesNotifier extends StateNotifier<List<String>> {
  ImportedFilesNotifier() : super([]) {
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesJson = prefs.getString('imported_files');
      if (filesJson != null) {
        state = List<String>.from(json.decode(filesJson));
      }
    } catch (e) {
      print('Error loading imported files: $e');
    }
  }

  Future<void> addFile(String fileName) async {
    print('DEBUG: Ajout du fichier: $fileName');
    if (!state.contains(fileName)) {
      state = [...state, fileName];
      await _saveFiles();
      print('DEBUG: Fichier ajouté. Nouveau state: $state');
    } else {
      print('DEBUG: Fichier déjà présent: $fileName');
    }
  }

  Future<void> removeFile(String fileName) async {
    state = state.where((file) => file != fileName).toList();
    await _saveFiles();
  }

  Future<void> _saveFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imported_files', json.encode(state));
    } catch (e) {
      print('Error saving imported files: $e');
    }
  }
}

final importedFilesProvider = StateNotifierProvider<ImportedFilesNotifier, List<String>>((ref) {
  return ImportedFilesNotifier();
});
