import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_usage_service.dart';
import '../services/secure_usage_service.dart';

class SessionTestPage extends ConsumerStatefulWidget {
  const SessionTestPage({super.key});

  @override
  ConsumerState<SessionTestPage> createState() => _SessionTestPageState();
}

class _SessionTestPageState extends ConsumerState<SessionTestPage> {
  Map<String, dynamic> _sessionInfo = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await SessionUsageService.instance.getSessionInfo();
      setState(() {
        _sessionInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _testPremiumFeature() async {
    try {
      final canUse = await SessionUsageService.instance.canUsePremiumFeature();
      if (canUse) {
        final success = await SessionUsageService.instance.usePremiumFeature();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité premium utilisée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de l\'utilisation de la fonctionnalité'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accès refusé - Limite de session atteinte'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await _loadSessionInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _resetSession() async {
    try {
      await SessionUsageService.instance.resetSession();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session réinitialisée!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadSessionInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _startNewSession() async {
    try {
      await SessionUsageService.instance.startNewSession();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouvelle session démarrée!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadSessionInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Session Usage'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de session
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations de Session',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Peut utiliser premium', 
                              _sessionInfo['can_use_premium']?.toString() ?? 'N/A'),
                          _buildInfoRow('Utilisations session', 
                              _sessionInfo['session_usage']?.toString() ?? '0'),
                          _buildInfoRow('Durée session (h)', 
                              _sessionInfo['session_duration_hours']?.toStringAsFixed(2) ?? '0'),
                          _buildInfoRow('Heures depuis activité', 
                              _sessionInfo['hours_since_activity']?.toStringAsFixed(2) ?? '0'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Boutons de test
                  const Text(
                    'Tests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _testPremiumFeature,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tester Fonctionnalité Premium'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startNewSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Démarrer Nouvelle Session'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Réinitialiser Session'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadSessionInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Actualiser Informations'),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Informations freemium global
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Freemium Global',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<int>(
                            future: SecureUsageService.instance.getRemainingUsage(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return _buildInfoRow('Utilisations restantes', snapshot.data.toString());
                              }
                              return const Text('Chargement...');
                            },
                          ),
                          FutureBuilder<bool>(
                            future: SecureUsageService.instance.isPremium(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return _buildInfoRow('Utilisateur premium', snapshot.data.toString());
                              }
                              return const Text('Chargement...');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


