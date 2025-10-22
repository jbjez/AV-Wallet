import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/usage_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/premium_vip_dialog.dart';
import 'email_code_verification_page.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/premium_email_service.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _error;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final authState = ref.read(authProvider);
    setState(() {
      _rememberMe = authState.rememberMe;
    });
  }

  void _showPremiumWelcomeDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumVIPDialog(
        email: _emailController.text,
        onContinue: () {
          print('DEBUG: Premium dialog onContinue called, redirecting to verification page');
          // Rediriger vers la page de vérification de code
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EmailCodeVerificationPage(
                email: _emailController.text,
              ),
            ),
          );
          print('DEBUG: Navigation to verification page initiated');
        },
      ),
    );
  }

  String _getUserDisplayName(dynamic user) {
    if (user == null) return '';
    
    // Utiliser directement le displayName de l'AppUser
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    
    // Fallback sur l'email si pas de nom disponible
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      // Extraire la partie avant @ de l'email et la formater
      final emailName = email.split('@').first;
      // Capitaliser la première lettre
      return emailName.isNotEmpty 
          ? emailName[0].toUpperCase() + emailName.substring(1).toLowerCase()
          : emailName;
    }
    
    return '';
  }

  void _showWelcomeDialog(AppLocalizations loc) {
    final usageState = ref.read(usageProvider);
    final authState = ref.read(authProvider);
    final userName = _getUserDisplayName(authState.user);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1128).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo2.png',
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 20),
            Text(
              userName.isNotEmpty 
                ? 'Bienvenue sur AVWallet, $userName'
                : 'Bienvenue sur AVWallet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Vous bénéficiez de l\'utilisation premium.\nIl vous reste ${usageState.remainingUsage} utilisations',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.continueButton,
                  style: TextStyle(
                    color: Color(0xFF0A1128),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(AppLocalizations loc) async {
    print('DEBUG: _signUp function called');
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.signUp(
            email: _emailController.text,
            password: _passwordController.text,
          );
        },
        loading: () async {
          throw Exception(loc.auth_service_loading);
        },
        error: (error, stack) async {
          throw Exception('${loc.auth_service_error}: $error');
        },
      );

      if (mounted) {
        print('DEBUG: Sign up successful, checking premium status');
        // Vérifier si l'email est premium
        print('DEBUG: Checking premium status for email: ${_emailController.text}');
        final isPremium = await PremiumEmailService.isPremiumEmail(_emailController.text);
        print('DEBUG: Is premium: $isPremium');
        
        if (isPremium) {
          print('DEBUG: Showing premium welcome dialog');
          // Afficher le dialog premium
              _showPremiumWelcomeDialog(loc);
        } else {
          print('DEBUG: Showing normal welcome dialog');
          // Afficher le dialog normal
          _showWelcomeDialog(loc);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        
        if (errorMessage.contains(loc.verification_code_sent_message)) {
          // Rediriger vers la page de vérification de code
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EmailCodeVerificationPage(
                email: _emailController.text,
              ),
            ),
          );
        } else {
          setState(() {
            _error = errorMessage;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    
    return Localizations.override(
      context: context,
      locale: currentLocale,
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context)!;
          
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF0A1128),
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: Image.asset(
                'assets/logo2.png',
                height: 40,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const LanguageSelector(),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(11),
                    child: Card(
                      color: const Color(0xFF0A1128).withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.signup,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 17),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: loc.email,
                                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.email_required;
                                  }
                                  if (!value.contains('@')) {
                                    return loc.invalid_email;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 11),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: loc.password,
                                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.password_required;
                                  }
                                  if (value.length < 8) {
                                    return 'Le mot de passe doit contenir au moins 8 caractères';
                                  }
                                  if (!value.contains(RegExp(r'[a-z]'))) {
                                    return 'Le mot de passe doit contenir au moins une lettre minuscule';
                                  }
                                  if (!value.contains(RegExp(r'[A-Z]'))) {
                                    return 'Le mot de passe doit contenir au moins une lettre majuscule';
                                  }
                                  if (!value.contains(RegExp(r'[0-9]'))) {
                                    return 'Le mot de passe doit contenir au moins un chiffre';
                                  }
                                  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                    return 'Le mot de passe doit contenir au moins un caractère spécial';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 11),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: loc.confirm_password,
                                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white70),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.confirm_password_required;
                                  }
                                  if (value != _passwordController.text) {
                                    return loc.passwords_dont_match;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 11),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.white.withOpacity(0.5);
                                      },
                                    ),
                                    checkColor: const Color(0xFF0A1128),
                                  ),
                                  Text(
                                    loc.remember_me,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 11),
                                Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 17),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : () => _signUp(loc),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          loc.sign_up,
                                          style: TextStyle(
                                            color: Color(0xFF0A1128),
                                            fontSize: 11,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 11),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/sign-in');
                                },
                                child: Text(
                                  '${loc.already_have_account} ${loc.sign_in}',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 11),
                              Text(
                                loc.or_continue_with,
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(height: 11),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            final authServiceAsync = ref.read(authServiceProvider);
                                            await authServiceAsync.when(
                                              data: (authService) async {
                                                await authService.signInWithGoogle();
                                                if (mounted) {
                                                  _showWelcomeDialog(loc);
                                                }
                                              },
                                              loading: () async {
                                                throw Exception(loc.auth_service_loading);
                                              },
                                              error: (error, stack) async {
                                                throw Exception('${loc.auth_service_error}: $error');
                                              },
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                _error = e.toString();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        },
                                  icon: Image.asset(
                                    'assets/google_logo.png',
                                    height: 17,
                                  ),
                                  label: Text(
                                    loc.google_sign_in,
                                    style: TextStyle(
                                      color: Color(0xFF0A1128),
                                      fontSize: 11,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}