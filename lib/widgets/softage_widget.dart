import 'package:flutter/material.dart';

/// Page de rendu vidéo avec calcul SoftEdge et Optique
class RenduPage extends StatefulWidget {
  const RenduPage({super.key});

  static const routeName = '/rendu';

  @override
  _RenduPageState createState() => _RenduPageState();
}

class _RenduPageState extends State<RenduPage> {
  // Paramètres SoftEdge
  double _imageWidth = 5.0;
  double _overlapWidth = 1.0;
  int _projectorCount = 2;

  // Paramètre optique
  double _throwDistance = 10.0; // distance unique projeteur-écran en mètres

  double get _totalProjectedWidth =>
      _imageWidth * _projectorCount - _overlapWidth * (_projectorCount - 1);

  double get _overlapPercent => (_overlapWidth / _imageWidth) * 100;

  double get _throwRatio => _throwDistance / _imageWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Rendu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calcul SoftEdge',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Largeur image par projecteur : ${_imageWidth.toStringAsFixed(1)} m'),
            Slider(
              min: 1,
              max: 15,
              divisions: 28,
              value: _imageWidth,
              label: '${_imageWidth.toStringAsFixed(1)} m',
              onChanged: (v) => setState(() => _imageWidth = v),
            ),
            Text('Chevauchement : ${_overlapWidth.toStringAsFixed(1)} m'),
            Slider(
              min: 0.1,
              max: _imageWidth / 2,
              divisions: 20,
              value: _overlapWidth,
              label: '${_overlapWidth.toStringAsFixed(1)} m',
              onChanged: (v) => setState(() => _overlapWidth = v),
            ),
            Row(
              children: [
                const Text('Projecteurs :'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _projectorCount,
                  items: List.generate(5, (i) => i + 2)
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                  onChanged: (v) => setState(() => _projectorCount = v!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Largeur totale projetée : ${_totalProjectedWidth.toStringAsFixed(2)} m'),
                    Text('Overlap : ${_overlapPercent.toStringAsFixed(1)} %'),
                    Text(
                      _overlapPercent < 10
                          ? '⚠️ Overlap trop faible'
                          : '✅ Overlap suffisant',
                      style: TextStyle(
                          color:
                              _overlapPercent < 10 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            const Text('Calcul Optique',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Distance projecteur-écran : ${_throwDistance.toStringAsFixed(1)} m'),
            Slider(
              min: 1,
              max: 20,
              divisions: 19,
              value: _throwDistance,
              label: '${_throwDistance.toStringAsFixed(1)} m',
              onChanged: (v) => setState(() => _throwDistance = v),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Throw Ratio : ${_throwRatio.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    Text(
                      'Objectif recommandé : ${_recommendLens(_throwRatio)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  String _recommendLens(double ratio) {
    if (ratio < 1) return 'Ultra-court (0.8 - 1.0)';
    if (ratio <= 1.5) return 'Court (1.0 - 1.5)';
    if (ratio <= 2.0) return 'Standard (1.5 - 2.0)';
    return 'Long (2.0+)';
  }
}
