import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;
  
  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isResending = false;
  bool _isChecking = false;
  String? _error;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        title: const Text(
          'Vérification Email',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icône d'email
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 40,
                color: Colors.blue,
              ),
            ),
            
            // Titre
            const Text(
              'Vérifiez votre email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Message principal
            Text(
              'Nous avons envoyé un email de confirmation à :',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.email,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Instructions :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Ouvrez votre boîte de réception\n'
                    '2. Cherchez l\'email de AV Wallet\n'
                    '3. Cliquez sur le lien de confirmation\n'
                    '4. Revenez à l\'application',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Message d'erreur ou de succès
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Bouton renvoyer email
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isResending ? null : _resendEmail,
                icon: _isResending 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isResending ? 'Envoi en cours...' : 'Renvoyer l\'email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton vérifier maintenant
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkVerification,
                icon: _isChecking 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isChecking ? 'Vérification...' : 'J\'ai vérifié mon email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lien retour à la connexion
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Retour à la connexion',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.resendConfirmationEmail(widget.email);
        },
        loading: () {},
        error: (error, stack) {
          throw error;
        },
      );

      setState(() {
        _successMessage = 'Email de confirmation renvoyé avec succès !';
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'envoi de l\'email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          final isConfirmed = await authService.checkEmailConfirmation(widget.email);
          if (isConfirmed) {
            setState(() {
              _successMessage = 'Email vérifié avec succès ! Vous pouvez maintenant vous connecter.';
            });
            
            // Attendre un peu avant de rediriger
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            setState(() {
              _error = 'L\'email n\'a pas encore été vérifié. Vérifiez votre boîte de réception.';
            });
          }
        },
        loading: () {},
        error: (error, stack) {
          throw error;
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la vérification: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }
}


