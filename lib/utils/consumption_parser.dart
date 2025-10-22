/// Utilitaire pour parser les valeurs de consommation et de poids
/// Gère les formats complexes comme "950 W (HP) / 870 W (Std)"
class ConsumptionParser {
  /// Parse une valeur de consommation en watts
  /// Gère les formats :
  /// - "950 W"
  /// - "950 W (HP) / 870 W (Std)" -> prend la première valeur
  /// - "800 W (Max)" -> prend la valeur principale
  /// - "2500 W (ballast)" -> prend la valeur principale
  static double parseConsumption(String conso) {
    if (conso.isEmpty) return 0.0;
    
    // Nettoyer la chaîne
    String cleaned = conso.trim();
    
    // Chercher le premier nombre suivi de "W"
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*W');
    final match = regex.firstMatch(cleaned);
    
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    
    // Fallback : essayer de parser directement
    return double.tryParse(cleaned.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
  
  /// Parse une valeur de poids en kg
  /// Gère les formats :
  /// - "28.2 kg"
  /// - "47.5 kg"
  static double parseWeight(String poids) {
    if (poids.isEmpty) return 0.0;
    
    // Nettoyer la chaîne
    String cleaned = poids.trim();
    
    // Chercher le premier nombre suivi de "kg"
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*kg');
    final match = regex.firstMatch(cleaned);
    
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    
    // Fallback : essayer de parser directement
    return double.tryParse(cleaned.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
  
  /// Parse une valeur de consommation en watts avec gestion des formats complexes
  /// Pour les formats comme "950 W (HP) / 870 W (Std)", retourne la valeur la plus élevée
  static double parseConsumptionMax(String conso) {
    if (conso.isEmpty) return 0.0;
    
    // Nettoyer la chaîne
    String cleaned = conso.trim();
    
    // Chercher tous les nombres suivis de "W"
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*W');
    final matches = regex.allMatches(cleaned);
    
    if (matches.isEmpty) {
      // Fallback : essayer de parser directement
      return double.tryParse(cleaned.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    
    // Retourner la valeur maximale trouvée
    double maxValue = 0.0;
    for (final match in matches) {
      final value = double.tryParse(match.group(1)!) ?? 0.0;
      if (value > maxValue) {
        maxValue = value;
      }
    }
    
    return maxValue;
  }
}
