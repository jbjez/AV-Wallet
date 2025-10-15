import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // tu utilises Riverpod
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import 'package:av_wallet_hive/pages/home_page.dart';
import 'package:av_wallet_hive/theme/app_theme.dart';
import 'package:av_wallet_hive/theme/theme_controller.dart';
import 'package:av_wallet_hive/widgets/splash_gate.dart';
// 👉 Si ta page d'accueil est bien à lib/pages/home_page.dart, décommente la ligne suivante :
// import 'package:av_wallet_hive/pages/home_page.dart';

void main() => runApp(const ProviderScope(child: AVWalletApp()));

class AVWalletApp extends ConsumerWidget {
  const AVWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'AV Wallet (recovery)',
      // i18n
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // thèmes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode, // <-- contrôlé par provider (default: dark)
      // splash gate
      home: const SplashGate(),
      debugShowCheckedModeBanner: false,
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
