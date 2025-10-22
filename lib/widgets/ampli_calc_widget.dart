import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/amplification_providers.dart';
import '../services/amplification_calculator_service.dart';

class AmplificationCalculator extends ConsumerStatefulWidget {
  const AmplificationCalculator({super.key});

  @override
  ConsumerState<AmplificationCalculator> createState() =>
      _AmplificationCalculatorState();
}

class _AmplificationCalculatorState extends ConsumerState<AmplificationCalculator> {
  final Map<String, int> selectedEnceintes = {};
  final Map<String, TextEditingController> controllers = {};
  
  String? selectedSpeakerKey;
  String? selectedAmplifierKey;
  String selectedMode = '4ch';
  int parallelChannels = 1;
  double safetyMargin = 1.5;

  void _calculateAmplification() {
    if (selectedSpeakerKey == null || selectedAmplifierKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une enceinte et un amplificateur')),
      );
      return;
    }

    final speaker = ref.read(speakerByKeyProvider(selectedSpeakerKey!));
    final amplifier = ref.read(amplifierByKeyProvider(selectedAmplifierKey!));

    if (speaker == null || amplifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données non trouvées')),
      );
      return;
    }

    // Calculer le nombre total d'enceintes
    int totalSpeakers = 0;
    for (var entry in controllers.entries) {
      final value = int.tryParse(entry.value.text);
      if (value != null && value > 0) {
        totalSpeakers += value;
      }
    }

    if (totalSpeakers == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir au moins une enceinte')),
      );
      return;
    }

    final request = AmplificationRequest(
      speakerKey: selectedSpeakerKey!,
      speakerCount: totalSpeakers,
      amplifierKey: selectedAmplifierKey!,
      amplifierMode: selectedMode,
      parallelChannels: parallelChannels,
      safetyMargin: safetyMargin,
    );

    final result = AmplificationCalculatorService.calculate(
      request,
      speaker,
      amplifier,
    );

    _showResult(result);
  }

  void _showResult(AmplificationResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          result.isValid ? 'Résultat' : 'Erreur',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!result.isValid) ...[
                Text(
                  result.errorMessage ?? 'Erreur inconnue',
                  style: const TextStyle(color: Colors.red),
                ),
              ] else ...[
                Text(
                  'Amplificateurs nécessaires: ${result.amplifiersNeeded}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Puissance par canal: ${result.powerPerChannel.toStringAsFixed(0)}W',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Puissance totale requise: ${result.totalPowerRequired.toStringAsFixed(0)}W',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Puissance totale disponible: ${result.totalPowerAvailable.toStringAsFixed(0)}W',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Utilisation: ${result.powerUtilization.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: result.powerUtilization > 90 ? Colors.orange : Colors.green,
                  ),
                ),
                if (result.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Avertissements:',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  ...result.warnings.map((warning) => Text(
                    '• $warning',
                    style: const TextStyle(color: Colors.orange),
                  )),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs pour les enceintes
    final speakers = ref.read(audioSpeakersProvider);
    for (var speaker in speakers) {
      final key = '${speaker.marque}:${speaker.produit}';
      controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speakers = ref.watch(audioSpeakersProvider);
    final amplifiers = ref.watch(availableAmplifiersProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('Calcul Amplification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection de l'enceinte
            const Text(
              'Enceinte:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedSpeakerKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24,
              ),
              dropdownColor: Colors.blueGrey[800],
              style: const TextStyle(color: Colors.white),
              items: speakers.map((speaker) {
                final key = '${speaker.marque}:${speaker.produit}';
                return DropdownMenuItem(
                  value: key,
                  child: Text('${speaker.marque} ${speaker.produit}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSpeakerKey = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sélection de l'amplificateur
            const Text(
              'Amplificateur:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedAmplifierKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24,
              ),
              dropdownColor: Colors.blueGrey[800],
              style: const TextStyle(color: Colors.white),
              items: amplifiers.map((amplifier) {
                final key = amplifier.key;
                return DropdownMenuItem(
                  value: key,
                  child: Text('${amplifier.brand} ${amplifier.model}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAmplifierKey = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Mode d'amplificateur
            const Text(
              'Mode:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedMode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24,
              ),
              dropdownColor: Colors.blueGrey[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: '4ch', child: Text('4 canaux')),
                DropdownMenuItem(value: 'Bridge', child: Text('Bridge')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Marge de sécurité
            const Text(
              'Marge de sécurité:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: safetyMargin,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              label: '${safetyMargin.toStringAsFixed(1)}x',
              onChanged: (value) {
                setState(() {
                  safetyMargin = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Bouton de calcul
            Center(
              child: ElevatedButton(
                onPressed: _calculateAmplification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Calculer', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
