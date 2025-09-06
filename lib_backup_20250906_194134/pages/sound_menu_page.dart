import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../widgets/preset_widget.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/decibel_meter_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/preset_provider.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SoundMenuPage extends ConsumerStatefulWidget {
  const SoundMenuPage({super.key});

  @override
  ConsumerState<SoundMenuPage> createState() => _SoundMenuPageState();
}

class _SoundMenuPageState extends ConsumerState<SoundMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.volume_up,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: Theme.of(context).brightness == Brightness.light ? 0.15 : 0.5,
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Amp.LA'),
                      Tab(text: 'Decibelmètre'),
                      Tab(text: 'Calcul Projet'),
                    ],
                  ),
                ),
                if (_tabController.index == 2)
                  PresetWidget(
                    onPresetSelected: (preset) {
                      setState(() {
                        final presets = ref.read(presetProvider);
                        final index =
                            presets.indexWhere((p) => p.id == preset.id);
                        if (index != -1) {
                          ref.read(presetProvider.notifier).selectPreset(index);
                        }
                      });
                    },
                  ),
                const SizedBox(height: 6),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      AmplificationLATab(),
                      DecibelMeterWidget(),
                      CalculProjectTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          final pages = [
            const CataloguePage(),
            const LightMenuPage(),
            const StructureMenuPage(),
            const SoundMenuPage(),
            const VideoMenuPage(),
            const ElectriciteMenuPage(),
            const DiversMenuPage(),
          ];

          Offset beginOffset;
          if (index == 0 || index == 1) {
            beginOffset = const Offset(-1.0, 0.0);
          } else if (index == 5 || index == 6) {
            beginOffset = const Offset(1.0, 0.0);
          } else {
            beginOffset = Offset.zero;
          }

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => pages[index],
              transitionsBuilder: (_, animation, __, child) {
                if (beginOffset == Offset.zero) {
                  return FadeTransition(opacity: animation, child: child);
                } else {
                  final tween = Tween(begin: beginOffset, end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                }
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Catalogue'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb), label: 'Lumière'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/truss_icon_grey.png',
                  width: 24, height: 24),
              label: 'Structure'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.volume_up), label: 'Son'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: 'Vidéo'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.bolt), label: 'Électricité'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: 'Divers'),
        ],
      ),
    );
  }
}

class AmplificationLATab extends ConsumerStatefulWidget {
  const AmplificationLATab({super.key});

  @override
  ConsumerState<AmplificationLATab> createState() => _AmplificationLATabState();
}

class _AmplificationLATabState extends ConsumerState<AmplificationLATab> {
  String searchQuery = '';
  String? selectedSpeaker;
  String? preferredAmplifier;
  int speakerQuantity = 1;
  List<Map<String, dynamic>> selectedSpeakers = [];
  List<CatalogueItem> searchResults = [];
  String? calculationResult;

  final List<String> amplifierTypes = ['LA4X', 'LA8', 'LA12X', 'Custom'];

  final Map<String, Map<String, Map<String, int>>> amplificationData = {
    "Kara II": {
      "LA4X": {"parSortie": 2, "total": 4},
      "LA8": {"parSortie": 3, "total": 6},
      "LA12X": {"parSortie": 3, "total": 6}
    },
    "Kiva II": {
      "LA4X": {"parSortie": 2, "total": 8},
      "LA8": {"parSortie": 4, "total": 16},
      "LA12X": {"parSortie": 6, "total": 24}
    },
    "Kiva / Kilo": {
      "LA4": {"parSortie": 2, "total": 8},
      "LA8": {"parSortie": 3, "total": 12},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "X8": {
      "LA4X": {"parSortie": 2, "total": 8},
      "LA8": {"parSortie": 3, "total": 8},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "X12": {
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "X15": {
      "LA4X": {"parSortie": 1, "total": 2},
      "LA8": {"parSortie": 2, "total": 4},
      "LA12X": {"parSortie": 3, "total": 6}
    },
    "SB18": {
      "LA4": {"parSortie": 1, "total": 4},
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 2, "total": 8}
    },
    "KS28": {
      "LA8": {"parSortie": 1, "total": 4},
      "LA12X": {"parSortie": 1, "total": 4}
    },
    "Syva": {
      "LA2Xi": {"parSortie": 1, "total": 2},
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "K2": {
      "LA4X": {"parSortie": 1, "total": 1},
      "LA8": {"parSortie": 3, "total": 3},
      "LA12X": {"parSortie": 3, "total": 6}
    },
    "K3": {
      "LA4X": {"parSortie": 1, "total": 2},
      "LA8": {"parSortie": 2, "total": 4},
      "LA12X": {"parSortie": 3, "total": 6}
    },
    "A15": {
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "A10": {
      "LA4X": {"parSortie": 2, "total": 8},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 3, "total": 12}
    },
    "5XT": {
      "LA4X": {"parSortie": 4, "total": 16},
      "LA8": {"parSortie": 6, "total": 24},
      "LA12X": {"parSortie": 6, "total": 24}
    },
    "KS21": {
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 6},
      "LA12X": {"parSortie": 2, "total": 8}
    },
    "SB118": {
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 8},
      "LA12X": {"parSortie": 2, "total": 8}
    },
    "SB218": {
      "LA4X": {"parSortie": 0, "total": 0},
      "LA8": {"parSortie": 1, "total": 4},
      "LA12X": {"parSortie": 1, "total": 4}
    },
    "SB15M": {
      "LA4X": {"parSortie": 1, "total": 4},
      "LA8": {"parSortie": 2, "total": 6},
      "LA12X": {"parSortie": 3, "total": 12}
    }
  };

  void _calculateAmplification() {
    Map<String, int> speakerCount = {};
    Map<String, Map<String, int>> amplifierNeeds = {};

    // Comptage des enceintes par type
    for (var speaker in selectedSpeakers) {
      final name = speaker['name'] as String;
      final qty = speaker['quantity'] as int;
      speakerCount[name] = (speakerCount[name] ?? 0) + qty;
    }

    // Analyse des besoins en amplification pour chaque type d'enceinte
    for (var speaker in speakerCount.entries) {
      final speakerName = speaker.key;
      final int count = speaker.value;

      if (amplificationData.containsKey(speakerName)) {
        // Si un ampli préférentiel est sélectionné, on l'utilise en priorité
        if (preferredAmplifier != null &&
            preferredAmplifier != 'Custom' &&
            amplificationData[speakerName]!.containsKey(preferredAmplifier)) {
          final ampData = amplificationData[speakerName]![preferredAmplifier]!;
          final int totalChannels = ampData['total']!;

          if (totalChannels > 0) {
            if (!amplifierNeeds.containsKey(preferredAmplifier)) {
              amplifierNeeds[preferredAmplifier!] = {};
            }
            int numAmps = (count / totalChannels).ceil();
            amplifierNeeds[preferredAmplifier!]![speakerName] = numAmps;
          }
        } else {
          // Logique optimisée pour la sélection d'amplis
          Map<String, int> optimalConfig = {};
          int remainingSpeakers = count;

          // Vérifier d'abord si un LA4X peut tout gérer
          if (amplificationData[speakerName]!.containsKey('LA4X')) {
            final la4xData = amplificationData[speakerName]!['LA4X']!;
            final int la4xTotal = la4xData['total']!;
            if (la4xTotal > 0 && count <= la4xTotal) {
              optimalConfig['LA4X'] = 1;
              remainingSpeakers = 0;
            }
          }

          // Si un LA4X ne suffit pas, essayer avec LA12X
          if (remainingSpeakers > 0 &&
              amplificationData[speakerName]!.containsKey('LA12X')) {
            final la12xData = amplificationData[speakerName]!['LA12X']!;
            final int la12xTotal = la12xData['total']!;
            if (la12xTotal > 0) {
              int numLA12X = (remainingSpeakers / la12xTotal).floor();
              if (numLA12X > 0) {
                optimalConfig['LA12X'] = numLA12X;
                remainingSpeakers -= numLA12X * la12xTotal;
              }
            }
          }

          // Ensuite avec LA8
          if (remainingSpeakers > 0 &&
              amplificationData[speakerName]!.containsKey('LA8')) {
            final la8Data = amplificationData[speakerName]!['LA8']!;
            final int la8Total = la8Data['total']!;
            if (la8Total > 0) {
              int numLA8 = (remainingSpeakers / la8Total).floor();
              if (numLA8 > 0) {
                optimalConfig['LA8'] = numLA8;
                remainingSpeakers -= numLA8 * la8Total;
              }
            }
          }

          // Enfin avec LA4X pour le reste
          if (remainingSpeakers > 0 &&
              amplificationData[speakerName]!.containsKey('LA4X')) {
            final la4xData = amplificationData[speakerName]!['LA4X']!;
            final int la4xTotal = la4xData['total']!;
            if (la4xTotal > 0) {
              int numLA4X = (remainingSpeakers / la4xTotal).ceil();
              if (numLA4X > 0) {
                optimalConfig['LA4X'] = (optimalConfig['LA4X'] ?? 0) + numLA4X;
              }
            }
          }

          // Ajouter la configuration optimale
          for (var amp in optimalConfig.entries) {
            if (!amplifierNeeds.containsKey(amp.key)) {
              amplifierNeeds[amp.key] = {};
            }
            amplifierNeeds[amp.key]![speakerName] = amp.value;
          }
        }
      }
    }

    // Construction du message de résultat
    String resultMessage = 'Configuration d\'amplification recommandée :\n\n';

    if (amplifierNeeds.isEmpty) {
      resultMessage =
          'Aucune configuration optimale trouvée pour cette combinaison d\'enceintes.\n';
      resultMessage += 'Veuillez vérifier les compatibilités.';
    } else {
      // Priorité des amplis : LA4X > LA8 > LA12X
      final priorityOrder = ['LA4X', 'LA8', 'LA12X'];

      for (var ampType in priorityOrder) {
        if (amplifierNeeds.containsKey(ampType)) {
          final speakers = amplifierNeeds[ampType]!;
          if (speakers.isNotEmpty) {
            // Trouver le nombre maximum d'amplis nécessaires pour ce type
            int maxAmps = 0;
            for (var speaker in speakers.entries) {
              maxAmps = maxAmps < speaker.value ? speaker.value : maxAmps;
            }

            // Construction de la ligne pour ce type d'ampli
            resultMessage += '$maxAmps x $ampType (';
            final speakerDetails = speakers.entries
                .map((speaker) =>
                    '${speakerCount[speaker.key]} x ${speaker.key}')
                .join(' ; ');
            resultMessage += '$speakerDetails)\n';
          }
        }
      }
    }

    setState(() {
      calculationResult = resultMessage;
    });
  }

  void _showQuantityDialog(BuildContext context, String speaker) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: Text('${loc.soundPage_quantity} $speaker',
              style: Theme.of(context).textTheme.bodyMedium),
          content: TextField(
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: loc.catalogPage_enterQuantity,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (value) {
              speakerQuantity = int.tryParse(value) ?? 1;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.catalogPage_cancel,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSpeakers.add({
                    'name': speaker,
                    'quantity': speakerQuantity,
                  });
                });
                Navigator.pop(context);
              },
              child: Text(loc.catalogPage_confirm,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PresetWidget(
          onPresetSelected: (preset) {
            setState(() {
              final presets = ref.read(presetProvider);
              final index = presets.indexWhere((p) => p.id == preset.id);
              if (index != -1) {
                ref.read(presetProvider.notifier).selectPreset(index);
              }
            });
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Ligne 1 : Recherche seule
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une enceinte...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        if (value.isEmpty) {
                          searchResults = [];
                        } else {
                          searchResults = ref
                              .watch(catalogueProvider)
                              .where((item) =>
                                  item.categorie == 'Son' &&
                                  (item.marque
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.produit
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2 : Sélection enceinte + ampli préférentiel
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButton<String>(
                          hint: Text('Sélectionner une enceinte',
                              style: Theme.of(context).textTheme.bodyMedium),
                          value: selectedSpeaker,
                          dropdownColor: Colors.black,
                          style: Theme.of(context).textTheme.bodyMedium,
                          isExpanded: true,
                          items: amplificationData.keys.map((String speaker) {
                            return DropdownMenuItem<String>(
                              value: speaker,
                              child: Text(speaker),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _showQuantityDialog(context, newValue);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButton<String>(
                          hint: Text('Ampli préférentiel',
                              style: Theme.of(context).textTheme.bodyMedium),
                          value: preferredAmplifier ?? 'Custom',
                          dropdownColor: Colors.black,
                          style: Theme.of(context).textTheme.bodyMedium,
                          isExpanded: true,
                          items: amplifierTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              preferredAmplifier = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          return InkWell(
                            onTap: () {
                              _showQuantityDialog(context, item.produit);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.marque} - ${item.produit}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    item.sousCategorie,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (selectedSpeakers.isNotEmpty) ...[
                    Text('Enceintes sélectionnées :',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedSpeakers.length,
                      itemBuilder: (context, index) {
                        final speaker = selectedSpeakers[index];
                        return ListTile(
                          title: Row(
                            children: [
                              // Bouton -
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    if (speaker['quantity'] > 1) {
                                      speaker['quantity'] =
                                          (speaker['quantity'] as int) - 1;
                                    }
                                  });
                                },
                              ),
                              // Quantité
                              Text(
                                '${speaker['quantity']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              // Bouton +
                              IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    speaker['quantity'] =
                                        (speaker['quantity'] as int) + 1;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              // Nom de l'enceinte
                              Expanded(
                                child: Text(
                                  speaker['name'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                selectedSpeakers.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Boutons icônes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _calculateAmplification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[900],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(Icons.calculate,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 25),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedSpeakers.clear();
                              calculationResult = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[900],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(Icons.refresh,
                              color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ],
                  if (calculationResult != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128).withOpacity(0.3),
                        border: Border.all(
                            color: const Color(0xFF0A1128), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        calculationResult!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CalculProjectTab extends ConsumerWidget {
  const CalculProjectTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final preset = ref.watch(presetProvider.notifier).activePreset;

    return Center(
      child: preset == null
          ? Text(loc.projectCalculationPage_noPresetSelected)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.projectCalculationPage_powerProject,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${loc.projectCalculationPage_powerConsumption}: '
                  '${preset.items.fold<double>(0, (sum, item) => sum + (double.tryParse(item.item.conso) ?? 0))} W',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  '${loc.projectCalculationPage_weight}: '
                  '${preset.items.fold<double>(0, (sum, item) => sum + (double.tryParse(item.item.poids) ?? 0))} kg',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
    );
  }
}
