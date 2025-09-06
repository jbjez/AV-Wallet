import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_extension.dart';
import '../providers/project_provider.dart';
import '../widgets/export_widget.dart';
import 'dart:math' as math;

// Modèle pour une entrée de patch
class PatchEntry {
  final String id;
  String trackName;
  String source;
  String? microphone;
  String? destination;
  String? type;
  String? microphoneStand; // Nouveau champ pour le pied de micro
  int quantity;

  PatchEntry({
    required this.id,
    required this.trackName,
    required this.source,
    this.microphone,
    this.destination,
    this.type,
    this.microphoneStand,
    this.quantity = 1,
  });

  PatchEntry copyWith({
    String? trackName,
    String? source,
    String? microphone,
    String? destination,
    String? type,
    String? microphoneStand,
    int? quantity,
  }) {
    return PatchEntry(
      id: id,
      trackName: trackName ?? this.trackName,
      source: source ?? this.source,
      microphone: microphone ?? this.microphone,
      destination: destination ?? this.destination,
      type: type ?? this.type,
      microphoneStand: microphoneStand ?? this.microphoneStand,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Sources disponibles pour INPUT
final List<String> inputSources = [
  'Voix',
  'Ordi',
  'DJ',
  'Piano',
  'Key',
  'GTR',
  'Basse',
  'Batterie',
  'Cuivres',
  'Violons',
];

// Destinations disponibles pour OUTPUT
final List<String> outputDestinations = [
  'Main', 'Sub', 'Ears', 'Retour', 'Front Fill', 'DJ Booth', 'Rec', 'Streaming', 'Delay'
];

// Mapping automatique des destinations stéréo/mono par défaut
final Map<String, bool> defaultStereoDestinations = {
  'Main': true,      // Stéréo par défaut
  'Sub': false,      // Mono
  'Ears': true,      // Stéréo
  'Retour': false,   // Mono
  'Front Fill': false, // Mono
  'DJ Booth': true,  // Stéréo
  'Rec': true,       // Stéréo
  'Streaming': true, // Stéréo
  'Delay': true,     // Stéréo
};

// Mapping automatique des types par défaut pour chaque destination
final Map<String, String> defaultOutputTypes = {
  'Main': 'L',           // Type L par défaut (sera dupliqué en L+R)
  'Sub': 'M',            // Type M par défaut
  'Ears': 'PSM1000',     // Type PSM1000 par défaut
  'Retour': 'X12',       // Type X12 par défaut
  'Front Fill': 'X12',   // Type X12 par défaut
  'DJ Booth': 'L',       // Type L par défaut
  'Rec': 'L',            // Type L par défaut
  'Streaming': 'L',      // Type L par défaut
  'Delay': 'L',          // Type L par défaut
};

// Mapping automatique des microphones par défaut
final Map<String, String> defaultMicrophones = {
  'Voix': 'HF',
  'Voix Lead': 'HF',
  'Ordi': 'D.I.',
  'DJ': 'D.I.',
  'Piano': 'DI',
  'Key': 'DI',
  'GTR': 'SM57',
  'Basse': 'DI',
  'Batterie': 'SM57',
  'Cuivres': 'SM58',
  'Violons': 'SM81',
};

// Types de pieds de micro disponibles
final List<String> microphoneStandTypes = [
  'Petit Pied (PP)',
  'Grand Pied (GP)', 
  'Pied embase ronde (PER)',
  'Pied de table (PT)',
];

// Mapping automatique des pieds de micro par défaut selon l'instrument
final Map<String, String> defaultMicrophoneStands = {
  'Voix': 'Grand Pied (GP)',
  'Voix Lead': 'Grand Pied (GP)',
  'Ordi': 'Pied de table (PT)',
  'DJ': 'Pied de table (PT)',
  'Piano': 'Grand Pied (GP)',
  'Key': 'Pied de table (PT)',
  'GTR': 'Petit Pied (PP)',
  'Basse': 'Petit Pied (PP)',
  'Batterie': 'Pied embase ronde (PER)',
  'Cuivres': 'Grand Pied (GP)',
  'Violons': 'Grand Pied (GP)',
};

class PatchScenePage extends ConsumerStatefulWidget {
  const PatchScenePage({super.key});

  @override
  ConsumerState<PatchScenePage> createState() => _PatchScenePageState();
}

class _PatchScenePageState extends ConsumerState<PatchScenePage> {
  final GlobalKey _repaintKey = GlobalKey();
  List<PatchEntry> _inputs = [];
  List<PatchEntry> _outputs = [];
  
  // Contrôleurs pour les champs de texte
  final TextEditingController _trackNameController = TextEditingController();
  final TextEditingController _microphoneController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _microphoneStandController = TextEditingController();
  
  // Variable pour gérer le mode mono/stéréo
  bool _isStereo = false;
  
  // Instruments qui sont par défaut en stéréo
  final List<String> _stereoInstruments = ['Ordi', 'DJ', 'Key', 'Piano'];
  
  // Compteur pour éviter les collisions d'ID
  int _idSeed = 0;
  
  // Helper pour générer des IDs uniques
  String _nextId([String suffix = '']) => '${DateTime.now().millisecondsSinceEpoch}_${_idSeed++}$suffix';
  
  // Helper pour détecter si un nom de piste est stéréo
  bool _isTrackNameStereo(String name) => name.trim().endsWith(' L') || name.trim().endsWith(' R');
  
  // Helper pour déterminer le flag stéréo/mono d'une sortie
  String stereoFlagForOutput(PatchEntry e) {
    if (_isTrackNameStereo(e.trackName)) return 'Stéréo';
    final mapped = defaultStereoDestinations[e.destination ?? ''] ?? false;
    return mapped ? 'Stéréo' : 'Mono';
  }

  @override
  void initState() {
    super.initState();
    // Ajouter une piste par défaut dans chaque cadre
    _addDefaultInputTrack();
    _addDefaultOutputTrack();
  }

  void _addDefaultInputTrack() {
    if (_inputs.isEmpty) {
      _inputs.add(PatchEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        trackName: '',
        source: 'Voix',
        microphone: 'HF',
        destination: '',
        type: '',
        quantity: 1,
      ));
    }
  }

  // Méthode pour ajouter une piste OUTPUT par défaut
  void _addDefaultOutputTrack() {
    if (_outputs.isEmpty) {
      final dest = 'Main';
      _outputs.add(PatchEntry(
        id: _nextId('_L'),
        trackName: '',
        source: '',
        microphone: '',
        destination: dest,
        type: defaultOutputTypes[dest] ?? 'L',
        quantity: 1,
      ));
      _outputs.add(PatchEntry(
        id: _nextId('_R'),
        trackName: '',
        source: '',
        microphone: '',
        destination: dest,
        type: defaultOutputTypes[dest] ?? 'R',
        quantity: 1,
      ));
    }
  }

  // Méthode pour réorganiser les OUTPUT en déplaçant les paires stéréo ensemble
  void _reorderOutputsWithStereoPairs(int oldIndex, int newIndex) {
    final movedEntry = _outputs[oldIndex];
    
    // Vérifier si c'est une piste stéréo (L ou R)
    final isLeft = movedEntry.trackName.endsWith(' L');
    final isRight = movedEntry.trackName.endsWith(' R');
    
    if (!isLeft && !isRight) {
      // Piste mono, déplacer normalement
      final item = _outputs.removeAt(oldIndex);
      _outputs.insert(newIndex, item);
      return;
    }
    
    // C'est une piste stéréo, trouver sa paire
    final baseName = movedEntry.trackName.replaceAll(RegExp(r' [LR]$'), '');
    final isLeftTrack = movedEntry.trackName.endsWith(' L');
    final expectedPairSuffix = isLeftTrack ? ' R' : ' L';
    
    // Trouver l'index de la paire correspondante
    int pairIndex = -1;
    for (int i = 0; i < _outputs.length; i++) {
      if (i != oldIndex && 
          _outputs[i].trackName.startsWith(baseName) && 
          _outputs[i].trackName.endsWith(expectedPairSuffix)) {
        pairIndex = i;
        break;
      }
    }
    
    if (pairIndex != -1) {
      // Déplacer les deux pistes ensemble
      final pairEntry = _outputs[pairIndex];
      
      // Supprimer les deux pistes de leurs positions actuelles
      final firstIndex = math.min(oldIndex, pairIndex);
      final secondIndex = math.max(oldIndex, pairIndex);
      
      _outputs.removeAt(secondIndex);
      _outputs.removeAt(firstIndex);
      
      // Calculer le nouvel index d'insertion
      int insertIndex = newIndex;
      if (oldIndex < newIndex && pairIndex < newIndex) {
        insertIndex -= 2; // Ajuster car on a supprimé 2 éléments avant newIndex
      } else if (oldIndex < newIndex && pairIndex >= newIndex) {
        insertIndex -= 1; // Ajuster car on a supprimé 1 élément avant newIndex
      } else if (oldIndex >= newIndex && pairIndex >= newIndex) {
        insertIndex -= 2; // Ajuster car on a supprimé 2 éléments avant newIndex
      }
      
      // S'assurer que l'index d'insertion est valide
      insertIndex = math.max(0, math.min(insertIndex, _outputs.length));
      
      // Insérer les deux pistes à la nouvelle position (L en premier, R en second)
      if (isLeftTrack) {
        _outputs.insert(insertIndex, movedEntry);
        _outputs.insert(insertIndex + 1, pairEntry);
      } else {
        _outputs.insert(insertIndex, pairEntry);
        _outputs.insert(insertIndex + 1, movedEntry);
      }
    } else {
      // Pas de paire trouvée, déplacer normalement
      final item = _outputs.removeAt(oldIndex);
      _outputs.insert(newIndex, item);
    }
  }

  @override
  void dispose() {
    _trackNameController.dispose();
    _microphoneController.dispose();
    _typeController.dispose();
    _microphoneStandController.dispose();
    super.dispose();
  }

  void _addInputTrack() {
    setState(() {
      _inputs.add(PatchEntry(
        id: _nextId(),
        trackName: '',
        source: 'Voix',
        microphone: 'HF',
        microphoneStand: null,
        destination: '',
        type: '',
        quantity: 1,
      ));
    });
    // Afficher le popup quantité pour la nouvelle piste
    final newEntry = _inputs.last;
    _showEditDialog(newEntry, isInput: true);
  }

  void _addOutputTrack() {
    setState(() {
      final dest = 'Main';
      final isStereo = defaultStereoDestinations[dest] ?? false;
      
      if (isStereo) {
        // Créer une paire stéréo L/R
        _outputs.add(PatchEntry(
          id: _nextId('_L'),
          trackName: '',
          source: '',
          microphone: '',
          destination: dest,
          type: 'L',
          quantity: 1,
        ));
        _outputs.add(PatchEntry(
          id: _nextId('_R'),
          trackName: '',
          source: '',
          microphone: '',
          destination: dest,
          type: 'R',
          quantity: 1,
        ));
      } else {
        // Créer une piste mono
        _outputs.add(PatchEntry(
          id: _nextId(),
          trackName: '',
          source: '',
          microphone: '',
          destination: dest,
          type: defaultOutputTypes[dest] ?? 'L',
          quantity: 1,
        ));
      }
    });
    // Afficher le popup pour la première piste de la paire ou la piste mono
    final newEntry = _outputs.last;
    _showEditDialog(newEntry, isInput: false);
  }

  void _showEditDialog(PatchEntry entry, {bool isInput = true, bool renameOnly = false}) {
    // Vérification de sécurité pour éviter le crash
    if (entry.id.isEmpty) {
      print('Erreur: ID de piste vide');
      return;
    }
    
    _trackNameController.text = entry.trackName;
    if (isInput) {
      _microphoneController.text = entry.microphone ?? '';
      _microphoneStandController.text = entry.microphoneStand ?? '';
      // Initialiser le mode stéréo selon l'instrument
      _isStereo = _stereoInstruments.contains(entry.source);
    } else {
      _typeController.text = entry.type ?? defaultOutputTypes[entry.destination] ?? 'L';
      // Initialiser le mode stéréo selon la destination
      _isStereo = defaultStereoDestinations[entry.destination] ?? false;
      // Si c'est stéréo, mettre le type à "L" par défaut
      if (_isStereo) {
        _typeController.text = 'L';
      }
    }

    // Créer des FocusNode pour la sélection automatique du texte
    final FocusNode trackNameFocusNode = FocusNode();
    final FocusNode microphoneFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Pas de focalisation automatique, seulement sélection au clic
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   if (trackNameFocusNode.canRequestFocus) {
            //     trackNameFocusNode.requestFocus();
            //     // Attendre un peu que le TextField soit complètement rendu
            //     Future.delayed(const Duration(milliseconds: 100), () {
            //       if (_trackNameController.text.isNotEmpty) {
            //         _trackNameController.selection = TextSelection(
            //           baseOffset: 0,
            //           extentOffset: _trackNameController.text.length,
            //         );
            //       }
            //     });
            //   }
            // });
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        renameOnly ? AppLocalizations.of(context)!.patch_rename : AppLocalizations.of(context)!.patch_instrument,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    // Contenu scrollable
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!renameOnly) ...[
                              // Dropdown pour la source/destination
                              UniformDropdown<String>(
                                value: (isInput ? (entry.source.isNotEmpty ? entry.source : null) : (entry.destination?.isNotEmpty == true ? entry.destination : null)),
                                items: (isInput ? inputSources : outputDestinations)
                                    .map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      if (isInput) {
                                        entry = entry.copyWith(
                                          source: value,
                                          microphone: defaultMicrophones[value] ?? '',
                                        );
                                        _microphoneController.text = entry.microphone ?? '';
                                        // Initialiser le pied par défaut selon l'instrument
                                        final pied = defaultMicrophoneStands[value];
                                        if (pied != null) {
                                          _microphoneStandController.text = pied;
                                        }
                                        // Initialiser le mode stéréo selon l'instrument
                                        _isStereo = _stereoInstruments.contains(value);
                                      } else {
                                        entry = entry.copyWith(destination: value);
                                        // Mettre à jour automatiquement le mode stéréo selon la destination
                                        _isStereo = defaultStereoDestinations[value] ?? false;
                                        // Mettre le type par défaut selon la destination
                                        final defaultType = defaultOutputTypes[value] ?? 'L';
                                        _typeController.text = defaultType;
                                      }
                                    });
                                  }
                                },
                                labelText: isInput 
                                    ? AppLocalizations.of(context)!.patch_instrument
                                    : AppLocalizations.of(context)!.patch_destination,
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Champ nom de piste
                            TextField(
                              controller: _trackNameController,
                              focusNode: trackNameFocusNode,
                              onTap: () {
                                // Sélectionner tout le texte quand on clique dedans
                                if (_trackNameController.text.isNotEmpty) {
                                  _trackNameController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _trackNameController.text.length,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Renommer piste',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.blue 
                                        : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : const Color(0xFF1a237e), // Bleu nuit en mode jour
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Champ microphone/type
                            if (isInput)
                              TextField(
                                controller: _microphoneController,
                                focusNode: microphoneFocusNode,
                                onTap: () {
                                  // Sélectionner tout le texte quand on clique dedans
                                  if (_microphoneController.text.isNotEmpty) {
                                    _microphoneController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: _microphoneController.text.length,
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.patch_microphone,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.blue 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                ),
                              )
                            else
                              TextField(
                                controller: _typeController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.patch_type,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.blue 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Champ pied de micro (uniquement pour INPUT)
                            if (isInput) ...[
                              UniformDropdown<String?>(
                                value: _microphoneStandController.text.isNotEmpty ? _microphoneStandController.text : null,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Sélectionner un pied', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ),
                                  ...microphoneStandTypes
                                      .map((item) => DropdownMenuItem<String?>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ))
                                      .toList(),
                                ],
                                onChanged: (value) {
                                  setDialogState(() {
                                    _microphoneStandController.text = value ?? '';
                                  });
                                },
                                labelText: 'Pied de micro',
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Sélection mono/stéréo (pour les entrées ET les sorties)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: Text(
                                    'Mono', 
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                    ),
                                  ),
                                  selected: !_isStereo,
                                  selectedColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.blue 
                                      : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[800] 
                                      : Colors.grey[200],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setDialogState(() {
                                        _isStereo = false;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: Text(
                                    'Stéréo', 
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                    ),
                                  ),
                                  selected: _isStereo,
                                  selectedColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.blue 
                                      : const Color(0xFF1a237e), // Bleu nuit en mode jour
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[800] 
                                      : Colors.grey[200],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setDialogState(() {
                                        _isStereo = true;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Sélecteur de quantité
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.patch_quantity,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    if (entry.quantity > 1) {
                                      setDialogState(() {
                                        entry = entry.copyWith(quantity: entry.quantity - 1);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Text(
                                  '${entry.quantity}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      entry = entry.copyWith(quantity: entry.quantity + 1);
                                    });
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Boutons d'action
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              AppLocalizations.of(context)!.patch_cancel,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Mettre à jour la piste existante mais ne pas fermer le popup
                              setDialogState(() {
                                if (isInput) {
                                  if (_isStereo) {
                                    // Mode stéréo : créer des paires L et R selon la quantité
                                    // Supprimer l'ancienne entrée
                                    _inputs.removeWhere((e) => e.id == entry.id);
                                    
                                    // Créer des paires stéréo selon la quantité
                                    for (int i = 0; i < entry.quantity; i++) {
                                      final base = _trackNameController.text; // ex: "1/"
                                      final baseNum = base.replaceAll('/', '').trim();
                                      final suffix = entry.quantity > 1 ? '${i + 1}' : '';
                                      _inputs.add(PatchEntry(
                                        id: _nextId('_L_$i'),
                                        trackName: '${baseNum}${suffix}L',
                                        source: entry.source,
                                        microphone: _microphoneController.text,
                                        microphoneStand: _microphoneStandController.text,
                                        destination: '',
                                        type: '',
                                        quantity: 1,
                                      ));
                                      _inputs.add(PatchEntry(
                                        id: _nextId('_R_$i'),
                                        trackName: '${baseNum}${suffix}R',
                                        source: entry.source,
                                        microphone: _microphoneController.text,
                                        microphoneStand: _microphoneStandController.text,
                                        destination: '',
                                        type: '',
                                        quantity: 1,
                                      ));
                                    }
                                  } else {
                                    // Mode mono : gérer la quantité
                                    if (entry.quantity == 1) {
                                      // Quantité = 1 : mettre à jour la piste existante
                                      final index = _inputs.indexWhere((e) => e.id == entry.id);
                                      if (index != -1) {
                                        _inputs[index] = _inputs[index].copyWith(
                                          trackName: _trackNameController.text,
                                          source: entry.source,
                                          microphone: _microphoneController.text,
                                          microphoneStand: _microphoneStandController.text,
                                          quantity: entry.quantity,
                                        );
                                        // Mettre à jour l'entrée locale pour le popup
                                        entry = _inputs[index];
                                      }
                                    } else {
                                      // Quantité > 1 : créer plusieurs pistes visuelles
                                      // Supprimer l'ancienne entrée
                                      _inputs.removeWhere((e) => e.id == entry.id);
                                      
                                      // Créer plusieurs pistes selon la quantité
                                      for (int i = 0; i < entry.quantity; i++) {
                                        _inputs.add(PatchEntry(
                                          id: _nextId('_qty_$i'),
                                          trackName: '${_trackNameController.text} ${i + 1}',
                                          source: entry.source,
                                          microphone: _microphoneController.text,
                                          microphoneStand: _microphoneStandController.text,
                                          destination: '',
                                          type: '',
                                          quantity: 1, // Chaque piste a une quantité de 1
                                        ));
                                      }
                                    }
                                  }
                                } else {
                                  // Gérer les pistes de sortie avec mode stéréo/mono et quantité
                                  if (_isStereo) {
                                    // Mode stéréo : créer des paires L et R selon la quantité
                                    // Supprimer l'ancienne entrée
                                    _outputs.removeWhere((e) => e.id == entry.id);
                                    
                                    // Créer des paires stéréo selon la quantité
                                    for (int i = 0; i < entry.quantity; i++) {
                                      final base = _trackNameController.text; // ex: "1/"
                                      final baseNum = base.replaceAll('/', '').trim();
                                      final suffix = entry.quantity > 1 ? '${i + 1}' : '';
                                      _outputs.add(PatchEntry(
                                        id: _nextId('_L_$i'),
                                        trackName: '${baseNum}${suffix}L',
                                        source: '',
                                        microphone: '',
                                        destination: entry.destination,
                                        type: 'L', // Forcer type L pour la piste gauche
                                        quantity: 1,
                                      ));
                                      _outputs.add(PatchEntry(
                                        id: _nextId('_R_$i'),
                                        trackName: '${baseNum}${suffix}R',
                                        source: '',
                                        microphone: '',
                                        destination: entry.destination,
                                        type: 'R', // Forcer type R pour la piste droite
                                        quantity: 1,
                                      ));
                                    }
                                  } else {
                                    // Mode mono : gérer la quantité
                                    if (entry.quantity == 1) {
                                      // Quantité = 1 : mettre à jour la piste existante
                                      final index = _outputs.indexWhere((e) => e.id == entry.id);
                                      if (index != -1) {
                                        _outputs[index] = _outputs[index].copyWith(
                                          trackName: _trackNameController.text,
                                          destination: entry.destination,
                                          type: _typeController.text,
                                          quantity: entry.quantity,
                                        );
                                        // Mettre à jour l'entrée locale pour le popup
                                        entry = _outputs[index];
                                      }
                                    } else {
                                      // Quantité > 1 : créer plusieurs pistes visuelles
                                      // Supprimer l'ancienne entrée
                                      _outputs.removeWhere((e) => e.id == entry.id);
                                      
                                      // Créer plusieurs pistes selon la quantité
                                      for (int i = 0; i < entry.quantity; i++) {
                                        _outputs.add(PatchEntry(
                                          id: _nextId('_qty_$i'),
                                          trackName: '${_trackNameController.text} ${i + 1}',
                                          source: '',
                                          microphone: '',
                                          destination: entry.destination,
                                          type: _typeController.text,
                                          quantity: 1, // Chaque piste a une quantité de 1
                                        ));
                                      }
                                    }
                                  }
                                }
                              });
                              
                              // Forcer la mise à jour de l'interface après la fermeture du dialogue
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {});
                              });
                              
                              // Valider le changement et fermer le popup
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Valider',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTrack(PatchEntry entry, bool isInput) {
    setState(() {
      if (isInput) {
        _inputs.removeWhere((e) => e.id == entry.id);
        // Renuméroter seulement les noms purement numériques
        final numOnly = RegExp(r'^\d+\/$');
        for (int i = 0; i < _inputs.length; i++) {
          if (numOnly.hasMatch(_inputs[i].trackName)) {
            _inputs[i] = _inputs[i].copyWith(
              trackName: '${i + 1}/',
            );
          }
        }
      } else {
        // Vérifier si c'est une piste stéréo
        final isLeft = entry.trackName.endsWith(' L');
        final isRight = entry.trackName.endsWith(' R');
        
        if (isLeft || isRight) {
          // C'est une piste stéréo, supprimer la paire complète
          final baseName = entry.trackName.replaceAll(RegExp(r' [LR]$'), '');
          final expectedPairSuffix = isLeft ? ' R' : ' L';
          
          // Supprimer les deux pistes de la paire
          _outputs.removeWhere((e) => e.id == entry.id);
          _outputs.removeWhere((e) => 
            e.trackName.startsWith(baseName) && 
            e.trackName.endsWith(expectedPairSuffix)
          );
        } else {
          // Piste mono, supprimer normalement
          _outputs.removeWhere((e) => e.id == entry.id);
        }
        
        // Renuméroter seulement les noms purement numériques
        final numOnly = RegExp(r'^\d+\/$');
        for (int i = 0; i < _outputs.length; i++) {
          if (numOnly.hasMatch(_outputs[i].trackName)) {
            _outputs[i] = _outputs[i].copyWith(
              trackName: '${i + 1}/',
            );
          }
        }
      }
    });
  }

  void _duplicateTrack(PatchEntry entry, bool isInput) {
    setState(() {
      final newEntry = PatchEntry(
        id: _nextId(),
        trackName: '${entry.trackName} (copie)',
        source: entry.source,
        microphone: entry.microphone,
        destination: entry.destination,
        type: entry.type,
        quantity: entry.quantity,
      );
      
      if (isInput) {
        _inputs.add(newEntry);
      } else {
        _outputs.add(newEntry);
      }
    });
  }

  Widget _buildSectionCard({
    required String title,
    required bool isInput,
    required List<PatchEntry> entries,
    required VoidCallback onAddTrack,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: context.dialogBackgroundColor.withOpacity(0.5),
        border: Border.all(color: Colors.white), // Bordure blanche pour INPUT et OUTPUT
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et bouton "Ajouter une piste" sur la même ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                // Bouton "Ajouter une piste" avec seulement l'icône +
                Container(
                  width: MediaQuery.of(context).size.width * 0.15, // Réduit de 70%
                  child: ElevatedButton(
                    onPressed: onAddTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PatchList(
              isInput: isInput,
              entries: entries,
              onEdit: (entry) => _showEditDialog(entry, isInput: isInput),
              onDelete: (entry) => _deleteTrack(entry, isInput),
              onDuplicate: (entry) => _duplicateTrack(entry, isInput),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  if (isInput) {
                    final item = _inputs.removeAt(oldIndex);
                    _inputs.insert(newIndex, item);
                  } else {
                    // Logique intelligente pour les OUTPUT : déplacer les paires stéréo ensemble
                    _reorderOutputsWithStereoPairs(oldIndex, newIndex);
                  }
                });
              },
            ),
            // Suppression des boutons d'export PNG/CSV
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCardWithExport({
    required String title,
    required bool isInput,
    required List<PatchEntry> entries,
    required VoidCallback onAddTrack,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: context.dialogBackgroundColor.withOpacity(0.5),
        border: Border.all(color: Colors.white), // Bordure blanche pour INPUT et OUTPUT
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et bouton "Ajouter une piste" sur la même ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                // Bouton "Ajouter une piste" avec seulement l'icône +
                Container(
                  width: MediaQuery.of(context).size.width * 0.15, // Réduit de 70%
                  child: ElevatedButton(
                    onPressed: onAddTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PatchList(
              isInput: isInput,
              entries: entries,
              onEdit: (entry) => _showEditDialog(entry, isInput: isInput),
              onDelete: (entry) => _deleteTrack(entry, isInput),
              onDuplicate: (entry) => _duplicateTrack(entry, isInput),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  if (isInput) {
                    final item = _inputs.removeAt(oldIndex);
                    _inputs.insert(newIndex, item);
                  } else {
                    // Logique intelligente pour les OUTPUT : déplacer les paires stéréo ensemble
                    _reorderOutputsWithStereoPairs(oldIndex, newIndex);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            // Widget Export intégré dans le cadre
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ExportWidget(
                  title: '${AppLocalizations.of(context)!.patch_title} \'${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName}\'',
                  content: _generatePatchTableContent(),
                  presetName: ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName,
                  exportDate: DateTime.now(),
                  patchInputs: _inputs.map((entry) => {
                    'trackName': entry.trackName,
                    'source': entry.source,
                    'microphone': entry.microphone ?? '',
                    'microphoneStand': entry.microphoneStand ?? '',
                    'type': _isTrackNameStereo(entry.trackName) ? 'Stéréo' : 'Mono',
                    'quantity': entry.quantity,
                  }).toList(),
                  patchOutputs: _outputs.map((entry) => {
                    'trackName': entry.trackName,
                    'destination': entry.destination ?? '',
                    'type': entry.type ?? '',
                    'stereoMono': stereoFlagForOutput(entry),
                    'quantity': entry.quantity,
                  }).toList(),
                  patchSummary: {
                    'Total INPUT': _inputs.length,
                    'Total OUTPUT': _outputs.length,
                    'Sorties Stéréo': _outputs.where((e) => defaultStereoDestinations[e.destination] == true).length,
                    'Sorties Mono': _outputs.where((e) => defaultStereoDestinations[e.destination] == false).length,
                    'Total Pieds': _inputs.where((e) => e.microphoneStand != null && e.microphoneStand!.isNotEmpty).length,
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return RepaintBoundary(
      key: _repaintKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal avec nom du projet
            Center(
              child: Text(
                '${loc.patch_title} \'${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName}\'',
                style: TextStyle(
                  fontSize: 18, // Réduit de 2 points supplémentaires (était 20)
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Section INPUT avec Export intégré
            _buildSectionCardWithExport(
              title: loc.patch_input,
              isInput: true,
              entries: _inputs,
              onAddTrack: _addInputTrack,
            ),
            
            const SizedBox(height: 16),
            
            // Section OUTPUT avec Export intégré
            _buildSectionCardWithExport(
              title: loc.patch_output,
              isInput: false,
              entries: _outputs,
              onAddTrack: _addOutputTrack,
            ),
            
            const SizedBox(height: 16),
            
            // Cadre de résumé Total Patch
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: context.dialogBackgroundColor.withOpacity(0.5),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne 1: Total Patch
                    Text(
                      'Total Patch',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Ligne 2: Total Input
                    Text(
                      'Total Input : ${_inputs.length} ch',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Ligne 3: Total Output
                    Text(
                      'Total Output : ${_outputs.length} ch',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
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

  String _generatePatchTableContent() {
    final StringBuffer content = StringBuffer();
    
    // En-tête du tableau
    content.writeln('📋 TABLEAU DU PATCH');
    content.writeln('==================');
    content.writeln('');
    
    // Section INPUT
    if (_inputs.isNotEmpty) {
      content.writeln('🎤 INPUT:');
      content.writeln('--------');
      for (int i = 0; i < _inputs.length; i++) {
        final entry = _inputs[i];
        final isStereo = _isTrackNameStereo(entry.trackName);
        content.writeln('${i + 1}. ${entry.trackName} | ${entry.source} | ${entry.microphone ?? ""} | ${entry.microphoneStand ?? ""} | ${isStereo ? "Stéréo" : "Mono"} | Qté: ${entry.quantity}');
      }
      content.writeln('');
    }
    
    // Section OUTPUT
    if (_outputs.isNotEmpty) {
      content.writeln('🔊 OUTPUT:');
      content.writeln('---------');
      for (int i = 0; i < _outputs.length; i++) {
        final entry = _outputs[i];
        final isStereo = _isTrackNameStereo(entry.trackName) || (defaultStereoDestinations[entry.destination] ?? false);
        content.writeln('${i + 1}. ${entry.trackName} | ${entry.destination} | ${entry.type ?? ""} | ${isStereo ? "Stéréo" : "Mono"} | Qté: ${entry.quantity}');
      }
      content.writeln('');
    }
    
    // Résumé
    content.writeln('📊 RÉSUMÉ:');
    content.writeln('----------');
    content.writeln('Total INPUT: ${_inputs.length}');
    content.writeln('Total OUTPUT: ${_outputs.length}');
    content.writeln('Sorties Stéréo: ${_outputs.where((e) => defaultStereoDestinations[e.destination] == true).length}');
    content.writeln('Sorties Mono: ${_outputs.where((e) => defaultStereoDestinations[e.destination] == false).length}');
    
    return content.toString();
  }
}



// Widget pour la liste des pistes
class _PatchList extends StatelessWidget {
  final bool isInput;
  final List<PatchEntry> entries;
  final Function(PatchEntry) onEdit;
  final Function(PatchEntry) onDelete;
  final Function(PatchEntry) onDuplicate;
  final Function(int, int) onReorder;

  const _PatchList({
    required this.isInput,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.patch_no_entries,
          style: const TextStyle(fontSize: 14), // Réduit de 2 points
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          key: ValueKey(entry.id),
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Partie gauche : nom de piste + instrument (cliquable)
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => onEdit(entry),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ligne 1 : Instrument/Source + Nom de la piste (en gras blanc)
                          Text(
                            isInput 
                                ? '${entry.source} - ${entry.trackName}'
                                : '${entry.destination} - ${entry.trackName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // Ligne 2 : Microphone (INPUT) ou Type (OUTPUT) (en petit grisé)
                          Text(
                            isInput 
                                ? entry.microphone ?? ''
                                : entry.type ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Partie droite : menu déroulant
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit(entry);
                        break;
                      case 'duplicate':
                        onDuplicate(entry);
                        break;
                      case 'delete':
                        onDelete(entry);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        AppLocalizations.of(context)!.patch_rename,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(
                        'Dupliquer',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        AppLocalizations.of(context)!.patch_delete,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget pour le bouton d'ajout
class _AddRowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _AddRowButton({
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.dialogBackgroundColor.withOpacity(0.3),
          side: BorderSide(color: context.dialogBorderColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
