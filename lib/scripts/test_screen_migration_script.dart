import 'dart:io';
import 'package:logging/logging.dart';
import '../services/test_screen_migration.dart';

/// Script exécutable pour tester la migration des écrans
/// Usage: dart run lib/scripts/test_screen_migration_script.dart
void main() async {
  // Configurer le logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  final logger = Logger('Main');
  
  try {
    logger.info('🚀 Starting screen migration test script...');
    
    // Test de migration
    await TestScreenMigration.testMigration();
    
    logger.info('✅ Test script completed successfully');
    
  } catch (e, stackTrace) {
    logger.severe('❌ Test script failed', e, stackTrace);
    exit(1);
  }
}
