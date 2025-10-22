import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
// import 'package:av_wallet/l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';

class ProjectionSchemaPage extends StatelessWidget {
  final double largeurTotale;
  final double hauteurTotale;
  final int nbProjecteurs;
  final double chevauchement;
  final double largeurParProjecteur;
  final double ratio;
  final String? optiqueRecommandee;
  final String? selectedProduct;

  const ProjectionSchemaPage({
    super.key,
    required this.largeurTotale,
    required this.hauteurTotale,
    required this.nbProjecteurs,
    required this.chevauchement,
    required this.largeurParProjecteur,
    required this.ratio,
    this.optiqueRecommandee,
    this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.videocam,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  // Titre
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Text(
                      'Softage $nbProjecteurs x ${selectedProduct ?? "Projecteur"}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Schéma du mur LED
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: 16 / 6.3,
                      child: CustomPaint(
                        painter: ProjectionPainter(
                          largeurTotale: largeurTotale,
                          hauteurTotale: hauteurTotale,
                          nbProjecteurs: nbProjecteurs,
                          chevauchement: chevauchement,
                          largeurParProjecteur: largeurParProjecteur,
                          ratio: ratio,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Informations détaillées
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900]?.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Largeur totale: ${largeurTotale.toStringAsFixed(2)} m',
                            style: const TextStyle(color: Colors.black)),
                        Text(
                            'Hauteur totale: ${hauteurTotale.toStringAsFixed(2)} m',
                            style: const TextStyle(color: Colors.black)),
                        Text('Nombre de projecteurs: $nbProjecteurs',
                            style: const TextStyle(color: Colors.black)),
                        Text(
                            'Chevauchement: ${chevauchement.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.black)),
                        Text(
                            'Largeur par projecteur: ${largeurParProjecteur.toStringAsFixed(2)} m',
                            style: const TextStyle(color: Colors.black)),
                        Text('Ratio: ${ratio.toStringAsFixed(2)}:1',
                            style: const TextStyle(color: Colors.black)),
                        if (optiqueRecommandee != null)
                          Text('Optique recommandée: $optiqueRecommandee',
                              style: const TextStyle(color: Colors.black)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implémenter l'export PDF
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exporter en PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
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
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => pages[index],
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.list), label: loc.catalogAccess),
          BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb), label: loc.lightMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_tree), label: loc.structureMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.volume_up), label: loc.soundMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.videocam), label: loc.videoMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bolt), label: loc.electricityMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz), label: loc.networkMenu),
        ],
      ),
    );
  }
}

class ProjectionPainter extends CustomPainter {
  final double largeurTotale;
  final double hauteurTotale;
  final int nbProjecteurs;
  final double chevauchement;
  final double largeurParProjecteur;
  final double ratio;

  ProjectionPainter({
    required this.largeurTotale,
    required this.hauteurTotale,
    required this.nbProjecteurs,
    required this.chevauchement,
    required this.largeurParProjecteur,
    required this.ratio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calcul des dimensions
    final schemaWidth = size.width * 0.9;
    final schemaHeight = size.height * 0.8;
    final xOffset = (size.width - schemaWidth) / 2;
    final yOffset = (size.height - schemaHeight) / 2;

    // Dessin du rectangle principal
    canvas.drawRect(
      Rect.fromLTWH(xOffset, yOffset, schemaWidth, schemaHeight),
      paint,
    );

    // Dessin des projecteurs
    final largeurProjecteur = schemaWidth / nbProjecteurs;
    final hauteurProjecteur = schemaHeight;

    for (int i = 0; i < nbProjecteurs; i++) {
      final x = xOffset + (i * largeurProjecteur);
      final rect =
          Rect.fromLTWH(x, yOffset, largeurProjecteur, hauteurProjecteur);
      canvas.drawRect(rect, paint);

      // Dessin du chevauchement
      if (i < nbProjecteurs - 1) {
        final overlapWidth = largeurProjecteur * (chevauchement / 100);
        final overlapRect = Rect.fromLTWH(
          x + largeurProjecteur - overlapWidth,
          yOffset,
          overlapWidth * 2,
          hauteurProjecteur,
        );
        final hatchPaint = Paint()
          ..color = Colors.blue.withValues(alpha: 77)
          ..style = PaintingStyle.fill;
        canvas.drawRect(overlapRect, hatchPaint);
      }
    }

    // Ajout des dimensions
    textPainter.text = TextSpan(
      text: '${largeurTotale.toStringAsFixed(1)}m',
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            xOffset + schemaWidth / 2 - textPainter.width / 2, yOffset - 20));

    textPainter.text = TextSpan(
      text: '${hauteurTotale.toStringAsFixed(1)}m',
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(xOffset - 30,
            yOffset + hauteurProjecteur / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
