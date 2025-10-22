// [L001]
// [L002]
import 'package:hive/hive.dart'; // [L003]

// Modèle minimal attendu : PdfData(id, name, path, presetId, createdAt) déjà déclaré côté Hive. // [L004]

class PdfStorageRepository { // [L005]
  final Box _box; // [L006]
  PdfStorageRepository(this._box); // [L007]

  Future<void> savePdf(Map<String, dynamic> pdfMap) async { // [L008]
    // Garantir l'écriture avant update UI // [L009]
    await _box.put(pdfMap['id'], pdfMap); // [L010]
  } // [L011]

  List<Map> getPresetPdfs(String presetId) { // [L012]
    return _box.values // [L013]
      .where((e) => e is Map && e['presetId'] == presetId) // [L014]
      .cast<Map>() // [L015]
      .toList(); // [L016]
  } // [L017]

  Map<String, dynamic>? getPdfById(String pdfId) { // [L018]
    return _box.get(pdfId); // [L019]
  } // [L020]

  Future<void> deletePdf(String pdfId) async { // [L021]
    await _box.delete(pdfId); // [L022]
  } // [L023]
} // [L024]