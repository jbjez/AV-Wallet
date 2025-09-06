import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_dialog.dart';

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
    final authState = ref.read(authStateProvider);
    setState(() {
      _rememberMe = authState.rememberMe;
    });
  }

  void _showWelcomeDialog() {
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
              'assets/logo.png',
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenu sur AVWallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Votre compte a été créé avec succès !',
              style: TextStyle(
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
                child: const Text(
                  'Continuer',
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        _showWelcomeDialog();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        
        if (errorMessage.contains('Un email de confirmation a été envoyé')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomDialog(
              title: 'Confirmation requise',
              message: errorMessage,
              onOkPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/sign-in');
              },
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
                        const Text(
                          'Inscription',
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
                            labelText: 'Email',
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
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 11),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
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
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 11),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
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
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
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
                            const Text(
                              'Se souvenir de moi',
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
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'S\'inscrire',
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
                          child: const Text(
                            'Déjà un compte ? Se connecter',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 11),
                        const Text(
                          'Ou',
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
                                      final authService = ref.read(authServiceProvider);
                                      await authService.signInWithGoogle();
                                      if (mounted) {
                                        _showWelcomeDialog();
                                      }
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
                            label: const Text(
                              'Se connecter avec Google',
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
  }
}
