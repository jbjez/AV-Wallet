import 'dart:io';
import '../services/reset_service.dart';

/// Script utilitaire pour effectuer un reset complet de l'application
/// Usage: dart run lib/scripts/reset_app.dart
void main() async {
  print('🔄 AV Wallet - Script de Reset');
  print('==============================');
  
  try {
    print('⚠️  ATTENTION: Ce script va supprimer TOUTES les données locales de l\'application.');
    print('   Cela inclut:');
    print('   - Toutes les données Hive (catalogue, projets, panier, etc.)');
    print('   - Toutes les préférences utilisateur (SharedPreferences)');
    print('   - Les sessions d\'authentification');
    print('   - Les paramètres de l\'application');
    print('');
    
    stdout.write('Êtes-vous sûr de vouloir continuer ? (oui/non): ');
    final input = stdin.readLineSync()?.toLowerCase();
    
    if (input != 'oui' && input != 'o' && input != 'yes' && input != 'y') {
      print('❌ Opération annulée.');
      exit(0);
    }
    
    print('');
    print('🔄 Début de la réinitialisation...');
    
    // Effectuer le reset complet
    await ResetService.performCompleteReset();
    
    print('✅ Réinitialisation terminée avec succès !');
    print('');
    print('📱 L\'application va maintenant se comporter comme lors de la première installation.');
    print('   - Toutes les données locales ont été supprimées');
    print('   - L\'utilisateur sera déconnecté');
    print('   - Les paramètres sont revenus aux valeurs par défaut');
    print('');
    print('🚀 Vous pouvez maintenant relancer l\'application.');
    
  } catch (e) {
    print('❌ Erreur lors de la réinitialisation: $e');
    print('');
    print('💡 Solutions possibles:');
    print('   - Vérifiez que l\'application n\'est pas en cours d\'exécution');
    print('   - Relancez le script en tant qu\'administrateur si nécessaire');
    print('   - Contactez le support technique si le problème persiste');
    exit(1);
  }
}
