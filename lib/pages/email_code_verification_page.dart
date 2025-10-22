import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/premium_email_service.dart';
import '../services/translation_service.dart';
import 'welcome_gate_page.dart';

class EmailCodeVerificationPage extends ConsumerStatefulWidget {
  final String email;
  
  const EmailCodeVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailCodeVerificationPage> createState() => _EmailCodeVerificationPageState();
}

class _EmailCodeVerificationPageState extends ConsumerState<EmailCodeVerificationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _error;
  String? _successMessage;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 secondes
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider.notifier);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          translationService.t('verification_code'),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icône de code
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              
              // Titre
              const Text(
                'Entrez le code de vérification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Message principal
              Text(
                'Nous avons envoyé un code à 6 chiffres à :',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Champ de saisie du code
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: Colors.white30,
                    fontSize: 18,
                    letterSpacing: 8,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code';
                  }
                  if (value.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Le code ne doit contenir que des chiffres';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
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
              
              // Bouton vérifier
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVerifying
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Vérification...', style: TextStyle(fontSize: 10)),
                          ],
                        )
                      : const Text(
                          'Vérifier le code',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bouton renvoyer le code
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resendCountdown > 0 || _isResending ? null : _resendCode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResending
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Envoi en cours...', style: TextStyle(fontSize: 10)),
                          ],
                        )
                      : Text(
                          _resendCountdown > 0 
                              ? 'Renvoyer le code (${_resendCountdown}s)'
                              : 'Renvoyer le code',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Vérifiez votre boîte de réception\n'
                      '• Cherchez l\'email de AV Wallet\n'
                      '• Entrez le code à 6 chiffres\n'
                      '• Le code expire dans 10 minutes',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lien retour à la connexion
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Retour à la connexion',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.verifyEmailCode(widget.email, _codeController.text);
        },
        loading: () {},
        error: (error, stack) {
          throw error;
        },
      );

      setState(() {
        _successMessage = 'Email vérifié avec succès !';
      });

      // Vérifier si l'email est VIP après vérification réussie
      print('DEBUG: Email verification successful, checking VIP status for: ${widget.email}');
      final isPremium = await PremiumEmailService.isPremiumEmail(widget.email);
      print('DEBUG: Is premium after verification: $isPremium');
      
      if (mounted) {
        if (isPremium) {
          print('DEBUG: Redirecting to welcome gate for premium user');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WelcomeGatePage(
                email: widget.email,
                isPremium: true,
              ),
            ),
          );
        } else {
          print('DEBUG: Redirecting to welcome gate for standard user');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WelcomeGatePage(
                email: widget.email,
                isPremium: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendCode() async {
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
        _successMessage = 'Code de vérification renvoyé !';
      });

      _startResendCountdown();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'envoi du code: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
