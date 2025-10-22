import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/uniform_bottom_nav_bar.dart';

class UnityMeasurePage extends StatefulWidget {
  const UnityMeasurePage({super.key});
  @override
  State<UnityMeasurePage> createState() => _UnityMeasurePageState();
}

class _UnityMeasurePageState extends State<UnityMeasurePage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.straighten,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône Unity
              const Icon(
                Icons.straighten,
                size: 100,
                color: Colors.white54,
              ),
              
              const SizedBox(height: 32),
              
              // Message de développement
              const Text(
                'Unity AR Measure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'En cours de développement...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Bouton temporaire
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unity sera intégré prochainement'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Information'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Instructions
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cette fonctionnalité Unity sera intégrée\n'
                  'une fois que l\'architecture sera stabilisée.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 0),
    );
  }
}