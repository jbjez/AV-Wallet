import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_auth_service.dart';

class BiometricSettingsPage extends ConsumerStatefulWidget {
  const BiometricSettingsPage({super.key});

  @override
  ConsumerState<BiometricSettingsPage> createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends ConsumerState<BiometricSettingsPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final _logger = Logger('BiometricSettingsPage');
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  String _biometricMethodName = 'Authentification biométrique';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    
    if (userId != null) {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final isEnabled = await _biometricService.isBiometricEnabled(userId);
      final methodName = await _biometricService.getBiometricMethodName();
      
      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _biometricMethodName = methodName;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        title: const Text(
          'Auth. Biométrique',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  if (_isBiometricAvailable) _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildInstructionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isBiometricAvailable ? Icons.fingerprint : Icons.fingerprint_outlined,
                  color: _isBiometricAvailable ? Colors.blue : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _biometricMethodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isBiometricAvailable
                  ? 'Utilisez $_biometricMethodName pour vous connecter rapidement et en toute sécurité à votre compte.'
                  : 'L\'auth. biométrique n\'est pas disponible sur cet appareil. Vérifiez que Face ID/Touch ID est configuré dans les paramètres système.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (!_isBiometricAvailable) {
      return Card(
        color: Colors.red.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Non disponible',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: _isBiometricEnabled 
          ? Colors.green.withValues(alpha: 0.1) 
          : Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isBiometricEnabled ? Icons.check_circle : Icons.warning,
              color: _isBiometricEnabled ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isBiometricEnabled ? 'Activé' : 'Non activé',
                    style: TextStyle(
                      color: _isBiometricEnabled ? Colors.green : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isBiometricEnabled 
                        ? 'Vous pouvez utiliser $_biometricMethodName pour vous connecter'
                        : 'Activez $_biometricMethodName pour une connexion rapide et sécurisée',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_isBiometricEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enableBiometric,
              icon: const Icon(Icons.fingerprint),
              label: Text('Activer $_biometricMethodName'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testBiometric,
              icon: const Icon(Icons.fingerprint),
              label: Text('Tester $_biometricMethodName'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _disableBiometric,
              icon: const Icon(Icons.block),
              label: Text('Désactiver $_biometricMethodName'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Comment ça marche',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isBiometricAvailable
                  ? '• Activez $_biometricMethodName dans les paramètres de votre appareil\n'
                    '• Utilisez $_biometricMethodName pour vous connecter rapidement\n'
                    '• Vos données biométriques restent sur votre appareil\n'
                    '• Vous pouvez toujours utiliser votre mot de passe'
                  : '• Vérifiez que $_biometricMethodName est configuré sur votre appareil\n'
                    '• Assurez-vous que les permissions sont accordées\n'
                    '• Redémarrez l\'application si nécessaire',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enableBiometric() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    
    if (userId == null) {
      _showErrorDialog('Utilisateur non connecté');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Vérifier d'abord si la biométrie est disponible
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _showErrorDialog('L\'authentification biométrique n\'est pas disponible sur cet appareil. Vérifiez les paramètres système.');
        return;
      }

      final success = await _biometricService.enableBiometricAuth(userId);
      if (success) {
        await _checkBiometricStatus();
        _showSuccessDialog('$_biometricMethodName activé avec succès !');
      } else {
        _showErrorDialog('Échec de l\'activation de $_biometricMethodName. Vérifiez que Face ID/Touch ID est configuré dans les paramètres système.');
      }
    } catch (e) {
      _logger.severe('Error enabling biometric: $e');
      _showErrorDialog('Erreur lors de l\'activation: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBiometric() async {
    try {
      final success = await _biometricService.authenticateWithBiometrics(
        reason: 'Testez $_biometricMethodName',
      );
      
      if (success) {
        _showSuccessDialog('Test réussi ! $_biometricMethodName fonctionne correctement.');
      } else {
        _showErrorDialog('Test échoué. Vérifiez votre configuration.');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du test: $e');
    }
  }

  Future<void> _disableBiometric() async {
    final confirmed = await _showConfirmDialog(
      'Désactiver $_biometricMethodName',
      'Êtes-vous sûr de vouloir désactiver $_biometricMethodName ?',
    );
    
    if (confirmed == true) {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId != null) {
        setState(() => _isLoading = true);
        
        try {
          final success = await _biometricService.disableBiometricAuth(userId);
          if (success) {
            await _checkBiometricStatus();
            _showSuccessDialog('$_biometricMethodName désactivé avec succès !');
          } else {
            _showErrorDialog('Erreur lors de la désactivation');
          }
        } catch (e) {
          _showErrorDialog('Erreur: $e');
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Succès', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Erreur', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
