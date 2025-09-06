import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/translation_service.dart';
import '../widgets/custom_dialog.dart';

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
      ref.read(authStateProvider.notifier).state = ref.read(authStateProvider).copyWith(
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      
      // Mettre à jour l'état remember me
      ref.read(authStateProvider.notifier).state = ref.read(authStateProvider).copyWith(
        rememberMe: _rememberMe,
      );
      
      await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
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
          errorMessage = 'Email ou mot de passe incorrect';
        } else if (errorMessage.contains('Email not confirmed')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomDialog(
              title: 'Email non confirmé',
              message: 'Veuillez confirmer votre email avant de vous connecter. '
                'Vérifiez votre boîte de réception et vos spams.',
              onOkPressed: () => Navigator.of(context).pop(),
            ),
          );
          errorMessage = 'Veuillez confirmer votre email';
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      
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
            title: const Text(
              'Erreur de connexion',
              style: TextStyle(color: Colors.white),
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
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
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

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(_emailController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Un email de réinitialisation a été envoyé. '
              'Vérifiez votre boîte de réception et vos spams.',
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

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 60,
              ),
            ),
          ),
          Text(
            context.t('login'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 11), // Réduit de 3 points (14 → 11)
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            style: const TextStyle(color: Colors.white, fontSize: 11), // Réduit de 3 points (14 → 11)
            validator: _validatePassword,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) async {
                  final authService = ref.read(authServiceProvider);
                  await authService.setRememberMe(value ?? false);
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
              const Text(
                'Se souvenir de moi',
                style: TextStyle(color: Colors.white70),
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
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(
                      context.t('sign_in'),
                      style: const TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ou continuer avec',
            style: TextStyle(
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
                  : const Text(
                      'Google',
                      style: TextStyle(fontSize: 11), // Réduit de 3 points (14 → 11)
                    ),
              onPressed: _isLoading ? null : _signInWithGoogle,
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
              child: const Text(
                'Créer un compte',
                style: TextStyle(color: Colors.white70),
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
    if (widget.isDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF0A1128),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildLoginForm(),
        ),
      );
    }

    return Scaffold(
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
              padding: const EdgeInsets.all(24),
              child: Card(
                color: const Color(0xFF0A1128).withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
