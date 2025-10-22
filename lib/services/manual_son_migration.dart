import 'package:flutter/material.dart';
import 'son_migration_service.dart';

/// Service pour forcer manuellement la migration des items Son
class ManualSonMigration {
  static Future<void> forceMigration(BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Migration des items Son en cours...'),
            ],
          ),
        ),
      );

      // Forcer la migration
      await SonMigrationService.migrateSonItems();

      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Migration des items Son terminée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la migration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
