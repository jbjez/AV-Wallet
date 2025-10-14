import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/translation_service.dart';
import '../widgets/custom_dialog.dart';
import '../services/biometric_auth_service.dart';
import 'email_code_verification_page.dart';
import '../widgets/language_selector.dart';

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
  final BiometricAuthService _biometricService = BiometricAuthService();

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

  String? _validateEmail(String? value, TranslationService translationService) {
    if (value == null || value.isEmpty) {
      return translationService.t('email_required');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return translationService.t('invalid_email');
    }
    return null;
  }

  String? _validatePassword(String? value, TranslationService translationService) {
    if (value == null || value.isEmpty) {
      return translationService.t('password_required');
    }
    if (value.length < 6) {
      return translationService.t('password_too_short');
    }
    return null;
  }

  Future<void> _signIn(TranslationService translationService) async {
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
          throw Exception(translationService.t('auth_service_loading'));
        },
        error: (error, stack) async {
          throw Exception('${translationService.t('auth_service_error')}: $error');
        },
      );
      
      if (mounted) {
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Invalid login credentials')) {
          errorMessage = translationService.t('invalid_credentials_error');
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

  Future<void> _signInWithGoogle(TranslationService translationService) async {
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
          throw Exception(translationService.t('auth_service_loading'));
        },
        error: (error, stack) async {
          throw Exception('${translationService.t('auth_service_error')}: $error');
        },
      );
      
      if (mounted) {
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
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
              translationService.t('connection_error'),
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
                  translationService.t('ok'),
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

  void _handleForgotPassword(TranslationService translationService) async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translationService.t('enter_email_first')),
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
          throw Exception(translationService.t('auth_service_loading'));
        },
        error: (error, stack) async {
          throw Exception('${translationService.t('auth_service_error')}: $error');
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              translationService.t('reset_email_sent'),
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

  Widget _buildLoginForm(TranslationService translationService) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translationService.t('login'),
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
              labelText: translationService.t('email'),
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
            validator: (value) => _validateEmail(value, translationService),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: translationService.t('password'),
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
            validator: (value) => _validatePassword(value, translationService),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _handleForgotPassword(translationService),
              child: Text(
                translationService.t('forgot_password'),
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
                  translationService.t('remember_me'),
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
              onPressed: _isLoading ? null : () => _signIn(translationService),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(
                      translationService.t('sign_in'),
                      style: const TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translationService.t('or_continue_with'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
              ),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      translationService.t('google_sign_in'),
                      style: const TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
              onPressed: _isLoading ? null : () => _signInWithGoogle(translationService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 4), // Réduit de 50% (8 → 4)
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.face),
              label: Text(
                translationService.t('biometric_auth'),
                style: const TextStyle(fontSize: 11),
              ),
              onPressed: _isLoading ? null : _signInWithBiometric,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
          if (!widget.isDialog) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/sign-up');
              },
              child: Text(
                translationService.t('sign_up'),
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

  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId == null) {
        setState(() {
          _error = 'Utilisateur non connecté';
        });
        return;
      }

      // Vérifier si la biométrie est activée
      final isEnabled = await _biometricService.isBiometricEnabled(userId);
      if (!isEnabled) {
        setState(() {
          _error = 'Authentification biométrique non activée';
        });
        return;
      }

      // Authentifier avec la biométrie
      final success = await _biometricService.authenticateWithBiometrics(
        reason: 'Connectez-vous à votre compte',
      );
      
      if (success) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _error = 'Authentification biométrique échouée';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors de l\'authentification biométrique: $e';
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

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider.notifier);
    ref.watch(translationServiceProvider); // Force la reconstruction quand la langue change
    
    if (widget.isDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF0A1128),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildLoginForm(translationService),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/Logo2.png',
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
                  child: _buildLoginForm(translationService),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
