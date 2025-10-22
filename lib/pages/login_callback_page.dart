import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../services/premium_email_service.dart';
import 'welcome_gate_page.dart';

final logger = Logger('LoginCallbackPage');

class LoginCallbackPage extends ConsumerStatefulWidget {
  const LoginCallbackPage({super.key});

  @override
  ConsumerState<LoginCallbackPage> createState() => _LoginCallbackPageState();
}

class _LoginCallbackPageState extends ConsumerState<LoginCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleLoginCallback();
  }

  Future<void> _handleLoginCallback() async {
    try {
      logger.info('Processing login callback...');
      
      // Vérifier immédiatement la session
      final session = Supabase.instance.client.auth.currentSession;
      logger.info('Session after callback: ${session != null}');
      
      if (session != null) {
        logger.info('Login successful, redirecting to welcome gate');
        print('🎉 LOGIN CALLBACK: Redirection vers welcome gate');
        if (mounted) {
          final user = session.user;
          if (user.email != null) {
            // Vérifier si l'utilisateur est premium
            final isPremium = await PremiumEmailService.isPremiumEmail(user.email!);
            print('💎 LOGIN CALLBACK: Is premium: $isPremium');
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WelcomeGatePage(
                  email: user.email!,
                  isPremium: isPremium,
                ),
              ),
            );
          } else {
            // Fallback si pas d'email
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        }
      } else {
        logger.warning('No session found after callback');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
        }
      }
    } catch (e) {
      logger.severe('Error handling login callback: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Connexion en cours...'),
          ],
        ),
      ),
    );
  }
}
