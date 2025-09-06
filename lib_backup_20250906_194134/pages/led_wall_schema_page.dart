import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/catalogue_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';

class LedWallSchemaPage extends ConsumerStatefulWidget {
  const LedWallSchemaPage({super.key});

  @override
  ConsumerState<LedWallSchemaPage> createState() => _LedWallSchemaPageState();
}

class _LedWallSchemaPageState extends ConsumerState<LedWallSchemaPage> {
  int width = 1;
  int height = 1;
  String? selectedPanel;
  List<List<String>> wall = [];
  String? calculationResult;

  @override
  void initState() {
    super.initState();
    _initializeWall();
  }

  void _initializeWall() {
    wall = List.generate(height, (_) => List.filled(width, ''));
  }

  List<CatalogueItem> get _availablePanels {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' && item.sousCategorie == 'Écrans')
        .toList();
  }

  void _updateWall() {
    setState(() {
      wall = List.generate(height, (_) => List.filled(width, ''));
    });
  }

  void _calculateWall() {
    if (selectedPanel == null) {
      setState(() {
        calculationResult = 'Veuillez sélectionner un panneau LED';
      });
      return;
    }

    final panel = _availablePanels.firstWhere(
      (item) => item.produit == selectedPanel,
      orElse: () => throw Exception('Panneau non trouvé'),
    );

    final dimensions = panel.dimensions.split('x');
    if (dimensions.length != 2) {
      setState(() {
        calculationResult = 'Format de dimensions invalide pour le panneau';
      });
      return;
    }

    final panelWidth = double.tryParse(dimensions[0].trim()) ?? 0;
    final panelHeight = double.tryParse(dimensions[1].trim()) ?? 0;

    if (panelWidth == 0 || panelHeight == 0) {
      setState(() {
        calculationResult = 'Dimensions du panneau invalides';
      });
      return;
    }

    final totalWidth = panelWidth * width;
    final totalHeight = panelHeight * height;
    final totalPanels = width * height;
    final totalWeight = (double.tryParse(panel.poids) ?? 0) * totalPanels;
    final totalPower = (double.tryParse(panel.conso) ?? 0) * totalPanels;

    setState(() {
      calculationResult = '''
Dimensions totales : ${totalWidth.toStringAsFixed(2)}m x ${totalHeight.toStringAsFixed(2)}m
Nombre de panneaux : $totalPanels
Poids total : ${totalWeight.toStringAsFixed(2)} kg
Consommation totale : ${totalPower.toStringAsFixed(2)} W
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final panels = _availablePanels;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.ledWallSchemaPage_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withValues(alpha: 77),
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.ledWallSchemaPage_dimensions,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.ledWallSchemaPage_width,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Slider(
                              value: width.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: width.toString(),
                              onChanged: (value) {
                                setState(() {
                                  width = value.toInt();
                                  _updateWall();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.ledWallSchemaPage_height,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Slider(
                              value: height.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: height.toString(),
                              onChanged: (value) {
                                setState(() {
                                  height = value.toInt();
                                  _updateWall();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withValues(alpha: 77),
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.ledWallSchemaPage_panelSelection,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedPanel,
                    hint: Text(
                      loc.ledWallSchemaPage_selectPanel,
                      style: const TextStyle(color: Colors.white),
                    ),
                    isExpanded: true,
                    dropdownColor: Colors.blueGrey[900],
                    style: const TextStyle(color: Colors.white),
                    items: panels.map((panel) {
                      return DropdownMenuItem<String>(
                        value: panel.produit,
                        child: Text(panel.produit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPanel = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _calculateWall,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF0A1128).withValues(alpha: 128),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.ledWallSchemaPage_calculate,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (calculationResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withValues(alpha: 128),
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  calculationResult!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LedWallPainter extends CustomPainter {
  final double largeurTotale;
  final double hauteurTotale;
  final int nbDallesLargeur;
  final int nbDallesHauteur;
  final String? selectedProduct;
  final String resolutionDalle;

  LedWallPainter({
    required this.largeurTotale,
    required this.hauteurTotale,
    required this.nbDallesLargeur,
    required this.nbDallesHauteur,
    this.selectedProduct,
    required this.resolutionDalle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 26)
      ..style = PaintingStyle.fill;

    // Calcul des dimensions
    final dalleWidth = size.width / nbDallesLargeur;
    final dalleHeight = size.height / nbDallesHauteur;

    // Dessin des dalles
    for (int y = 0; y < nbDallesHauteur; y++) {
      for (int x = 0; x < nbDallesLargeur; x++) {
        final rect = Rect.fromLTWH(
          x * dalleWidth,
          y * dalleHeight,
          dalleWidth,
          dalleHeight,
        );
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
