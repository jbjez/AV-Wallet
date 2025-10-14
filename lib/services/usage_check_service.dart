import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usage_provider.dart';
import '../widgets/premium_expired_dialog.dart';
import 'secure_usage_service.dart';
import 'package:logging/logging.dart';

class UsageCheckService {
  static final Logger _logger = Logger('UsageCheckService');
  
  /// Vérifie si l'utilisateur peut accéder à une fonctionnalité
  /// Retourne true si l'accès est autorisé, false sinon
  static Future<bool> checkUsageAccess(
    BuildContext context,
    WidgetRef ref,
    String featureName,
  ) async {
    try {
      // Utiliser SecureUsageService pour la vérification
      final hasUsageRemaining = await SecureUsageService.instance.hasUsageRemaining();
      final remainingUsage = await SecureUsageService.instance.getRemainingUsage();
      
      // Si l'utilisateur a encore des utilisations, autoriser l'accès
      if (hasUsageRemaining) {
        _logger.info('Access granted to $featureName. Remaining: $remainingUsage');
        return true;
      }
      
      // Sinon, afficher la boîte de dialogue d'expiration
      _logger.info('Access denied to $featureName. No remaining usage');
      _showPremiumExpiredDialog(context);
      return false;
    } catch (e) {
      _logger.severe('Error checking usage access for $featureName', e);
      return false;
    }
  }
  
  /// Incrémente l'utilisation et vérifie l'accès
  /// Retourne true si l'action peut être effectuée, false sinon
  static Future<bool> useFeature(
    BuildContext context,
    WidgetRef ref,
    String featureName,
  ) async {
    try {
      final usageNotifier = ref.read(usageProvider.notifier);
      
      // Vérifier d'abord si l'utilisateur a encore des utilisations
      final usageState = ref.read(usageProvider);
      if (!usageState.hasUsageRemaining) {
        _logger.info('Cannot use $featureName. No remaining usage');
        _showPremiumExpiredDialog(context);
        return false;
      }
      
      // Incrémenter l'utilisation
      final success = await usageNotifier.incrementUsage();
      
      if (success) {
        _logger.info('Successfully used $featureName. Usage incremented');
        return true;
      } else {
        _logger.warning('Failed to increment usage for $featureName');
        return false;
      }
    } catch (e) {
      _logger.severe('Error using feature $featureName', e);
      return false;
    }
  }
  
  /// Affiche la boîte de dialogue d'expiration premium
  static void _showPremiumExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PremiumExpiredDialog(),
    );
  }
  
  /// Vérifie l'accès et incrémente l'utilisation en une seule opération
  /// Utilisé pour les actions qui nécessitent à la fois la vérification et l'incrémentation
  static Future<bool> checkAndUseFeature(
    BuildContext context,
    WidgetRef ref,
    String featureName,
  ) async {
    try {
      // Utiliser SecureUsageService pour la vérification
      final hasUsageRemaining = await SecureUsageService.instance.hasUsageRemaining();
      
      if (!hasUsageRemaining) {
        _logger.info('Cannot use $featureName. No remaining usage');
        _showPremiumExpiredDialog(context);
        return false;
      }
      
      // Incrémenter l'utilisation via SecureUsageService
      final success = await SecureUsageService.instance.incrementUsage();
      
      if (success) {
        _logger.info('Successfully checked and used $featureName');
        return true;
      } else {
        _logger.warning('Failed to increment usage for $featureName');
        return false;
      }
    } catch (e) {
      _logger.severe('Error checking and using feature $featureName', e);
      return false;
    }
  }
}
