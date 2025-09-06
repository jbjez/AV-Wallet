import 'dart:io';
import 'lib/services/reset_service.dart';

/// Script de test rapide pour vérifier le reset
void main() async {
  print('🧪 Test du système de reset AV Wallet');
  print('=====================================');
  
  try {
    print('🔄 Test du reset complet...');
    await ResetService.performCompleteReset();
    print('✅ Reset complet réussi !');
    
    print('');
    print('🔍 Vérification de la première visite...');
    final isFirstVisit = await ResetService.isFirstVisit();
    print('Première visite détectée: $isFirstVisit');
    
    print('');
    print('📱 L\'application devrait maintenant afficher la page de connexion');
    print('   au lieu de la page d\'accueil.');
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
    exit(1);
  }
}
