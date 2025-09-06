import 'package:flutter/material.dart';

/// Page de calculs électrique
class CalculationPage extends StatefulWidget {
  const CalculationPage({super.key});

  static const routeName = '/calculations';

  @override
  _CalculationPageState createState() => _CalculationPageState();
}

class _CalculationPageState extends State<CalculationPage> {
  // Module P = U * I
  double _voltage = 230.0;
  double _current = 10.0;
  double get _power => _voltage * _current;

  // Module section de câble
  double _intensity = 10.0;
  double _length = 10.0;
  double get _cableSection {
    // Formule simplifiée: S = (I * L) / (k * dU)
    // k = conductivité (ex: 56), dU tolérance (ex: 5V)
    const double k = 56;
    const double dU = 5;
    return (_intensity * _length) / (k * dU);
  }

  // Module conversion kW <-> kVA
  double _kw = 1.0;
  double _pf = 0.8;
  double get _kva => _kw / _pf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculs Électriques'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module P = U * I
            const Text('Calcul Puissance P = U × I',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPowerCalculator(),
            const Divider(height: 32),
            // Module section de câble
            const Text('Section de câble',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCableSectionCalculator(),
            const Divider(height: 32),
            // Module conversion kW ↔ kVA
            const Text('Conversion kW ↔ kVA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPowerConversion(),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildNumberInput(
              label: 'Tension U (V)',
              value: _voltage,
              min: 0,
              max: 400,
              onChanged: (v) => setState(() => _voltage = v),
            ),
            _buildNumberInput(
              label: 'Intensité I (A)',
              value: _current,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _current = v),
            ),
            const SizedBox(height: 8),
            Text('Puissance P = ${_power.toStringAsFixed(1)} W'),
          ],
        ),
      ),
    );
  }

  Widget _buildCableSectionCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildNumberInput(
              label: 'Intensité I (A)',
              value: _intensity,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _intensity = v),
            ),
            _buildNumberInput(
              label: 'Longueur L (m)',
              value: _length,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _length = v),
            ),
            const SizedBox(height: 8),
            Text('Section S ≈ ${_cableSection.toStringAsFixed(3)} mm²'),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerConversion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildNumberInput(
              label: 'Puissance (kW)',
              value: _kw,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _kw = v),
            ),
            _buildNumberInput(
              label: 'Facteur de puissance (cos φ)',
              value: _pf,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: (v) => setState(() => _pf = v),
            ),
            const SizedBox(height: 8),
            Text('Apparente = ${_kva.toStringAsFixed(2)} kVA'),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
