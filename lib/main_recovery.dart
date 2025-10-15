import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // tu utilises Riverpod
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import 'package:av_wallet_hive/pages/home_page.dart';
// 👉 Si ta page d'accueil est bien à lib/pages/home_page.dart, décommente la ligne suivante :
// import 'package:av_wallet_hive/pages/home_page.dart';

void main() => runApp(const ProviderScope(child: AVWalletApp()));

class AVWalletApp extends StatelessWidget {
  const AVWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AV Wallet (recovery)',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)), // bleu
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1E3A8A),      // bleu nuit
          secondary: const Color(0xFF0EA5E9),    // accent cyan doux
          surface: const Color(0xFF0B152B),
          background: const Color(0xFF0B152B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B152B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B152B),
          foregroundColor: Color(0xFFE2E8F0),
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // 👉 Si tu as importé HomePage ci-dessus, remplace _RecoveryHome() par HomePage()
     home: const HomePage(),
    );
  }
}

class _RecoveryHome extends StatelessWidget {
  const _RecoveryHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AV Wallet — recovery')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ça boote ✅', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Locale: ${Localizations.localeOf(context)}'),
          ],
        ),
      ),
    );
  }
}
