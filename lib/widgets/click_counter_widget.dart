import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClickCounterWidget extends ConsumerStatefulWidget {
  final Widget child;

  const ClickCounterWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ClickCounterWidget> createState() => _ClickCounterWidgetState();
}

class _ClickCounterWidgetState extends ConsumerState<ClickCounterWidget> {
  static const String _clickCountKey = 'click_count';
  int _clickCount = 0;
  bool _isComplete = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadClickCount();
  }

  Future<void> _loadClickCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _clickCount = prefs.getInt(_clickCountKey) ?? 0;
      _isComplete = _clickCount >= 10;
      _isInitialized = true;
    });
  }

  Future<void> _saveClickCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_clickCountKey, _clickCount);
  }

  void _incrementCounter() {
    if (!_isInitialized || _isComplete) return;

    setState(() {
      _clickCount++;
      _saveClickCount();
      if (_clickCount >= 10) {
        _isComplete = true;
        _showSignUpDialog();
      }
    });
  }

  Future<void> _showSignUpDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService(prefs);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Inscription requise'),
          content: const Text(
              'Pour continuer à utiliser l\'application, veuillez vous inscrire.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('S\'inscrire'),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  await authService.signInWithGoogle();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'inscription: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink(); // Retourne un widget vide pendant le chargement
    }

    return GestureDetector(
      onTap: _incrementCounter,
      child: widget.child,
    );
  }
}
