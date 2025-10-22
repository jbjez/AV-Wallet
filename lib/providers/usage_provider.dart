import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/usage_service.dart';
import 'package:logging/logging.dart';

/// État des utilisations premium
class UsageState {
  final int remainingUsage;
  final int maxUsage;
  final int usedUsage;
  final bool isLoading;
  final String? error;
  
  const UsageState({
    this.remainingUsage = 5,
    this.maxUsage = 5,
    this.usedUsage = 0,
    this.isLoading = false,
    this.error,
  });
  
  UsageState copyWith({
    int? remainingUsage,
    int? maxUsage,
    int? usedUsage,
    bool? isLoading,
    String? error,
  }) {
    return UsageState(
      remainingUsage: remainingUsage ?? this.remainingUsage,
      maxUsage: maxUsage ?? this.maxUsage,
      usedUsage: usedUsage ?? this.usedUsage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  /// Vérifie si l'utilisateur a encore des utilisations disponibles
  bool get hasUsageRemaining => remainingUsage > 0;
  
  /// Vérifie si l'utilisateur est premium
  bool get isPremium => hasUsageRemaining;
}

/// Notifier pour gérer l'état des utilisations
class UsageNotifier extends StateNotifier<UsageState> {
  final Logger _logger = Logger('UsageNotifier');
  
  UsageNotifier() : super(const UsageState()) {
    _loadUsage();
  }
  
  /// Charge les données d'utilisation depuis le service
  Future<void> _loadUsage() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final remaining = await UsageService.instance.getRemainingUsage();
      final maxUsage = await UsageService.instance.getMaxUsage();
      final usedUsage = await UsageService.instance.getUsedUsage();
      
      state = state.copyWith(
        remainingUsage: remaining,
        maxUsage: maxUsage,
        usedUsage: usedUsage,
        isLoading: false,
      );
      
      _logger.info('Usage loaded: $remaining/$maxUsage remaining');
    } catch (e) {
      _logger.severe('Error loading usage', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Incrémente le compteur d'utilisations
  Future<bool> incrementUsage() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await UsageService.instance.incrementUsage();
      
      if (success) {
        // Recharger les données après incrémentation
        await _loadUsage();
        _logger.info('Usage incremented successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur lors de l\'incrémentation des utilisations',
        );
        return false;
      }
    } catch (e) {
      _logger.severe('Error incrementing usage', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  /// Réinitialise le compteur d'utilisations
  Future<bool> resetUsage() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await UsageService.instance.resetUsage();
      
      if (success) {
        await _loadUsage();
        _logger.info('Usage reset successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur lors de la réinitialisation des utilisations',
        );
        return false;
      }
    } catch (e) {
      _logger.severe('Error resetting usage', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  /// Recharge les données d'utilisation
  Future<void> refreshUsage() async {
    await _loadUsage();
  }
  
  /// Définit le nombre maximum d'utilisations
  Future<bool> setMaxUsage(int maxUsage) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await UsageService.instance.setMaxUsage(maxUsage);
      
      if (success) {
        await _loadUsage();
        _logger.info('Max usage set to: $maxUsage');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur lors de la définition du nombre maximum d\'utilisations',
        );
        return false;
      }
    } catch (e) {
      _logger.severe('Error setting max usage', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider pour l'état des utilisations
final usageProvider = StateNotifierProvider<UsageNotifier, UsageState>((ref) {
  return UsageNotifier();
});

/// Provider pour vérifier si l'utilisateur est premium
final isPremiumProvider = Provider<bool>((ref) {
  final usageState = ref.watch(usageProvider);
  return usageState.isPremium;
});

/// Provider pour le nombre d'utilisations restantes
final remainingUsageProvider = Provider<int>((ref) {
  final usageState = ref.watch(usageProvider);
  return usageState.remainingUsage;
});
