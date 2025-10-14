import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/catalogue_item.dart';
import '../models/preset.dart';
import '../services/hive_service.dart';

class BackupService {
  static Future<void> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');

      final catalogueItems = await HiveService.getAllCatalogueItems();
      final presets = await HiveService.getAllPresets();

      final backupData = {
        'catalogueItems': catalogueItems.map((item) => item.toMap()).toList(),
        'presets': presets.map((preset) => preset.toMap()).toList(),
        'timestamp': timestamp,
      };

      await backupFile.writeAsString(jsonEncode(backupData));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      final backupData = jsonDecode(await backupFile.readAsString());
      final catalogueItems = (backupData['catalogueItems'] as List)
          .map((item) => CatalogueItem.fromMap(item))
          .toList();
      final presets = (backupData['presets'] as List)
          .map((preset) => Preset.fromMap(preset))
          .toList();

      await HiveService.clearCatalogue();
      await HiveService.clearPresets();
      for (final item in catalogueItems) {
        await HiveService.addCatalogueItem(item);
      }
      for (final preset in presets) {
        await HiveService.addPreset(preset);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      return files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }
} 
