import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:av_wallet_hive/l10n/app_localizations.dart'; // non-synthetic (lib/l10n)
import 'package:av_wallet_hive/theme/app_theme.dart';
import 'package:av_wallet_hive/theme/theme_controller.dart';
import 'package:av_wallet_hive/widgets/splash_gate.dart';

// Optionnel: si tu as le bootstrap/dev flags
// import 'package:av_wallet_hive/dev/dev_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Si withDevGuards existe, garde-le ; sinon, runApp direct
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  // Avec dev guards :
  // runApp(ProviderScope(child: withDevGuards(const MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider); // default: ThemeMode.dark
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // i18n (non-synthetic)
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // thèmes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,

      // splash -> route vers home ou login/register
      home: const SplashGate(),
    );
  }
}