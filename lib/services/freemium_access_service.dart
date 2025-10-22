import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'secure_usage_service.dart';
import 'usage_check_service.dart';

/// Service de contrôle d'accès basé sur le freemium
class FreemiumAccessService {
  static final Logger _logger = Logger('FreemiumAccessService');
  
  /// Vérifie si l'utilisateur peut accéder au catalogue (premium uniquement)
  static Future<bool> canAccessCatalogue(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final isPremium = await SecureUsageService.instance.isPremium();
      
      if (isPremium) {
        _logger.info('Catalogue access granted - user is premium');
        return true;
      }
      
      _logger.info('Catalogue access denied - user is not premium');
      _showCatalogueAccessDeniedDialog(context);
      return false;
    } catch (e) {
      _logger.severe('Error checking catalogue access: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur peut accéder aux projets/presets (premium uniquement)
  static Future<bool> canAccessProjects(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final isPremium = await SecureUsageService.instance.isPremium();
      
      if (isPremium) {
        _logger.info('Projects access granted - user is premium');
        return true;
      }
      
      _logger.info('Projects access denied - user is not premium');
      _showProjectsAccessDeniedDialog(context);
      return false;
    } catch (e) {
      _logger.severe('Error checking projects access: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur peut exporter (premium uniquement)
  static Future<bool> canExport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final isPremium = await SecureUsageService.instance.isPremium();
      
      if (isPremium) {
        _logger.info('Export access granted - user is premium');
        return true;
      }
      
      _logger.info('Export access denied - user is not premium');
      _showExportAccessDeniedDialog(context);
      return false;
    } catch (e) {
      _logger.severe('Error checking export access: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur peut utiliser les calculs basiques (gratuit)
  static Future<bool> canUseBasicCalculations(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Les calculs basiques sont toujours autorisés
      _logger.info('Basic calculations access granted - always free');
      return true;
    } catch (e) {
      _logger.severe('Error checking basic calculations access: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur peut utiliser une fonctionnalité premium
  static Future<bool> canUsePremiumFeature(
    BuildContext context,
    WidgetRef ref,
    String featureName,
  ) async {
    try {
      return await UsageCheckService.checkAndUseFeature(
        context,
        ref,
        featureName,
      );
    } catch (e) {
      _logger.severe('Error checking premium feature access: $e');
      return false;
    }
  }
  
  /// Affiche le dialog d'accès refusé pour le catalogue
  static void _showCatalogueAccessDeniedDialog(BuildContext context) {
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
            // Icône catalogue
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.blue,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            const Text(
              'Catalogue Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            const Text(
              'L\'accès au catalogue complet est réservé aux utilisateurs Premium. Passez à Premium pour accéder à tous les équipements et fonctionnalités.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Affiche le dialog d'accès refusé pour les projets
  static void _showProjectsAccessDeniedDialog(BuildContext context) {
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
            // Icône projets
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_special,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            const Text(
              'Projets Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            const Text(
              'La gestion des projets et presets est réservée aux utilisateurs Premium. Passez à Premium pour sauvegarder et organiser vos calculs.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Affiche le dialog d'accès refusé pour l'export
  static void _showExportAccessDeniedDialog(BuildContext context) {
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
            // Icône export
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.file_download,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            const Text(
              'Export Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            const Text(
              'L\'export de vos calculs est réservé aux utilisateurs Premium. Passez à Premium pour exporter vos projets en PDF et les partager.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


