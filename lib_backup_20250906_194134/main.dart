import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:av_wallet_hive/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:logging/logging.dart';
import 'config/supabase_config.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/catalogue_page.dart';
import 'pages/splash_screen.dart';
import 'pages/debug_auth_page.dart';
import 'pages/debug_son_migration.dart';
import 'services/hive_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';
import 'widgets/auth_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';

final logger = Logger('main');

// Clé globale pour la navigation
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  setupLogging();
  logger.info('Starting application...');

  try {
    // Initialize Supabase with more detailed logging
    logger.info('Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );
    logger.info('Supabase initialized successfully');
    
    // Test Supabase connection
    try {
      final response = await Supabase.instance.client.from('_test').select().limit(1);
      logger.info('Supabase connection test successful');
    } catch (e) {
      logger.warning('Supabase connection test failed: $e');
    }

    // Initialize Hive
    await HiveService.initialize();
    logger.info('Hive initialized successfully');

    // Créer le container de providers
    final container = ProviderContainer();

    // Initialiser l'authentification
    await initializeAuth(container);
    logger.info('Auth initialized successfully');

    // On ne demande plus la permission caméra au démarrage
    // La permission sera demandée uniquement quand nécessaire (dans AR)

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
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AV Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomePage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/catalogue': (context) => const CataloguePage(),
        '/debug-son': (context) => const DebugSonMigrationPage(),
      },
    );
  }
}
