import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Script de test rapide pour vérifier le reset
void main() async {
  print('🧪 Test rapide du reset AV Wallet');
  print('=================================');
  
  try {
    print('🔄 Nettoyage des SharedPreferences...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Supprimer les clés importantes
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('remember_me');
    await prefs.remove('first_launch');
    
    print('✅ SharedPreferences nettoyées !');
    
    print('');
    print('🔍 Vérification...');
    final hasUserData = prefs.containsKey('user_id') || prefs.containsKey('user_email');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    print('Has user data: $hasUserData');
    print('Remember me: $rememberMe');
    
    if (!hasUserData && !rememberMe) {
      print('✅ L\'application devrait maintenant afficher la page de connexion !');
    } else {
      print('❌ Il reste encore des données utilisateur');
    }
    
  } catch (e) {
    print('❌ Erreur: $e');
    exit(1);
  }
}
