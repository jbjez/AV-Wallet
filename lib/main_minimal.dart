import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:av_wallet_hive/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:url_strategy/url_strategy.dart';
import 'config/supabase_config.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/catalogue_page.dart';
import 'pages/debug_son_migration.dart';
import 'pages/light_menu_page.dart';
import 'pages/structure_menu_page.dart';
import 'pages/sound_menu_page.dart';
import 'pages/video_menu_page.dart';
import 'pages/electricite_menu_page.dart';
import 'pages/divers_menu_page.dart';
import 'pages/settings_page.dart';
import 'pages/calcul_projet_page.dart';
import 'pages/payment_page.dart';
import 'pages/freemium_test_page.dart';
import 'pages/project_selection_page.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';

final logger = Logger('main');

// Clé globale pour la navigation
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  setupLogging();
  logger.info('Starting application...');

  // Configure URL strategy for deep links
  setPathUrlStrategy();

  try {
    // Initialize Supabase with more detailed logging
    logger.info('Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    logger.info('Supabase initialized successfully');
    
    logger.info('All services initialized successfully');

    // Créer le container de providers
    final container = ProviderContainer();

    // Auth is handled by AuthWrapper
    logger.info('Auth will be handled by AuthWrapper');

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(navigatorKey: navigatorKey),
      ),
    );
  } catch (e, stackTrace) {
    logger.severe('Error during initialization', e, stackTrace);
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AV Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('es'),
        Locale('de'),
        Locale('it'),
      ],
      home: const SignUpPage(), // Aller directement à la page de connexion
      routes: {
        '/home': (context) => const HomePage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/catalogue': (context) => const CataloguePage(),
        '/light-menu': (context) => const LightMenuPage(),
        '/structure-menu': (context) => const StructureMenuPage(),
        '/sound-menu': (context) => const SoundMenuPage(),
        '/video-menu': (context) => const VideoMenuPage(),
        '/electricity-menu': (context) => const ElectriciteMenuPage(),
        '/divers-menu': (context) => const DiversMenuPage(),
        '/settings': (context) => const SettingsPage(),
        '/debug-son': (context) => const DebugSonMigrationPage(),
        '/calcul-projet': (context) => const CalculProjetPage(),
        '/payment': (context) => const PaymentPage(),
        '/freemium-test': (context) => const FreemiumTestPage(),
        '/project-selection': (context) => const ProjectSelectionPage(),
      },
    );
  }
}
