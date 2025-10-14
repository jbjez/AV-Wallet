import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class OAuthTestService {
  static final _logger = Logger('OAuthTestService');
  static final _supabase = Supabase.instance.client;

  static Future<void> testGoogleOAuth() async {
    try {
      _logger.info('Testing Google OAuth configuration...');
      
      // Test de la configuration OAuth
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.avwallet://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      _logger.info('OAuth test response: $response');
      
      if (response) {
        _logger.info('✅ OAuth configuration is working!');
      } else {
        _logger.severe('❌ OAuth configuration failed');
      }
      
    } catch (e) {
      _logger.severe('❌ OAuth test error: $e');
      
      // Analyser l'erreur
      if (e.toString().contains('401')) {
        _logger.severe('❌ 401 Error: Invalid client ID or secret');
      } else if (e.toString().contains('redirect_uri_mismatch')) {
        _logger.severe('❌ Redirect URI mismatch');
      } else if (e.toString().contains('invalid_client')) {
        _logger.severe('❌ Invalid client configuration');
      }
    }
  }
}





