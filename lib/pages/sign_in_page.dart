import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'email_code_verification_page.dart';
import 'welcome_gate_page.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/premium_email_service.dart';

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
          final isPremium = await PremiumEmailService.isPremiumEmail(_emailController.text);
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
            loc.or_continue_with,
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
                      loc.google_sign_in,
                      style: const TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
              onPressed: _isLoading ? null : () => _signInWithGoogle(loc),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 4), // Réduit de 50% (8 → 4)
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
