import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../providers/project_provider.dart';
import '../providers/imported_photos_provider.dart';
import '../providers/preset_pdf_provider.dart';
import '../providers/preset_files_provider.dart';

/// Provider optimisé pour les compteurs de badges du projet
final projectBadgesProvider = Provider<Map<String, int>>((ref) {
  final presets = ref.watch(presetProvider);
  final importedPhotos = ref.watch(importedPhotosProvider);
  final project = ref.watch(projectProvider).selectedProject;
  
  // Calculer les compteurs de manière optimisée
  int calculationCount = 0;
  int presetPhotosCount = 0;
  
  for (final preset in presets) {
    try {
      final pdfMaps = ref.read(presetPdfProvider(preset.id));
      calculationCount += pdfMaps.length;
      
      final imageFiles = ref.read(presetImageFilesProvider(preset.id));
      presetPhotosCount += imageFiles.length;
    } catch (e) {
      // Ignorer les erreurs silencieusement
      continue;
    }
  }
  
  final projectPhotos = importedPhotos[project.name] ?? [];
  final photoCount = projectPhotos.length + presetPhotosCount;
  
  return {
    'photos': photoCount,
    'calculations': calculationCount,
  };
});

/// Provider pour vérifier si les badges doivent être affichés
final shouldShowBadgesProvider = Provider<bool>((ref) {
  final badges = ref.watch(projectBadgesProvider);
  return badges['photos']! > 0 || badges['calculations']! > 0;
});
