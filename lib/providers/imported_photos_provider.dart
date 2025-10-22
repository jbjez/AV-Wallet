import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Provider pour gérer les photos importées pour chaque projet
class ImportedPhotosNotifier extends StateNotifier<Map<String, List<String>>> {
  ImportedPhotosNotifier() : super({});

  /// Charger les photos depuis SharedPreferences uniquement
  Future<void> loadPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getString('imported_photos');
      
      if (photosJson != null) {
        final Map<String, dynamic> savedPhotosMap = jsonDecode(photosJson);
        state = savedPhotosMap.map((key, value) => MapEntry(key, List<String>.from(value)));
      } else {
        state = {};
      }
      
      debugPrint('Photos chargées depuis SharedPreferences: $state');
    } catch (e) {
      debugPrint('Erreur lors du chargement des photos: $e');
      state = {};
    }
  }

  /// Sauvegarder les photos dans SharedPreferences
  Future<void> _savePhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imported_photos', jsonEncode(state));
    } catch (e) {
      print('Erreur lors de la sauvegarde des photos: $e');
    }
  }

  /// Ajouter une photo à un projet
  Future<void> addPhotoToProject(String projectName, String photoPath) async {
    final currentPhotos = state[projectName] ?? [];
    if (!currentPhotos.contains(photoPath)) {
      state = {
        ...state,
        projectName: [...currentPhotos, photoPath],
      };
      await _savePhotos();
      
      // Copier aussi la photo dans le dossier du projet
      await _copyPhotoToProjectFolder(projectName, photoPath);
    }
  }
  
  /// Copier une photo dans le dossier du projet
  Future<void> _copyPhotoToProjectFolder(String projectName, String photoPath) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${documentsDir.path}/projets/$projectName/photos_ar');
      
      // Créer le dossier s'il n'existe pas
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }
      
      final sourceFile = File(photoPath);
      if (await sourceFile.exists()) {
        final fileName = photoPath.split('/').last;
        final destinationFile = File('${projectDir.path}/$fileName');
        await sourceFile.copy(destinationFile.path);
        debugPrint('Photo copiée vers le projet: ${destinationFile.path}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la copie de la photo: $e');
    }
  }

  /// Supprimer une photo d'un projet
  Future<void> removePhotoFromProject(String projectName, String photoPath) async {
    final currentPhotos = state[projectName] ?? [];
    if (currentPhotos.contains(photoPath)) {
      state = {
        ...state,
        projectName: currentPhotos.where((path) => path != photoPath).toList(),
      };
      await _savePhotos();
      
      // Supprimer aussi le fichier physique
      try {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Fichier physique supprimé: $photoPath');
        }
      } catch (e) {
        debugPrint('Erreur lors de la suppression du fichier physique: $e');
      }
    }
  }

  /// Supprimer toutes les photos de tous les projets
  Future<void> clearAllPhotos() async {
    state = {};
    await _savePhotos();
    debugPrint('Toutes les photos supprimées');
  }

  /// Supprimer toutes les photos d'un projet
  Future<void> clearProjectPhotos(String projectName) async {
    if (state.containsKey(projectName)) {
      state = {
        ...state,
        projectName: <String>[],
      };
      await _savePhotos();
      debugPrint('Photos du projet $projectName supprimées');
    }
  }

  /// Obtenir les photos d'un projet
  List<String> getPhotosForProject(String projectName) {
    return state[projectName] ?? [];
  }

  /// Copier les photos d'un projet vers le dossier photos_ar
  Future<void> copyPhotosToProjectFolder(String projectName) async {
    try {
      final photos = getPhotosForProject(projectName);
      if (photos.isEmpty) return;

      final documentsDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${documentsDir.path}/projets/$projectName/photos_ar');
      
      // Créer le dossier s'il n'existe pas
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      // Copier chaque photo
      for (final photoPath in photos) {
        final sourceFile = File(photoPath);
        if (await sourceFile.exists()) {
          final fileName = photoPath.split('/').last;
          final destinationFile = File('${projectDir.path}/$fileName');
          await sourceFile.copy(destinationFile.path);
        }
      }
    } catch (e) {
      print('Erreur lors de la copie des photos: $e');
    }
  }

  /// Vérifier si des photos existent pour un projet
  bool hasPhotosForProject(String projectName) {
    return (state[projectName] ?? []).isNotEmpty;
  }

  /// Obtenir le nombre de photos pour un projet
  int getPhotoCountForProject(String projectName) {
    return (state[projectName] ?? []).length;
  }
}

final importedPhotosProvider = StateNotifierProvider<ImportedPhotosNotifier, Map<String, List<String>>>((ref) {
  return ImportedPhotosNotifier();
});

/// Provider pour obtenir les photos d'un projet spécifique
final projectPhotosProvider = Provider.family<List<String>, String>((ref, projectName) {
  final importedPhotos = ref.watch(importedPhotosProvider);
  return importedPhotos[projectName] ?? [];
});

/// Provider pour vérifier si un projet a des photos
final hasProjectPhotosProvider = Provider.family<bool, String>((ref, projectName) {
  final photos = ref.watch(projectPhotosProvider(projectName));
  return photos.isNotEmpty;
});
