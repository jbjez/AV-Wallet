import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/secure_usage_service.dart';
import '../services/usage_check_service.dart';
import '../services/device_fingerprint_service.dart';
import '../widgets/premium_expired_dialog.dart';

class FreemiumTestPage extends ConsumerStatefulWidget {
  const FreemiumTestPage({super.key});

  @override
  ConsumerState<FreemiumTestPage> createState() => _FreemiumTestPageState();
}

class _FreemiumTestPageState extends ConsumerState<FreemiumTestPage> {
  Map<String, dynamic>? _debugInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await SecureUsageService.instance.getDebugInfo();
      setState(() {
        _debugInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _testIncrementUsage() async {
    try {
      final success = await SecureUsageService.instance.incrementUsage();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisation incrémentée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadDebugInfo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'incrémenter l\'utilisation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _testUsageCheck() async {
    try {
      final hasAccess = await UsageCheckService.checkAndUseFeature(
        context,
        ref,
        'TEST_FEATURE',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasAccess ? 'Accès autorisé!' : 'Accès refusé'),
          backgroundColor: hasAccess ? Colors.green : Colors.red,
        ),
      );
      
      await _loadDebugInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _resetFreemiumStatus() async {
    try {
      final success = await SecureUsageService.instance.resetUsage();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut freemium réinitialisé!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadDebugInfo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la réinitialisation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _showPremiumDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PremiumExpiredDialog(),
    );
  }

  Future<void> _forceResetFreemium() async {
    try {
      // Réinitialisation forcée complète
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('premium_usage_count');
      await prefs.remove('premium_max_usage');
      await prefs.remove('last_validation_timestamp');
      await prefs.remove('used_devices');
      
      // Réinitialiser le statut de l'appareil
      await DeviceFingerprintService.instance.resetDeviceFreemiumStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réinitialisation forcée réussie!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadDebugInfo();
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
        title: const Text('Test Freemium'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0A1128),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de debug
                  if (_debugInfo != null) ...[
                    _buildDebugSection(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Boutons de test
                  _buildTestButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // Instructions
                  _buildInstructions(),
                ],
              ),
            ),
    );
  }

  Widget _buildDebugSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de Debug',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Informations d'utilisation
          if (_debugInfo?['usage'] != null) ...[
            Text(
              'Utilisations: ${_debugInfo!['usage']['used']}/${_debugInfo!['usage']['max']} (${_debugInfo!['usage']['remaining']} restantes)',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
          ],
          
          // Statut freemium
          if (_debugInfo?['freemium_status'] != null) ...[
            Text(
              'Freemium utilisé: ${_debugInfo!['freemium_status']['has_used_freemium'] ? 'Oui' : 'Non'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Peut utiliser freemium: ${_debugInfo!['freemium_status']['can_use_freemium'] ? 'Oui' : 'Non'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
          ],
          
          // Informations utilisateur
          if (_debugInfo?['user'] != null) ...[
            Text(
              'Authentifié: ${_debugInfo!['user']['is_authenticated'] ? 'Oui' : 'Non'}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (_debugInfo!['user']['user_id'] != null)
              Text(
                'User ID: ${_debugInfo!['user']['user_id'].toString().substring(0, 8)}...',
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 8),
          ],
          
          // Informations appareil
          if (_debugInfo?['device_info'] != null) ...[
            Text(
              'Plateforme: ${_debugInfo!['device_info']['platform'] ?? 'Inconnue'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Modèle: ${_debugInfo!['device_info']['model'] ?? 'Inconnu'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Device ID: ${_debugInfo!['device_info']['deviceId']?.toString().substring(0, 8) ?? 'Inconnu'}...',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Bouton d'incrémentation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _testIncrementUsage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Incrémenter Utilisation'),
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton de test de vérification
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _testUsageCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Tester Vérification d\'Accès'),
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton de réinitialisation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _resetFreemiumStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Réinitialiser Freemium'),
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton de réinitialisation forcée
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _forceResetFreemium,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Réinitialisation Forcée'),
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton de test du dialog
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showPremiumDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Tester Dialog Premium'),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions de Test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. Incrémentez les utilisations jusqu\'à 5 pour tester l\'expiration\n'
            '2. Testez la vérification d\'accès pour voir le comportement\n'
            '3. Réinitialisez pour recommencer les tests\n'
            '4. Le dialog premium s\'affiche automatiquement à la 5ème utilisation',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
