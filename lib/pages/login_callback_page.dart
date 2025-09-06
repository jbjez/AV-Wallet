import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

final logger = Logger('LoginCallbackPage');

class LoginCallbackPage extends StatefulWidget {
  const LoginCallbackPage({Key? key}) : super(key: key);

  @override
  State<LoginCallbackPage> createState() => _LoginCallbackPageState();
}

class _LoginCallbackPageState extends State<LoginCallbackPage> {
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
        logger.info('Login successful, redirecting to home');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
