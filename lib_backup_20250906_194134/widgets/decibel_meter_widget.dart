import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class DecibelMeterWidget extends StatefulWidget {
  final double minDb;
  final double maxDb;
  final Duration samplingInterval;

  const DecibelMeterWidget({
    super.key,
    this.minDb = 30.0,
    this.maxDb = 120.0,
    this.samplingInterval = const Duration(milliseconds: 50),
  });

  @override
  State<DecibelMeterWidget> createState() => _DecibelMeterWidgetState();
}

class _DecibelMeterWidgetState extends State<DecibelMeterWidget> {
  double _currentDb = 30.0;
  double _offset = 0.0;
  String _weighting = 'A';
  String _measurementMode = 'Normal';
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  bool _isRecording = false;
  bool _hasPermission = false;
  String _errorMessage = '';
  final List<double> _lastValues = [];
  double _peakValue = 0.0;
  double _averageValue = 0.0;
  Timer? _updateTimer;

  // Constantes de calibration ajustées
  static const double _baseLevel = 35.0; // Niveau de base pour un environnement calme
  static const double _calibrationFactor = 1.2; // Facteur de calibration plus doux
  static const double _noiseFloor = 30.0; // Seuil minimum de bruit

  @override
  void initState() {
    super.initState();
    _initializeNoiseMeter();
  }

  Future<void> _initializeNoiseMeter() async {
    try {
      _noiseMeter = NoiseMeter();
      await _checkAndRequestPermission();
    } catch (e) {
      print('Erreur initialisation: $e');
      setState(() {
        _errorMessage = 'Erreur d\'initialisation: $e';
      });
    }
  }

  Future<void> _checkAndRequestPermission() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
          _errorMessage = '';
        });
        _startRecording();
      } else if (status.isDenied) {
        final result = await Permission.microphone.request();
        if (result.isGranted) {
          setState(() {
            _hasPermission = true;
            _errorMessage = '';
          });
          _startRecording();
        } else {
          setState(() {
            _hasPermission = false;
            _errorMessage = 'Permission du microphone refusée';
          });
        }
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _errorMessage = 'Permission du microphone désactivée dans les paramètres';
        });
      }
    } catch (e) {
      print('Erreur permission: $e');
      setState(() {
        _errorMessage = 'Erreur de permission: $e';
      });
    }
  }

  void _startRecording() {
    try {
      _noiseSubscription?.cancel();
      _noiseSubscription = _noiseMeter?.noise.listen(
        onData,
        onError: onError,
        cancelOnError: false,
      );
      
      // Mise à jour plus fréquente de l'UI
      _updateTimer?.cancel();
      _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {
        _isRecording = true;
        _errorMessage = '';
      });
    } catch (err) {
      print('Erreur démarrage: $err');
      setState(() {
        _isRecording = false;
        _errorMessage = 'Erreur lors du démarrage: $err';
      });
    }
  }

  void onData(NoiseReading noiseReading) {
    if (!mounted) return;
    
    try {
      // Lecture de la valeur brute
      double rawDb = noiseReading.meanDecibel;
      
      // Application du seuil minimum
      if (rawDb < _noiseFloor) {
        rawDb = _noiseFloor;
      }

      // Nouvelle formule de calibration plus douce
      double calibratedDb = _baseLevel + (rawDb - _noiseFloor) * _calibrationFactor;
      
      // Ajout de l'offset utilisateur
      calibratedDb += _offset;

      // Limite les valeurs à la plage définie
      calibratedDb = calibratedDb.clamp(widget.minDb, widget.maxDb);

      setState(() {
        _currentDb = calibratedDb;
        
        _lastValues.add(_currentDb);
        if (_lastValues.length > 10) {
          _lastValues.removeAt(0);
        }
        
        if (_lastValues.isNotEmpty) {
          _peakValue = _lastValues.reduce(max);
          _averageValue = _lastValues.reduce((a, b) => a + b) / _lastValues.length;

          // Debug print pour voir les valeurs
          print('Raw: ${noiseReading.meanDecibel}, Calibrated: $calibratedDb, Peak: $_peakValue');
        }
      });
    } catch (e) {
      print('Erreur traitement données: $e');
    }
  }

  void onError(Object error) {
    if (!mounted) return;
    print('Erreur: $error');
    setState(() {
      _isRecording = false;
      _errorMessage = 'Erreur du décibelmètre: $error';
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _noiseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond avec image
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
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (!_hasPermission)
                  ElevatedButton(
                    onPressed: _checkAndRequestPermission,
                    child: const Text('Autoriser l\'accès au microphone'),
                  ),
                if (_hasPermission) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white.withOpacity(0.15)
                          : Theme.of(context).extension<ResultContainerTheme>()?.backgroundColor ?? const Color(0xFF1A237E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: _buildGauge(small: true),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getDisplayValue(),
                                style: TextStyle(
                                  fontFamily: 'Orbitron-VariableFont_wght',
                                  fontSize: 35,
                                  color: const Color(0xFF00FF00),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.greenAccent.withOpacity(0.7),
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'dB',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron-VariableFont_wght',
                                    fontSize: 11,
                                    color: const Color(0xFF00FF00),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.greenAccent.withOpacity(0.7),
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Affichage : ',
                              style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle ?? 
                                     const TextStyle(color: Colors.white)
                            ),
                            DropdownButton<String>(
                              dropdownColor: const Color(0xFF12325F),
                              value: _measurementMode,
                              style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle ?? 
                                     const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'Moyenne', child: Text('Moy.')),
                                DropdownMenuItem(value: 'Pic 3s', child: Text('Pic')),
                                DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                              ],
                              onChanged: (mode) => setState(() => _measurementMode = mode!),
                            ),
                          ],
                        ),
                        const Divider(height: 8, color: Colors.white54),
                        _buildSettings(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGauge({bool small = false}) {
    double value = _currentDb + _offset;
    switch (_measurementMode) {
      case 'Pic 3s':
        value = _peakValue + _offset;
        break;
      case 'Moyenne':
        value = _averageValue + _offset;
        break;
      default:
        value = _currentDb + _offset;
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: CustomPaint(
        painter: _VintageGaugePainter(value, widget.minDb, widget.maxDb),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${value.toStringAsFixed(1)} dB',
              style: TextStyle(
                fontSize: small ? 16 : 24,
                fontFamily: 'Serif',
                color: Colors.black,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalDisplay({bool small = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getDisplayValue(),
            style: TextStyle(
              fontSize: small ? 28 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Monospace',
            ),
          ),
          Text(
            'dB',
            style: TextStyle(
              fontSize: small ? 14 : 24,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayValue() {
    double value = _currentDb + _offset;
    switch (_measurementMode) {
      case 'Pic 3s':
        value = _peakValue + _offset;
        break;
      case 'Moyenne':
        value = _averageValue + _offset;
        break;
      default:
        value = _currentDb + _offset;
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Offset (dB)', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  activeColor: const Color(0xFFD4A373),
                  inactiveColor: Colors.white30,
                  min: -20,
                  max: 20,
                  divisions: 40,
                  value: _offset,
                  label: _offset.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _offset = v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Poids', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                dropdownColor: const Color(0xFF12325F),
                value: _weighting,
                style: const TextStyle(color: Colors.white),
                isDense: true,
                items: ['A', 'C']
                    .map((w) => DropdownMenuItem(
                          value: w,
                          child: Text('Poids $w',
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (w) => setState(() => _weighting = w!),
              ),
              const Spacer(),
              Text('Min ${widget.minDb.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const Text('dB',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 6),
              Text('Max ${widget.maxDb.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const Text('dB',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VintageGaugePainter extends CustomPainter {
  final double db;
  final double minDb;
  final double maxDb;

  _VintageGaugePainter(this.db, this.minDb, this.maxDb);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.6; // Augmenté de 30%

    // Cadre laiton
    final brassPaint = Paint()..color = const Color(0xFFD4A373);
    canvas.drawCircle(center, radius + 6, brassPaint);

    // Cadran ivoire
    final dialPaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawCircle(center, radius, dialPaint);

    // Ticks et chiffres
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    const tickCount = 12;
    for (var i = 0; i <= tickCount; i++) {
      final angle = pi * 3 / 4 + (pi * 3 / 2) * (i / tickCount);
      final outer = center + Offset(cos(angle), sin(angle)) * radius;
      final inner = center + Offset(cos(angle), sin(angle)) * (radius - 12);
      canvas.drawLine(outer, inner, tickPaint);
      final val = (minDb + (maxDb - minDb) * (i / tickCount)).round();
      textPainter.text = TextSpan(
          text: '$val',
          style: const TextStyle(fontSize: 10, color: Colors.black87));
      textPainter.layout();
      final pos = center +
          Offset(cos(angle), sin(angle)) * (radius - 24) -
          Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, pos);
    }

    // Aiguille
    final needlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3;
    final needleAngle =
        pi * 3 / 4 + (pi * 3 / 2) * ((db - minDb) / (maxDb - minDb));
    final needleEnd =
        center + Offset(cos(needleAngle), sin(needleAngle)) * (radius - 20);
    canvas.drawLine(center, needleEnd, needlePaint);

    // Bouton central
    canvas.drawCircle(center, 5, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
