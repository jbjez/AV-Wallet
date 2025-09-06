import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import '../models/amplifier_spec.dart';
import '../providers/catalogue_provider.dart';

/// Provider pour récupérer une enceinte par sa clé "marque:produit"
final speakerByKeyProvider = Provider.family<CatalogueItem?, String>((ref, key) {
  final items = ref.watch(catalogueProvider)?? <CatalogueItem>[];
  
  // key = "L-Acoustics:K2", "d&b audiotechnik:V8", "NEXO:P12"
  final parts = key.split(':');
  if (parts.length != 2) return null;
  
  final brand = parts[0];
  final model = parts[1];
  
  return items.firstWhere(
    (item) => item.categorie == 'Son' && 
              item.marque == brand && 
              item.produit == model,
    orElse: () => throw Exception('Speaker not found'),
  );
});

/// Provider pour les spécifications d'amplificateurs
final amplifiersProvider = Provider<Map<String, AmplifierSpec>>((ref) {
  // TODO: Remplacer par lecture live (remote JSON/DB)
  // Pour l'instant, données statiques d'exemple
  return {
    // Exemple L-Acoustics LA12X
    'L-Acoustics:LA12X': AmplifierSpec(
      brand: 'L-Acoustics',
      model: 'LA12X',
      minLoadOhms: 2,
      maxParallelPerChannel: 4,
      modes: {
        '4ch': AmpModeSpec(name: '4ch', channels: 4, sharedPSU: true),
        'Bridge': AmpModeSpec(name: 'Bridge', channels: 2, sharedPSU: true),
      },
      power: {
        '4ch': PerChannelPower({2: 2500, 4: 1800, 8: 1000}),
        'Bridge': PerChannelPower({4: 5000, 8: 3600}),
      },
    ),
    
    // Exemple d&b D80
    'd&b audiotechnik:D80': AmplifierSpec(
      brand: 'd&b audiotechnik',
      model: 'D80',
      minLoadOhms: 2,
      maxParallelPerChannel: 4,
      modes: {
        '4ch': AmpModeSpec(name: '4ch', channels: 4, sharedPSU: true),
        'Bridge': AmpModeSpec(name: 'Bridge', channels: 2, sharedPSU: true),
      },
      power: {
        '4ch': PerChannelPower({2: 2000, 4: 1500, 8: 800}),
        'Bridge': PerChannelPower({4: 4000, 8: 3000}),
      },
    ),
    
    // Exemple NEXO NXAMP4X4
    'NEXO:NXAMP4X4': AmplifierSpec(
      brand: 'NEXO',
      model: 'NXAMP4X4',
      minLoadOhms: 2,
      maxParallelPerChannel: 4,
      modes: {
        '4ch': AmpModeSpec(name: '4ch', channels: 4, sharedPSU: true),
        'Bridge': AmpModeSpec(name: 'Bridge', channels: 2, sharedPSU: true),
      },
      power: {
        '4ch': PerChannelPower({2: 1800, 4: 1200, 8: 600}),
        'Bridge': PerChannelPower({4: 3600, 8: 2400}),
      },
    ),
  };
});

/// Provider pour obtenir un amplificateur par sa clé
final amplifierByKeyProvider = Provider.family<AmplifierSpec?, String>((ref, key) {
  final amplifiers = ref.watch(amplifiersProvider);
  return amplifiers[key];
});

/// Provider pour lister toutes les enceintes audio disponibles
final audioSpeakersProvider = Provider<List<CatalogueItem>>((ref) {
  final items = ref.watch(catalogueProvider)?? <CatalogueItem>[];
  return items.where((item) => item.categorie == 'Son').toList();
});

/// Provider pour lister tous les amplificateurs disponibles
final availableAmplifiersProvider = Provider<List<AmplifierSpec>>((ref) {
  final amplifiers = ref.watch(amplifiersProvider);
  return amplifiers.values.toList();
});

/// Provider pour vérifier si une enceinte a ses spécifications audio complètes
final speakerAudioSpecsCompleteProvider = Provider.family<bool, String>((ref, speakerKey) {
  final speaker = ref.watch(speakerByKeyProvider(speakerKey));
  if (speaker == null) return false;
  
  return speaker.impedanceOhms != null && 
         speaker.powerRmsW != null;
});

/// Provider pour obtenir les enceintes avec spécifications audio incomplètes
final speakersWithIncompleteSpecsProvider = Provider<List<CatalogueItem>>((ref) {
  final speakers = ref.watch(audioSpeakersProvider);
  return speakers.where((speaker) {
    final key = '${speaker.marque}:${speaker.produit}';
    return !ref.watch(speakerAudioSpecsCompleteProvider(key));
  }).toList();
});
