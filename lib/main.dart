import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:av_wallet/l10n/app_localizations.dart'; // non-synthetic (lib/l10n)
import 'package:av_wallet/theme/app_theme.dart';
import 'package:av_wallet/providers/theme_provider.dart';
import 'package:av_wallet/services/supabase_service.dart';
import 'package:av_wallet/widgets/splash_gate.dart';
import 'package:av_wallet/pages/sign_up_page.dart';
import 'package:av_wallet/pages/sign_in_page.dart';
import 'package:av_wallet/pages/home_page.dart';
import 'package:av_wallet/pages/payment_page.dart';
import 'package:av_wallet/pages/welcome_gate_page.dart';
import 'package:av_wallet/providers/auth_provider.dart';
import 'package:av_wallet/providers/locale_provider.dart';

// Optionnel: si tu as le bootstrap/dev flags
// import 'package:av_wallet/dev/dev_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquer l'app en mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialiser Hive
  await Hive.initFlutter();
  
  // Ouvrir la box pour les PDFs
  await Hive.openBox('pdf_box');
  
  // Initialiser Supabase avant de lancer l'app
  await SB.init();
  
  // Lancer l'app immédiatement avec un splash instantané
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // i18n (non-synthetic)
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale, // Utilise le locale du provider

      // Thème jour : fond blanc, texte gris foncé, éléments sélectionnés rouge cerise
      theme: AppTheme.lightTheme,
      // Thème nuit : fond bleu nuit, texte blanc (par défaut)
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,

      // Navigation conditionnelle selon l'état de connexion
      home: Consumer(
        builder: (context, ref, child) {
          final authServiceAsync = ref.watch(authServiceProvider);
          
          return authServiceAsync.when(
            data: (authService) {
              final authState = ref.watch(authProvider);
              return SplashGate(authState: authState);
            },
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur d\'initialisation: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(authServiceProvider);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      
      // Routes définies
      routes: {
        '/sign-up': (context) => const SignUpPage(),
        '/sign-in': (context) => const SignInPage(),
        '/home': (context) => const HomePage(),
        '/payment': (context) => const PaymentPage(),
        '/welcome-gate': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return WelcomeGatePage(
            email: args?['email'] ?? '',
            isPremium: args?['isPremium'] ?? false,
          );
        },
      },
      
      // Gestion des routes inconnues
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            final authState = ref.read(authProvider);
            return SplashGate(authState: authState);
          },
        );
      },
    );
  }
}
