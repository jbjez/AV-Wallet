import 'package:flutter/material.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../../widgets/uniform_dropdown.dart';

class DriverTab extends StatefulWidget {
  const DriverTab({super.key});

  @override
  State<DriverTab> createState() => _DriverTabState();
}

class _DriverTabState extends State<DriverTab> {
  int tension = 24;
  int nbVoies = 4;
  double ampereParVoie = 5.0;
  String selectedDriver = 'S04x5A';
  double longueurLed = 5.0;
  String typeStripLed = 'RGB';
  double conso = 14.4; // W/m
  String? driverCalculationResult;

  final Map<String, Map<String, dynamic>> drivers = {
    'S04x5A': {'voies': 4, 'ampere': 5.0},
    'S04x10A': {'voies': 4, 'ampere': 10.0},
    'S05x6A': {'voies': 5, 'ampere': 6.0},
    'S32x3A': {'voies': 32, 'ampere': 3.0},
  };

  final List<String> stripTypes = ['RGB', 'RGBW', 'RGBWW', 'WW', 'CW', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Configuration Driver
          Container(
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
                  loc.driverConfiguration,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Première ligne: Tension et Nombre de voies
                Row(
                  children: [
                    Expanded(
                      child: UniformDropdown(
                        value: '$tension ${loc.volts}',
                        hintText: loc.voltage,
                        items: [9, 12, 24].map((v) => '$v ${loc.volts}').toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            tension = int.parse(newValue!.replaceAll(' ${loc.volts}', ''));
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: UniformDropdown(
                        value: '$nbVoies ${nbVoies == 1 ? loc.channel : loc.channelsPlural}',
                        hintText: loc.channels,
                        items: List.generate(5, (i) => '${i + 1} ${i == 0 ? loc.channel : loc.channelsPlural}'),
                        onChanged: (String? newValue) {
                          setState(() {
                            nbVoies = int.parse(newValue!.split(' ')[0]);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Deuxième ligne: Ampères par voie et Type de driver
                Row(
                  children: [
                    Expanded(
                      child: UniformDropdown(
                        value: '${ampereParVoie.toInt()} ${loc.amperes}',
                        hintText: loc.amperePerChannel,
                        items: List.generate(10, (i) => '${i + 1} ${loc.amperes}'),
                        onChanged: (String? newValue) {
                          setState(() {
                            ampereParVoie = double.parse(newValue!.replaceAll(' ${loc.amperes}', ''));
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: UniformDropdown(
                        value: selectedDriver,
                        hintText: loc.driverType,
                        items: drivers.keys.toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDriver = newValue!;
                            final driver = drivers[newValue]!;
                            nbVoies = driver['voies'];
                            ampereParVoie = driver['ampere'];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Configuration Strip LED
          Container(
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
                  loc.stripLedConfiguration,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Type de strip LED
                UniformDropdown(
                  value: typeStripLed,
                  hintText: loc.stripLedType,
                  items: stripTypes,
                  onChanged: (String? newValue) {
                    setState(() {
                      typeStripLed = newValue!;
                      _updateConsumption();
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Longueur LED
                Text(
                  '${loc.length}: ${longueurLed.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Slider(
                  min: 1,
                  max: 100,
                  divisions: 99,
                  value: longueurLed,
                  label: '${longueurLed.round()} m',
                  onChanged: (value) {
                    setState(() {
                      longueurLed = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Consommation
                Text(
                  '${loc.consumption}: ${conso.toStringAsFixed(1)} W/m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Slider(
                  min: 5,
                  max: 50,
                  divisions: 45,
                  value: conso,
                  label: '${conso.round()} W/m',
                  onChanged: (value) {
                    setState(() {
                      conso = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton calcul
          Center(
            child: ElevatedButton(
              onPressed: _calculateDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                side: const BorderSide(color: Color(0xFF1976D2), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                loc.calculateDriverConfig,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Résultat du calcul
          if (driverCalculationResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withOpacity(0.5),
                border: Border.all(color: Colors.green, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.recommendedConfiguration,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driverCalculationResult!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _updateConsumption() {
    switch (typeStripLed) {
      case 'RGB':
        conso = 14.4;
        break;
      case 'RGBW':
        conso = 18.0;
        break;
      case 'RGBWW':
        conso = 21.6;
        break;
      case 'WW':
        conso = 12.0;
        break;
      case 'CW':
        conso = 9.6;
        break;
      case 'Custom':
        conso = 15.0;
        break;
    }
  }

  void _calculateDriver() {
    // Calcul de la puissance totale du driver
    double puissanceDriver = nbVoies * ampereParVoie * tension;
    
    // Calcul de la longueur maximale par driver
    double longueurMaxParDriver = puissanceDriver / conso;
    
    // Calcul du nombre de drivers nécessaires
    int nbDrivers = (longueurLed / longueurMaxParDriver).ceil();
    
    String result = 'Configuration Driver LED:\n\n';
    result += 'Strip LED: $typeStripLed\n';
    result += 'Longueur: ${longueurLed.toStringAsFixed(1)} m\n';
    result += 'Puissance: ${conso.toStringAsFixed(1)} W/m\n\n';
    
    result += 'Driver: $selectedDriver\n';
    result += 'Longueur max par driver: ${longueurMaxParDriver.toStringAsFixed(1)} m\n';
    result += 'Nb de driver $selectedDriver requis: $nbDrivers';

    setState(() {
      driverCalculationResult = result;
    });
  }
}
