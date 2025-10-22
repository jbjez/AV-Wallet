import 'package:flutter/material.dart';
import 'package:av_wallet/config/supabase_env.dart';

class SupabaseDiagnosticPage extends StatelessWidget {
  const SupabaseDiagnosticPage({super.key});
  @override
  Widget build(BuildContext context) {
    final issues = <String>[];
    if (SupabaseEnv.supabaseUrl.startsWith('https://YOUR-PROJECT')) {
      issues.add('Supabase URL manquante. Renseigne SupabaseEnv.supabaseUrl ou --dart-define.');
    }
    if (SupabaseEnv.supabaseAnonKey.startsWith('YOUR-ANON')) {
      issues.add('Supabase anon key manquante. Renseigne SupabaseEnv.supabaseAnonKey ou --dart-define.');
    }
    issues.addAll([
      'iOS: Info.plist → URL Types avec scheme "io.supabase.flutter"',
      'Android: AndroidManifest → intent-filter scheme "io.supabase.flutter", host "login-callback"',
      'Supabase Console: ajoute "io.supabase.flutter://login-callback/" dans les Redirect URLs (Google OAuth).',
    ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Supabase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final i in issues)
            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('• $i')),
        ],
      ),
    );
  }
}
