// NOTE APP STORE REVIEW:
// Sign in with Apple est disponible sur cette page.
// Compte de test: review@avwallet.app / Test1234

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'email_code_verification_page.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/premium_email_service.dart';
import 'privacy_page.dart';
import 'welcome_gate_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends ConsumerStatefulWidget {
  final bool isDialog;
  
  const SignInPage({
    super.key,
    this.isDialog = false,
  });

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).state = ref.read(authProvider).copyWith(
        error: null,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations loc) {
    if (value == null || value.isEmpty) {
      return loc.email_required;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return loc.invalid_email;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations loc) {
    if (value == null || value.isEmpty) {
      return loc.password_required;
    }
    if (value.length < 6) {
      return loc.password_too_short;
    }
    return null;
  }

  Future<void> _signIn(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          // Mettre à jour l'état remember me
          ref.read(authProvider.notifier).state = ref.read(authProvider).copyWith(
            rememberMe: _rememberMe,
          );
          
          await authService.signIn(
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
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          // Vérifier si l'utilisateur est premium et rediriger vers welcome gate
          print('🔍 SignInPage: Checking premium status for email: ${_emailController.text}');
          final isPremium = await PremiumEmailService.isPremiumEmail(_emailController.text);
          print('🔍 SignInPage: Premium status result: $isPremium');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WelcomeGatePage(
                email: _emailController.text,
                isPremium: isPremium,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Invalid login credentials')) {
          errorMessage = loc.invalid_credentials_error;
        } else if (errorMessage.contains('Email not confirmed') || errorMessage.contains('vérifier votre email')) {
          // Rediriger vers la page de vérification de code
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmailCodeVerificationPage(
                email: _emailController.text,
              ),
            ),
          );
          return; // Ne pas afficher d'erreur
        }
        setState(() {
          _error = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle(AppLocalizations loc) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.signInWithGoogle();
        },
        loading: () async {
          throw Exception(loc.auth_service_loading);
        },
        error: (error, stack) async {
          throw Exception('${loc.auth_service_error}: $error');
        },
      );
      
      if (mounted) {
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          // Pour Google, on laisse le callback gérer la redirection vers welcome gate
          // Pas besoin de redirection ici car le callback s'en charge
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        
        // Afficher une boîte de dialogue avec l'erreur
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              loc.connection_error,
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            backgroundColor: const Color(0xFF0A1128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.ok,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
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
  }

  Future<void> _signInWithApple(AppLocalizations loc) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // TODO: Use correct redirect URL that matches Info.plist URL scheme
    // const kSupabaseRedirectUrl = 'io.supabase.avwallet://login-callback';
    
    try {
      // Obtenir les credentials Apple via le SDK natif
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Vérifier que le token est présent
      if (credential.identityToken == null) {
        throw Exception('Identité Apple non reçue');
      }

      // Authentifier avec Supabase
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.signInWithApple(
            identityToken: credential.identityToken!,
            nonce: null, // Le nonce est optionnel pour Apple
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
        // Navigation explicite vers WelcomeGatePage après connexion réussie
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && session.user.email != null) {
          final email = session.user.email!;
          final isPremium = await PremiumEmailService.isPremiumEmail(email);
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WelcomeGatePage(
                email: email,
                isPremium: isPremium,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback iPad/iOS: passer par le flux OAuth Supabase (ASWebAuthenticationSession)
      try {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: 'io.supabase.avwallet://login-callback/',
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
        // La navigation sera gérée par l'écouteur d'état (DeepLink/WelcomeGate)
        return;
      } catch (_) {
        // On retombe ensuite sur la gestion d'erreur utilisateur ci-dessous
      }
      if (mounted) {
        // Si l'utilisateur annule, ne pas afficher d'erreur
        final errorString = e.toString();
        if (!errorString.contains('The operation couldn') && 
            !errorString.contains('CANCELED') &&
            !errorString.contains('canceled')) {
          
          // Vérifier si c'est une erreur de configuration (audience mismatch)
          final isConfigError = errorString.contains('Unacceptable audience') || 
                               errorString.contains('audience in id_token');
          
          // Afficher un message d'erreur non-bloquant avec une suggestion de fallback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isConfigError 
                ? 'Apple Sign-In configuration error. Please contact support.'
                : 'Apple sign-in is temporarily unavailable. Please try email login.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          setState(() {
            _error = null; // Ne pas afficher l'erreur technique à l'utilisateur
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

  void _openPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPage()),
    );
  }

  void _handleForgotPassword(AppLocalizations loc) async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.enter_email_first),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final authServiceAsync = ref.read(authServiceProvider);
      await authServiceAsync.when(
        data: (authService) async {
          await authService.resetPassword(_emailController.text);
        },
        loading: () async {
          throw Exception(loc.auth_service_loading);
        },
        error: (error, stack) async {
          throw Exception('${loc.auth_service_error}: $error');
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.reset_email_sent,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoginForm(AppLocalizations loc) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.login,
            style: const TextStyle(
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
            validator: (value) => _validateEmail(value, loc),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
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
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            validator: (value) => _validatePassword(value, loc),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _handleForgotPassword(loc),
              child: Text(
                loc.forgot_password,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) async {
                  final authServiceAsync = ref.read(authServiceProvider);
                  await authServiceAsync.when(
                    data: (authService) async {
                      await authService.setRememberMe(value ?? false);
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    loading: () {},
                    error: (error, stack) {},
                  );
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
              Flexible(
                child: Text(
                  loc.remember_me,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A1128),
                padding: const EdgeInsets.symmetric(vertical: 4), // Réduit de 50% (8 → 4)
              ),
              onPressed: _isLoading ? null : () => _signIn(loc),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(
                      loc.sign_in,
                      style: const TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in with :',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Google
              InkWell(
                onTap: _isLoading ? null : () => _signInWithGoogle(loc),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/google_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Bouton Apple
              InkWell(
                onTap: _isLoading ? null : () => _signInWithApple(loc),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apple,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _openPrivacy,
            child: Text(
              loc.privacy_policy_link ?? "Politique de confidentialité",
              style: const TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.privacy_gdpr_text ?? "AV Wallet utilise votre adresse e-mail uniquement pour l'accès à votre compte, "
                "la sauvegarde de vos projets et la génération d'exports techniques. "
                "Aucune donnée personnelle n'est vendue à des tiers.",
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          if (!widget.isDialog) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/sign-up');
              },
              child: Text(
                loc.sign_up,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
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
          
          if (widget.isDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFF0A1128),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildLoginForm(loc),
              ),
            );
          }

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
                        child: _buildLoginForm(loc),
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
