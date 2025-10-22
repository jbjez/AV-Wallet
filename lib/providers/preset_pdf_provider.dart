// [L001]
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [L002]
import 'package:flutter/foundation.dart'; // [L003]
import 'package:hive/hive.dart'; // [L004]
import 'pdf_storage_provider.dart'; // [L005]

final hivePdfBoxProvider = Provider<Box>((ref) { // [L005]
  // Récupère la box des PDFs (nom existant à adapter si différent) // [L006]
  return Hive.box('pdf_box'); // [L007]
}); // [L008]

final pdfRepoProvider = Provider<PdfStorageRepository>((ref) { // [L009]
  final box = ref.watch(hivePdfBoxProvider); // [L010]
  return PdfStorageRepository(box); // [L011]
}); // [L012]

class PresetFilesNotifier extends StateNotifier<List<Map>> { // [L013]
  final Ref ref; // [L014]
  final String presetId; // [L015]
  PresetFilesNotifier(this.ref, this.presetId) : super(const []) { // [L016]
    _load(); // [L017]
  } // [L018]

  void _load() { // [L019]
    final repo = ref.read(pdfRepoProvider); // [L020]
    state = repo.getPresetPdfs(presetId); // [L021]
  } // [L022]

  Future<void> addPdf(Map<String, dynamic> pdfMap) async { // [L023]
    debugPrint('DEBUG PresetPdfProvider - Ajout PDF pour preset: $presetId');
    debugPrint('DEBUG PresetPdfProvider - PDF Map: $pdfMap');
    
    // 1) Écrit dans Hive et attend la fin (crucial pour le 1er export) // [L024]
    await ref.read(pdfRepoProvider).savePdf(pdfMap); // [L025]
    debugPrint('DEBUG PresetPdfProvider - PDF sauvegardé dans Hive');
    
    // 2) Puis met à jour l'état immédiatement // [L026]
    state = [...state, pdfMap]; // [L027]
    debugPrint('DEBUG PresetPdfProvider - État mis à jour, ${state.length} PDFs total');
  } // [L028]

  void refresh() => _load(); // [L029]
} // [L030]

final presetPdfProvider = StateNotifierProvider.family<PresetFilesNotifier, List<Map>, String>((ref, presetId) { // [L031]
  return PresetFilesNotifier(ref, presetId); // [L032]
}); // [L033]

// Provider pour récupérer un PDF par son ID depuis Hive
final pdfByIdProvider = Provider.family<Map<String, dynamic>?, String>((ref, pdfId) {
  final repo = ref.read(pdfRepoProvider);
  return repo.getPdfById(pdfId);
});
