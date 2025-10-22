import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:av_wallet/config/supabase_env.dart';

class SB {
  static bool _inited = false;
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    if (_inited) return;
    
    // Vérifier si les clés sont configurées
    if (!SupabaseEnv.isConfigured) {
      print('⚠️ SUPABASE NON CONFIGURÉ - Mode démo activé');
      print('URL: ${SupabaseEnv.supabaseUrl}');
      print('Key: ${SupabaseEnv.supabaseAnonKey.substring(0, 10)}...');
      print('Configure tes clés dans lib/config/supabase_env.dart ou via --dart-define');
      _inited = true; // Marquer comme initialisé pour éviter les crashes
      return;
    }
    
    await Supabase.initialize(
      url: SupabaseEnv.supabaseUrl,
      anonKey: SupabaseEnv.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // OAuth mobile
      ),
      debug: true,
    );
    _inited = true;
    print('✅ Supabase initialisé avec succès');
  }

  static Stream<AuthState> authState() {
    if (!SupabaseEnv.isConfigured) {
      return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
    }
    return client.auth.onAuthStateChange;
  }

  static Session? get session {
    if (!SupabaseEnv.isConfigured) return null;
    return client.auth.currentSession;
  }
  
  static User? get user {
    if (!SupabaseEnv.isConfigured) return null;
    return client.auth.currentUser;
  }

  static Future<AuthResponse> signUpEmail(String email, String password) async {
    await init();
    if (!SupabaseEnv.isConfigured) {
      throw Exception('Supabase non configuré - impossible de s\'inscrire');
    }
    return client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signInEmail(String email, String password) async {
    await init();
    if (!SupabaseEnv.isConfigured) {
      throw Exception('Supabase non configuré - impossible de se connecter');
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    if (!SupabaseEnv.isConfigured) return;
    await client.auth.signOut();
  }

  static Future<void> signInGoogle() async {
    await init();
    if (!SupabaseEnv.isConfigured) {
      throw Exception('Supabase non configuré - impossible de se connecter avec Google');
    }
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.avwallet.avWalletHive://login-callback/',
      // scopes: 'email profile', // optionnel
    );
  }
}
