import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../../pages/ar_measure_page.dart';
import '../action_button.dart';
import '../comment_button.dart';
import '../export_widget.dart';

class BeamTab extends StatefulWidget {
  const BeamTab({super.key});

  @override
  State<BeamTab> createState() => _BeamTabState();
}

class _BeamTabState extends State<BeamTab> {
  double angle = 35;
  double height = 10;
  double distance = 20;
  String? beamCalculationResult;
  bool isCalculated = false; // État du bouton calcul/reset

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.beamCalculation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Angle du faisceau
            Text(
              '${loc.lightPage_angleRange}: ${angle.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            Slider(
              value: angle,
              min: 1,
              max: 70,
              divisions: 69,
              label: '${angle.round()}°',
              onChanged: (value) => setState(() => angle = value),
            ),
            
            const SizedBox(height: 16),
            
            // Hauteur
            Text(
              '${loc.lightPage_heightRange}: ${height.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            Slider(
              min: 1,
              max: 20,
              divisions: 19,
              value: height,
              label: '${height.round()}m',
              onChanged: (value) => setState(() => height = value),
            ),
            
            const SizedBox(height: 16),
            
            // Distance
            Text(
              '${loc.lightPage_distanceRange}: ${distance.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            Slider(
              min: 1,
              max: 40,
              divisions: 39,
              value: distance,
              label: '${distance.round()}m',
              onChanged: (value) => setState(() => distance = value),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  icon: Icons.camera_alt,
                  onPressed: () => _navigateTo(const ArMeasurePage()),
                  iconSize: 28,
                ),
                const SizedBox(width: 25),
                ActionButton(
                  icon: isCalculated ? Icons.refresh : Icons.calculate,
                  onPressed: isCalculated ? _resetCalculation : _calculateBeam,
                  iconSize: 28,
                ),
                const SizedBox(width: 25),
                ActionButton(
                  icon: Icons.refresh,
                  onPressed: () {
                    setState(() {
                      angle = 35;
                      height = 10;
                      distance = 20;
                      beamCalculationResult = null;
                      isCalculated = false;
                    });
                  },
                  iconSize: 28,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Résultat du calcul
            if (beamCalculationResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.5),
                  border: Border.all(color: const Color(0xFF0A1128), width: 1),
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
                      beamCalculationResult!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Boutons d'action pour le résultat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Widget Commentaire
                        CommentButton(
                          commentKey: 'beam_calculation_${DateTime.now().millisecondsSinceEpoch}',
                          dialogTitle: 'Commentaire Faisceau',
                          tabName: 'Faisceau',
                          showCommentFrame: true,
                          commentFrameSpacing: 10,
                        ),
                        const SizedBox(width: 20),
                        // Bouton Export
                        ExportWidget(
                          title: 'Calcul Faisceau',
                          content: beamCalculationResult!,
                          projectType: 'faisceau',
                          fileName: 'calcul_faisceau',
                          customIcon: Icons.cloud_upload,
                          backgroundColor: Colors.blueGrey[900],
                          tooltip: 'Exporter le calcul',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _calculateBeam() {
    final loc = AppLocalizations.of(context)!;
    
    // Calcul du diamètre du faisceau
    double diameter = 2 * distance * (angle * 3.14159 / 180) / 2;
    
    setState(() {
      beamCalculationResult = '${loc.lightPage_beamDiameter}: ${diameter.toStringAsFixed(2)} ${loc.lightPage_meters}';
      isCalculated = true;
    });
  }

  void _resetCalculation() {
    setState(() {
      beamCalculationResult = null;
      isCalculated = false;
    });
  }
}
