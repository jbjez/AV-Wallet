import 'dart:async';
import 'package:flutter/material.dart';
import 'package:av_wallet/services/supabase_service.dart';
import 'package:av_wallet/theme/app_theme.dart';
import 'package:av_wallet/pages/home_page.dart';
import 'package:av_wallet/pages/sign_up_page.dart';

class SplashAuthGate extends StatefulWidget {
  const SplashAuthGate({super.key});
  @override
  State<SplashAuthGate> createState() => _SplashAuthGateState();
}

class _SplashAuthGateState extends State<SplashAuthGate> {
  late final StreamSubscription _sub;
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    _sub = SB.authState().listen((_) => _route());
    Future.microtask(_route);
  }

  Future<void> _route() async {
    if (!mounted || _routed) return;
    await Future.delayed(const Duration(milliseconds: 600));
    final isLogged = SB.session != null;
    _routed = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => isLogged ? const HomePage() : const SignUpPage()),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  Image.asset('assets/logo3.png', width: 140, height: 140),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
