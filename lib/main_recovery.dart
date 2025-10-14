import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // tu utilises Riverpod
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
