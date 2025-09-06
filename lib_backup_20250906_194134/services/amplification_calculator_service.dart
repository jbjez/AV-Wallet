import '../models/catalogue_item.dart';
import '../models/amplifier_spec.dart';

/// Requête de calcul d'amplification
class AmplificationRequest {
  final String speakerKey;           // "L-Acoustics:K2"
  final int speakerCount;           // Nombre d'enceintes
  final String amplifierKey;        // "L-Acoustics:LA12X"
  final String amplifierMode;       // "4ch", "Bridge"
  final int parallelChannels;       // Nombre de canaux en parallèle par enceinte
  final double safetyMargin;        // Marge de sécurité (ex: 1.5 = 50% de marge)

  const AmplificationRequest({
    required this.speakerKey,
    required this.speakerCount,
    required this.amplifierKey,
    required this.amplifierMode,
    required this.parallelChannels,
    this.safetyMargin = 1.5,
  });
}

/// Résultat de calcul d'amplification
class AmplificationResult {
  final bool isValid;
  final String? errorMessage;
  final int amplifiersNeeded;
  final double powerPerChannel;
  final double totalPowerRequired;
  final double totalPowerAvailable;
  final double powerUtilization;    // Pourcentage d'utilisation
  final bool isWithinLimits;
  final List<String> warnings;

  const AmplificationResult({
    required this.isValid,
    this.errorMessage,
    required this.amplifiersNeeded,
    required this.powerPerChannel,
    required this.totalPowerRequired,
    required this.totalPowerAvailable,
    required this.powerUtilization,
    required this.isWithinLimits,
    required this.warnings,
  });

  /// Résultat d'erreur
  factory AmplificationResult.error(String message) {
    return AmplificationResult(
      isValid: false,
      errorMessage: message,
      amplifiersNeeded: 0,
      powerPerChannel: 0,
      totalPowerRequired: 0,
      totalPowerAvailable: 0,
      powerUtilization: 0,
      isWithinLimits: false,
      warnings: [],
    );
  }
}

/// Service de calcul d'amplification
class AmplificationCalculatorService {
  /// Calcule les besoins en amplification
  static AmplificationResult calculate(
    AmplificationRequest request,
    CatalogueItem? speaker,
    AmplifierSpec? amplifier,
  ) {
    // Vérifications de base
    if (speaker == null) {
      return AmplificationResult.error('Enceinte non trouvée');
    }
    
    if (amplifier == null) {
      return AmplificationResult.error('Amplificateur non trouvé');
    }

    if (speaker.impedanceOhms == null) {
      return AmplificationResult.error('Impedance de l\'enceinte non définie');
    }

    if (speaker.powerRmsW == null) {
      return AmplificationResult.error('Puissance RMS de l\'enceinte non définie');
    }

    // Vérifier que l'amplificateur peut gérer l'impédance
    if (!amplifier.canHandleImpedance(speaker.impedanceOhms!)) {
      return AmplificationResult.error(
        'L\'amplificateur ne peut pas gérer une impédance de ${speaker.impedanceOhms}Ω'
      );
    }

    // Vérifier le mode d'amplificateur
    if (!amplifier.modes.containsKey(request.amplifierMode)) {
      return AmplificationResult.error(
        'Mode d\'amplificateur "${request.amplifierMode}" non supporté'
      );
    }

    // Vérifier le nombre de canaux en parallèle
    if (!amplifier.canHandleParallelChannels(request.parallelChannels)) {
      return AmplificationResult.error(
        'Trop de canaux en parallèle (max: ${amplifier.maxParallelPerChannel})'
      );
    }

    // Obtenir la puissance disponible par canal
    final powerPerChannel = amplifier.getPowerForModeAndImpedance(
      request.amplifierMode, 
      speaker.impedanceOhms!
    );

    if (powerPerChannel == null) {
      return AmplificationResult.error(
        'Puissance non disponible pour ${speaker.impedanceOhms}Ω en mode ${request.amplifierMode}'
      );
    }

    // Calculer la puissance requise par enceinte (avec marge de sécurité)
    final powerRequiredPerSpeaker = speaker.powerRmsW! * request.safetyMargin;

    // Calculer le nombre d'amplificateurs nécessaires
    final speakersPerAmplifier = (powerPerChannel / powerRequiredPerSpeaker).floor();
    final amplifiersNeeded = (request.speakerCount / speakersPerAmplifier).ceil();

    // Calculer les puissances totales
    final totalPowerRequired = request.speakerCount * powerRequiredPerSpeaker;
    final totalPowerAvailable = amplifiersNeeded * powerPerChannel;
    final powerUtilization = (totalPowerRequired / totalPowerAvailable) * 100;

    // Générer les avertissements
    final warnings = <String>[];
    
    if (powerUtilization > 90) {
      warnings.add('Utilisation de puissance élevée (${powerUtilization.toStringAsFixed(1)}%)');
    }
    
    if (speaker.powerProgramW != null && powerRequiredPerSpeaker > speaker.powerProgramW!) {
      warnings.add('Puissance requise supérieure à la puissance program');
    }
    
    if (speaker.powerPeakW != null && powerRequiredPerSpeaker > speaker.powerPeakW!) {
      warnings.add('Puissance requise supérieure à la puissance peak');
    }

    // Vérifier si c'est dans les limites
    final isWithinLimits = powerUtilization <= 100 && warnings.isEmpty;

    return AmplificationResult(
      isValid: true,
      amplifiersNeeded: amplifiersNeeded,
      powerPerChannel: powerPerChannel.toDouble(),
      totalPowerRequired: totalPowerRequired,
      totalPowerAvailable: totalPowerAvailable.toDouble(),
      powerUtilization: powerUtilization,
      isWithinLimits: isWithinLimits,
      warnings: warnings,
    );
  }

  /// Calcule la puissance optimale pour une configuration donnée
  static double calculateOptimalPower(
    int speakerCount,
    int impedanceOhms,
    double safetyMargin,
  ) {
    // Formule simplifiée : P = V²/R
    // On assume une tension de 70V pour les calculs
    const double nominalVoltage = 70.0;
    return (nominalVoltage * nominalVoltage) / impedanceOhms * safetyMargin;
  }

  /// Vérifie la compatibilité entre une enceinte et un amplificateur
  static bool areCompatible(CatalogueItem speaker, AmplifierSpec amplifier) {
    if (speaker.impedanceOhms == null) return false;
    
    return amplifier.canHandleImpedance(speaker.impedanceOhms!) &&
           speaker.categorie == 'Son';
  }

  /// Obtient les modes d'amplificateur compatibles avec une enceinte
  static List<String> getCompatibleModes(
    CatalogueItem speaker, 
    AmplifierSpec amplifier
  ) {
    if (!areCompatible(speaker, amplifier)) return [];
    
    return amplifier.modes.keys.toList();
  }
}
