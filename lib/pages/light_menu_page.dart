import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/custom_app_bar.dart';
import '../widgets/light_tabs/dmx_tab.dart';
import '../widgets/uniform_bottom_nav_bar.dart';
import '../widgets/export_widget.dart';
import '../widgets/preset_widget.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../widgets/action_button.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/page_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Driver {
  final int voies;
  final int ampereParVoie;

  const Driver({required this.voies, required this.ampereParVoie});
}

class LightMenuPage extends ConsumerStatefulWidget {
  const LightMenuPage({super.key});

  @override
  ConsumerState<LightMenuPage> createState() => _LightMenuPageState();
}

class _LightMenuPageState extends ConsumerState<LightMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Utilisation du provider de persistance
  LightPageState get lightState => ref.watch(lightPageStateProvider);
  
  // Gestion des commentaires
  Map<String, String> _comments = {};
  String _currentBeamResult = ''; // Clé unique pour le résultat faisceau actuel
  String _currentDriverResult = ''; // Clé unique pour le résultat driver actuel

  final Map<String, Driver> drivers = {
    'S04x5A': const Driver(voies: 4, ampereParVoie: 5),
    'S04x10A': const Driver(voies: 4, ampereParVoie: 10),
    'S05x6A': const Driver(voies: 5, ampereParVoie: 6),
    'S32x3A': const Driver(voies: 32, ampereParVoie: 3),
  };

  // Listes pour les nouveaux menus déroulants
  final List<String> ledTypes = [
    'Blanc (W)',
    'Bi-Blanc (WW)',
    'RVB',
    'RVBW',
    'RVBWW',
  ];

  final List<String> ledPowers = [
    '5W', '6W', '7W', '8W', '9W', '10W', '11W', '12W', '13W', '14W', '15W',
    '16W', '17W', '18W', '19W', '20W', '21W', '22W', '23W', '24W', '25W',
    '26W', '27W', '28W', '29W', '30W', '31W', '32W'
  ];

  final List<String> driverChoices = [
    'S04x5A',
    'S04x10A',
    'S05x6A',
    'S32x3A',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadComments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateBeam() {
    final beamDiameter = 2 * lightState.distance * tan(lightState.angle * pi / 180);
    final result = '${AppLocalizations.of(context)!.lightPage_beamDiameter}: ${beamDiameter.toStringAsFixed(2)} m';
    ref.read(lightPageStateProvider.notifier).updateBeamCalculation(result);
    
    // Générer une nouvelle clé unique pour ce résultat
    setState(() {
      _currentBeamResult = _generateBeamResultKey();
    });
  }

  void _resetBeamCalculation() {
    // Utiliser la méthode reset() du provider comme les autres boutons reset
    ref.read(lightPageStateProvider.notifier).reset();
    
    // Effacer le commentaire du résultat précédent
    if (_currentBeamResult.isNotEmpty) {
      _comments.remove(_currentBeamResult);
      _saveComments();
    }
    
    // Forcer la mise à jour de l'interface
    setState(() {
      _currentBeamResult = '';
    });
  }


  // Nouvelles fonctions pour l'onglet Driver refait
  void _showCustomDriverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              title: Text(
                AppLocalizations.of(context)!.driverTab_customDriverTitle,
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.driverTab_customDriverChannels,
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        ref.read(lightPageStateProvider.notifier).updateCustomChannels(int.tryParse(value) ?? 4);
                        // Effacer le commentaire du résultat précédent
                        if (_currentDriverResult.isNotEmpty) {
                          _comments.remove(_currentDriverResult);
                          _saveComments();
                        }
                        _currentDriverResult = '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.driverTab_customDriverIntensity,
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        ref.read(lightPageStateProvider.notifier).updateCustomIntensity(double.tryParse(value) ?? 5.0);
                        // Effacer le commentaire du résultat précédent
                        if (_currentDriverResult.isNotEmpty) {
                          _comments.remove(_currentDriverResult);
                          _saveComments();
                        }
                        _currentDriverResult = '';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(lightPageStateProvider.notifier).updateSelectedDriverNew('Custom');
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _calculateDriverNew() {
    final loc = AppLocalizations.of(context)!;
    
    // Calculer la puissance totale
    final powerValue = double.parse(lightState.selectedLedPower.replaceAll('W', ''));
    final totalPower = lightState.longueurLed * powerValue;
    
    // Calculer l'ampérage total (supposons 24V)
    final totalAmperage = totalPower / 24.0;
    
    // Déterminer le driver
    String driverInfo;
    int channels;
    double intensityPerChannel;
    
    if (lightState.selectedDriverNew == 'Custom') {
      driverInfo = 'Custom (${lightState.customChannels} voies)';
      channels = lightState.customChannels;
      intensityPerChannel = lightState.customIntensity;
    } else {
      final driver = drivers[lightState.selectedDriverNew]!;
      driverInfo = lightState.selectedDriverNew;
      channels = driver.voies;
      intensityPerChannel = driver.ampereParVoie.toDouble();
    }
    
    // Calculer l'ampérage par voie
    final amperagePerChannel = totalAmperage / channels;
    
    // Vérifier la compatibilité
    final isCompatible = amperagePerChannel <= intensityPerChannel;
    
    final result = '${loc.driverTab_result}:\n\n'
        'LED Strip: ${lightState.selectedLedType}\n'
        'Longueur: ${lightState.longueurLed.toStringAsFixed(1)} m\n'
        'Puissance: ${lightState.selectedLedPower}/m\n'
        'Puissance totale: ${totalPower.toStringAsFixed(1)} W\n\n'
        'Driver: $driverInfo\n'
        'Ampérage total: ${totalAmperage.toStringAsFixed(2)} A\n'
        'Ampérage par voie: ${amperagePerChannel.toStringAsFixed(2)} A\n'
        'Capacité par voie: ${intensityPerChannel.toStringAsFixed(1)} A\n\n'
        '${isCompatible ? '✅ Compatible' : '❌ Non compatible'}';
    
    ref.read(lightPageStateProvider.notifier).updateDriverCalculation(result);
    
    // Générer une nouvelle clé unique pour ce résultat
    setState(() {
      _currentDriverResult = _generateDriverResultKey();
    });
  }

  void _resetDriverCalculation() {
    // Utiliser la méthode reset() du provider comme les autres boutons reset
    ref.read(lightPageStateProvider.notifier).reset();
    
    // Effacer le commentaire du résultat précédent
    if (_currentDriverResult.isNotEmpty) {
      _comments.remove(_currentDriverResult);
      _saveComments();
    }
    
    // Forcer la mise à jour de l'interface
    setState(() {
      _currentDriverResult = '';
    });
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tailles fixes pour iPhone SE et autres appareils
    final iconSize = 14.0; // 14px pour les icônes
    final fontSize = 12.0; // 12px pour le texte

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.lightbulb,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue[300]!
                            : const Color(0xFF0A1128),
                        width: 2,
                      ),
                    ),
                  ),
         child: TabBar(
           controller: _tabController,
           dividerColor: Colors.transparent, // Supprime la ligne de séparation
           indicatorColor: Colors.transparent, // Supprime l'indicateur bleu
           labelColor: Colors.transparent, // Masque les couleurs par défaut
           unselectedLabelColor: Colors.transparent, // Masque les couleurs par défaut
           tabs: [
                      Tab(
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isSelected = _tabController.index == 0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calculate, 
                                  size: iconSize,
                                  color: isSelected 
                                    ? (Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.lightBlue[300]! 
                                        : const Color(0xFF0A1128))
                                    : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DMX',
                                  style: TextStyle(
                                    color: isSelected 
                                      ? (Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.lightBlue[300]! 
                                          : const Color(0xFF0A1128))
                                      : Colors.white,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Tab(
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isSelected = _tabController.index == 1;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calculate, 
                                  size: iconSize,
                                  color: isSelected 
                                    ? (Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.lightBlue[300]! 
                                        : const Color(0xFF0A1128))
                                    : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.lightPage_beamTab,
                                    style: TextStyle(
                                      color: isSelected 
                                        ? (Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.lightBlue[300]! 
                                            : const Color(0xFF0A1128))
                                        : Colors.white,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Tab(
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isSelected = _tabController.index == 2;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calculate, 
                                  size: iconSize,
                                  color: isSelected 
                                    ? (Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.lightBlue[300]! 
                                        : const Color(0xFF0A1128))
                                    : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.lightPage_ledDriverTab,
                                    style: TextStyle(
                                      color: isSelected 
                                        ? (Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.lightBlue[300]! 
                                            : const Color(0xFF0A1128))
                                        : Colors.white,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Widget Preset pour tous les onglets
                PresetWidget(
                  onPresetSelected: (preset) {
                    // Logique de sélection de preset si nécessaire
                  },
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Premier onglet - DMX
                      const DmxTab(),
                      // Deuxième onglet - Faisceau
                      SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).extension<ResultContainerTheme>()?.backgroundColor ?? 
                                   Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: Theme.of(context).extension<ResultContainerTheme>()?.borderColor ?? 
                                     Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${loc.lightPage_angleRange}: ${lightState.angle.toStringAsFixed(1)}°',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                value: lightState.angle,
                                min: 1,
                                max: 70,
                                divisions: 69,
                                label: '${lightState.angle.round()}°',
                                onChanged: (value) {
                                  ref.read(lightPageStateProvider.notifier).updateAngle(value);
                                  // Effacer le commentaire du résultat précédent
                                  if (_currentBeamResult.isNotEmpty) {
                                    _comments.remove(_currentBeamResult);
                                    _saveComments();
                                  }
                                  _currentBeamResult = '';
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_heightRange}: ${lightState.height.toStringAsFixed(1)} m',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 20,
                                divisions: 19,
                                value: lightState.height,
                                label: '${lightState.height.round()}m',
                                onChanged: (value) => ref.read(lightPageStateProvider.notifier).updateHeight(value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_distanceRange}: ${lightState.distance.toStringAsFixed(1)} m',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 40,
                                divisions: 39,
                                value: lightState.distance,
                                label: '${lightState.distance.round()}m',
                                onChanged: (value) {
                                  ref.read(lightPageStateProvider.notifier).updateDistance(value);
                                  // Effacer le commentaire du résultat précédent
                                  if (_currentBeamResult.isNotEmpty) {
                                    _comments.remove(_currentBeamResult);
                                    _saveComments();
                                  }
                                  _currentBeamResult = '';
                                },
                              ),
                              const SizedBox(height: 16),
                              // Bouton calculer/reset centré avec ActionButton
                              Center(
                                child: lightState.beamCalculationResult != null
                                    ? ActionButton.reset(
                                        onPressed: _resetBeamCalculation,
                                        iconSize: 32,
                                        color: Colors.white,
                                      )
                                    : ActionButton(
                                        icon: Icons.calculate,
                                        onPressed: _calculateBeam,
                                        iconSize: 32,
                                        color: Colors.white,
                                      ),
                              ),
                              const SizedBox(height: 16),
                              if (lightState.beamCalculationResult != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A1128).withOpacity(0.5),
                                    border: Border.all(color: Colors.blueGrey[600]!, width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.calculationResult,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        lightState.beamCalculationResult!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Commentaire utilisateur (au-dessus des boutons)
                                      if (_getCommentForTab('beam_tab').isNotEmpty) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.blue[900]?.withOpacity(0.3)
                                                : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.lightBlue[300]!
                                                  : Colors.blue[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 14,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.lightBlue[300]
                                                    : Colors.blue[700],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _getCommentForTab('beam_tab'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      
                                      // Boutons d'action
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Bouton Commentaire (icône uniquement)
                                          ActionButton.comment(
                                            onPressed: () => _showCommentDialog('beam_tab', 'Faisceau'),
                                            iconSize: 28,
                                          ),
                                          const SizedBox(width: 20),
                                          // Bouton Export
                                          Transform.rotate(
                                            angle: 0, // Pas de rotation - flèche vers le haut
                                            child: ExportWidget(
                                              title: 'Faisceau',
                                              content: lightState.beamCalculationResult!,
                                              projectType: 'faisceau',
                                              fileName: 'faisceau',
                                              customIcon: Icons.cloud_upload,
                                              backgroundColor: Colors.blueGrey[900],
                                              tooltip: 'Exporter le calcul',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Troisième onglet - Driver (refait)
                      Column(
                        children: [
                          // Cadre principal
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).extension<ResultContainerTheme>()?.backgroundColor ?? 
                                       Colors.grey.withOpacity(0.1),
                                border: Border.all(
                                  color: Theme.of(context).extension<ResultContainerTheme>()?.borderColor ?? 
                                         Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    
                                    // Slider longueur LED strip (1-250m)
                                    Text(
                                      '${AppLocalizations.of(context)!.driverTab_ledLength}: ${lightState.longueurLed.toStringAsFixed(1)} m',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Slider(
                                      value: lightState.longueurLed,
                                      min: 1.0,
                                      max: 250.0,
                                      divisions: 249,
                                      label: '${lightState.longueurLed.toStringAsFixed(1)} m',
                                      onChanged: (value) {
                                        ref.read(lightPageStateProvider.notifier).updateLedLength(value);
                                        // Effacer le commentaire du résultat précédent
                                        if (_currentDriverResult.isNotEmpty) {
                                          _comments.remove(_currentDriverResult);
                                          _saveComments();
                                        }
                                        _currentDriverResult = '';
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Menus déroulants côte à côte
                                    Row(
                                      children: [
                                        // Menu déroulant LED Strip
                                        Expanded(
                                          child: BorderLabeledDropdown<String>(
                                            label: 'LED Strip',
                                            value: lightState.selectedLedType,
                                            items: ledTypes.map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type, style: const TextStyle(fontSize: 11)),
                                            )).toList(),
                                            onChanged: (String? newValue) {
                                              ref.read(lightPageStateProvider.notifier).updateSelectedLedType(newValue!);
                                              // Effacer le commentaire du résultat précédent
                                              if (_currentDriverResult.isNotEmpty) {
                                                _comments.remove(_currentDriverResult);
                                                _saveComments();
                                              }
                                              _currentDriverResult = '';
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Menu déroulant Puissance LED strip
                                        Expanded(
                                          child: BorderLabeledDropdown<String>(
                                            label: AppLocalizations.of(context)!.driverTab_ledPower,
                                            value: lightState.selectedLedPower,
                                            items: ledPowers.map((power) => DropdownMenuItem(
                                              value: power,
                                              child: Text(power, style: const TextStyle(fontSize: 11)),
                                            )).toList(),
                                            onChanged: (String? newValue) {
                                              ref.read(lightPageStateProvider.notifier).updateSelectedLedPower(newValue!);
                                              // Effacer le commentaire du résultat précédent
                                              if (_currentDriverResult.isNotEmpty) {
                                                _comments.remove(_currentDriverResult);
                                                _saveComments();
                                              }
                                              _currentDriverResult = '';
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Menu déroulant Choix Driver
                                    BorderLabeledDropdown<String>(
                                      label: AppLocalizations.of(context)!.driverTab_driverChoice,
                                      value: lightState.selectedDriverNew,
                                      items: driverChoices.map((driver) => DropdownMenuItem(
                                        value: driver,
                                        child: Text(driver, style: const TextStyle(fontSize: 11)),
                                      )).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue == 'Custom') {
                                          _showCustomDriverDialog();
                                        } else {
                                          ref.read(lightPageStateProvider.notifier).updateSelectedDriverNew(newValue!);
                                        }
                                        // Effacer le commentaire du résultat précédent
                                        if (_currentDriverResult.isNotEmpty) {
                                          _comments.remove(_currentDriverResult);
                                          _saveComments();
                                        }
                                        _currentDriverResult = '';
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Bouton calculer/reset centré avec ActionButton
                                    Center(
                                      child: lightState.driverCalculationResult != null
                                          ? ActionButton.reset(
                                              onPressed: _resetDriverCalculation,
                                              iconSize: 32,
                                              color: Colors.white,
                                            )
                                          : ActionButton(
                                              icon: Icons.calculate,
                                              onPressed: _calculateDriverNew,
                                              iconSize: 32,
                                              color: Colors.white,
                                            ),
                                    ),
                                    
                                    // Résultat du calcul
                                    if (lightState.driverCalculationResult != null) ...[
                                      const SizedBox(height: 24),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A1128).withOpacity(0.5),
                                          border: Border.all(color: Colors.blueGrey[600]!, width: 1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lightState.driverCalculationResult!,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            // Commentaire utilisateur (au-dessus des boutons)
                                            if (_getCommentForTab('driver_tab').isNotEmpty) ...[
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? Colors.blue[900]?.withOpacity(0.3)
                                                      : Colors.blue[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? Colors.lightBlue[300]!
                                                        : Colors.blue[300]!,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.chat_bubble_outline,
                                                      size: 14,
                                                      color: Theme.of(context).brightness == Brightness.dark
                                                          ? Colors.lightBlue[300]
                                                          : Colors.blue[700],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      _getCommentForTab('driver_tab'),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                            
                                            // Boutons d'action
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Bouton Commentaire (icône uniquement)
                                                ActionButton.comment(
                                                  onPressed: () => _showCommentDialog('driver_tab', 'Driver'),
                                                  iconSize: 28,
                                                ),
                                                const SizedBox(width: 20),
                                                // Bouton Export (rotated)
                                                Transform.rotate(
                                                  angle: 0, // Pas de rotation - flèche vers le haut
                                                  child: ExportWidget(
                                                    title: 'Led Driver',
                                                    content: lightState.driverCalculationResult!,
                                                    projectType: 'driver',
                                                    fileName: 'led_driver',
                                                    customIcon: Icons.cloud_upload,
                                                    backgroundColor: Colors.blueGrey[900],
                                                    tooltip: 'Exporter la configuration',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 1),
    );
  }

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('light_comments');
      if (commentsJson != null) {
        setState(() {
          _comments = Map<String, String>.from(json.decode(commentsJson));
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('light_comments', json.encode(_comments));
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
    }
  }

  String _getCommentForTab(String tabKey) {
    if (tabKey == 'beam_tab') {
      // Pour l'onglet faisceau, utiliser la clé unique du résultat
      return _comments[_currentBeamResult] ?? '';
    } else if (tabKey == 'driver_tab') {
      // Pour l'onglet driver, utiliser la clé unique du résultat
      return _comments[_currentDriverResult] ?? '';
    } else {
      // Pour les autres onglets, utiliser le système normal
      return _comments[tabKey] ?? '';
    }
  }

  String _generateBeamResultKey() {
    // Générer une clé unique basée sur les paramètres du calcul faisceau
    return 'beam_${lightState.selectedLedType}_${lightState.selectedLedPower}_${lightState.angle.toStringAsFixed(1)}_${lightState.distance.toStringAsFixed(1)}_${lightState.height.toStringAsFixed(1)}';
  }

  String _generateDriverResultKey() {
    // Générer une clé unique basée sur les paramètres du calcul driver
    return 'driver_${lightState.selectedLedType}_${lightState.selectedLedPower}_${lightState.longueurLed.toStringAsFixed(1)}_${lightState.selectedDriverNew}_${lightState.customChannels}_${lightState.customIntensity.toStringAsFixed(1)}';
  }

  Future<void> _showCommentDialog(String tabKey, String tabName) async {
    final TextEditingController commentController = TextEditingController(
      text: _getCommentForTab(tabKey),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1128),
          title: Text(
            'Commentaire - $tabName',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          content: TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Entrez votre commentaire...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                String commentKey;
                
                if (tabKey == 'beam_tab') {
                  // Pour l'onglet faisceau, utiliser la clé unique du résultat
                  commentKey = _currentBeamResult;
                } else if (tabKey == 'driver_tab') {
                  // Pour l'onglet driver, utiliser la clé unique du résultat
                  commentKey = _currentDriverResult;
                } else {
                  // Pour les autres onglets, utiliser le système normal
                  commentKey = tabKey;
                }
                
                _comments[commentKey] = comment;
                await _saveComments();
                if (mounted) {
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }
}
