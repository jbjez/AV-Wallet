import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet_hive/theme/app_theme.dart';
import 'package:av_wallet_hive/theme/theme_controller.dart';

// OPTIONNEL: dev flags si déjà présents
// import 'package:av_wallet_hive/config/dev_flags.dart';

// -- Déclare des signatures faibles (références tardives) pour pages existantes --
// Adapter si les chemins diffèrent dans ton projet.
import 'package:av_wallet_hive/pages/home_page.dart';
import 'package:av_wallet_hive/pages/sign_up_page.dart';
// Si tu as login_page.dart, tu peux l'importer aussi

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});
  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  @override
  void initState() {
    super.initState();
    // petit délai pour afficher le splash puis router
    Timer(const Duration(milliseconds: 900), _routeNext);
  }

  Future<bool> _isAuthenticated() async {
    // 1) Si tu as un provider d'auth, essaie de le lire
    // try { final user = ref.read(authProvider); return user != null; } catch (_) {}
    // 2) Si tu as mis des dev flags : kDevBypassAuth → true en DEV
    // try { if (kDevMode && kDevBypassAuth) return true; } catch (_) {}
    // 3) Fallback: pas authentifié
    return false;
  }

  void _routeNext() async {
    final ok = await _isAuthenticated();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // S'il existe LoginPage, enchaîne vers Login; sinon Register
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo2.png', width: 140, height: 140),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
