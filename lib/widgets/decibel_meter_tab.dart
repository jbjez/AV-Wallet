// lib/widgets/decibel_meter_tab.dart
// Lignes 1-400
import 'dart:async';                                    // [1]
import 'dart:math';                                      // [2]
import 'dart:typed_data';                                // [3]
import 'package:flutter/material.dart';                  // [4]
import 'package:permission_handler/permission_handler.dart'; // [5]
import 'package:mic_stream/mic_stream.dart';            // [6]
import '../utils/permissions.dart';                      // [7]

enum DbWeighting { flat, A, C }                          // [8]
enum DbResponse { fast, slow }                           // [9]

class DecibelMeterTab extends StatefulWidget {           // [11]
  const DecibelMeterTab({Key? key}) : super(key: key);   // [12]
  @override
  State<DecibelMeterTab> createState() => _DecibelMeterTabState(); // [14]
}

class _DecibelMeterTabState extends State<DecibelMeterTab> {  // [16]
  StreamSubscription? _micSub;                           // [17]
  double _dbInstant = -120;                              // [18]
  double _dbPeakHold = -120;                             // [19]
  DateTime _peakHoldTs = DateTime.now();                 // [20]
  double _dbLeqEnergy = 0;                               // [21]
  int _leqSamples = 0;                                   // [22]
  bool _running = false;                                 // [23]
  DbWeighting _weighting = DbWeighting.A;                // [24]
  DbResponse _response = DbResponse.fast;                // [25]
  Color _digitColor = const Color(0xFFFF3B30);           // [26] // rouge par défaut
  final ValueNotifier<double> _liveDb = ValueNotifier(-120); // [27] // pour le plein écran

  // Configs de réponse (constantes temps). Fast ≈ 125 ms, Slow ≈ 1 s.     // [29]
  double get _alpha {
    final tau = _response == DbResponse.fast ? 0.125 : 1.0; // seconds       // [30]
    final dt = 0.02; // approx moyenne de frame 20ms                         // [31]
    return 1 - exp(-dt / tau);                                               // [32]
  }

  // Coeffs simples pour pondération A et C via bilinéaire (Fs=44100).       // [34]
  // Ici on applique un IIR d'ordre 2 très standardisé pour une approximation
  // NOTE: ça suffit pour un usage utilitaire (pas de classe 1/2).           // [36]
  Biquad? _biquad;                                                           // [37]

  @override
  void dispose() {                                                           // [39]
    _stop();                                                                 // [40]
    super.dispose();                                                         // [41]
  }

  Future<bool> _ensureMicPermission() async {                                // [43]
    return await AppPermissions.ensureMicrophone();                          // [44]
  }

  void _buildFilter({int sampleRate = 44100}) {                              // [53]
    switch (_weighting) {
      case DbWeighting.flat:
        _biquad = null;                                                      // [56]
        break;
      case DbWeighting.A:
        _biquad = Biquad.aWeighting(sampleRate);                             // [58]
        break;
      case DbWeighting.C:
        _biquad = Biquad.cWeighting(sampleRate);                             // [60]
        break;
    }
  }

  Future<void> _start() async {                                              // [64]
    if (_running) return;                                                    // [65]
    
    // Debug log pour vérifier les permissions
    final micStatus = await Permission.microphone.status;
    debugPrint('MIC status iOS: $micStatus');
    
    if (!await _ensureMicPermission()) return;                               // [66]
    _buildFilter(sampleRate: 44100);                                         // [67]
    _dbInstant = -120;                                                       // [68]
    _dbPeakHold = -120;                                                      // [69]
    _dbLeqEnergy = 0;                                                        // [70]
    _leqSamples = 0;                                                         // [71]

    // Démarre le stream micro (16-bit PCM mono, 44.1kHz si possible)        // [73]
    final stream = await MicStream.microphone(                               // [74]
      audioSource: AudioSource.DEFAULT,                                      // [75]
      sampleRate: 44100,                                                     // [76]
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,                          // [77]
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,                           // [78]
    );

    if (stream == null) {
      debugPrint('Failed to get microphone stream');
      return;
    }

    _running = true;                                                         // [80]
    _micSub = stream.listen(_onAudioData, onError: (e) {                     // [81]
      debugPrint('Mic error: $e');                                           // [82]
      _stop();                                                               // [83]
    });
    setState(() {});                                                         // [85]
  }

  void _stop() {                                                             // [87]
    _micSub?.cancel();                                                       // [88]
    _micSub = null;                                                          // [89]
    _running = false;                                                        // [90]
    setState(() {});                                                         // [91]
  }

  void _onAudioData(dynamic data) {                                          // [93]
    if (data is! Uint8List) return;                                          // [94]
    // Convertit bytes -> int16 -> double [-1;1]                             // [95]
    final bd = data.buffer.asInt16List();                                    // [96]
    if (bd.isEmpty) return;                                                  // [97]

    // Filtrage + calcul RMS instantané (exponentiel)                         // [100]
    double sumSquares = 0;                                                   // [101]
    for (int i = 0; i < bd.length; i++) {                                    // [102]
      final s = (bd[i] / 32768.0);                                           // [103]
      final x = _biquad?.process(s) ?? s;                                    // [104]
      sumSquares += x * x;                                                   // [105]
    }
    final rms = sqrt(sumSquares / bd.length);                                // [107]

    // Convertit en dBFS approx — offset de calibration (SPL) optionnel       // [109]
    const floorDb = -120.0;                                                  // [110]
    double db = 20 * log(rms == 0 ? 1e-12 : rms) / ln10;                     // [111]
    db = db.clamp(floorDb, 0.0);                                             // [112]

    // Lissage (Fast/Slow)                                                    // [114]
    final a = _alpha;                                                         // [115]
    _dbInstant = (1 - a) * _dbInstant + a * db;                               // [116]

    // Peak hold 3s                                                           // [118]
    if (db > _dbPeakHold) {                                                  // [119]
      _dbPeakHold = db;                                                      // [120]
      _peakHoldTs = DateTime.now();                                          // [121]
    } else if (DateTime.now().difference(_peakHoldTs).inMilliseconds > 3000) {
      _dbPeakHold = _dbInstant;                                              // [123]
    }

    // Leq (approx, énergie cumulée)                                          // [125]
    _dbLeqEnergy += pow(10, db / 10);                                        // [126]
    _leqSamples += 1;                                                        // [127]

    _liveDb.value = _dbInstant;                                              // [129]
    if (mounted) setState(() {});                                            // [130]
  }

  String get _weightingLabel {                                               // [132]
    switch (_weighting) {
      case DbWeighting.flat: return 'Flat';                                  // [134]
      case DbWeighting.A:    return 'A';                                     // [135]
      case DbWeighting.C:    return 'C';                                     // [136]
    }
  }

  String get _responseLabel => _response == DbResponse.fast ? 'Fast' : 'Slow'; // [139]

  double get _leqDb {                                                        // [141]
    if (_leqSamples == 0) return -120;                                       // [142]
    final meanEnergy = _dbLeqEnergy / _leqSamples;                           // [143]
    return 10 * log(meanEnergy) / ln10;                                      // [144]
  }

  void _pickColor() async {                                                  // [146]
    final chosen = await showDialog<Color>(                                  // [147]
      context: context,
      builder: (_) => _ColorPickerDialog(initial: _digitColor),
    );
    if (chosen != null) setState(() => _digitColor = chosen);                // [151]
  }

  void _openFullscreen() {                                                   // [153]
    Navigator.of(context).push(MaterialPageRoute(                            // [154]
      builder: (_) => DecibelFullscreenPage(liveDb: _liveDb, digitColor: _digitColor),
    ));
  }

  @override
  Widget build(BuildContext context) {                                       // [160]
    return Column(                                                           // [161]
      children: [
        const SizedBox(height: 8),                                           // [163]
        // Bande outils                                                       // [164]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),             // [166]
          child: Row(
            children: [
              _chip('A', _weighting == DbWeighting.A, () {
                setState(() { _weighting = DbWeighting.A; _buildFilter(); }); // [170]
              }),
              const SizedBox(width: 6),
              _chip('C', _weighting == DbWeighting.C, () {
                setState(() { _weighting = DbWeighting.C; _buildFilter(); }); // [173]
              }),
              const SizedBox(width: 6),
              _chip('Flat', _weighting == DbWeighting.flat, () {
                setState(() { _weighting = DbWeighting.flat; _buildFilter(); });// [176]
              }),
              const Spacer(),
              _chip('Fast', _response == DbResponse.fast, () {
                setState(() {}); _response = DbResponse.fast;                 // [179]
              }),
              const SizedBox(width: 6),
              _chip('Slow', _response == DbResponse.slow, () {
                setState(() {}); _response = DbResponse.slow;                 // [182]
              }),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Plein écran',
                onPressed: _openFullscreen,
                icon: const Icon(Icons.play_circle_fill, color: Colors.white),// [190]
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),                                           // [194]

        // Afficheur numérique                                                // [196]
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),            // [200]
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black,                                         // [203]
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bigDigits('${_dbInstant.toStringAsFixed(1)} dB', _digitColor), // [210]
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniTile('Peak', _dbPeakHold),
                      const SizedBox(width: 16),
                      _miniTile('Leq', _leqDb),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Weight: $_weightingLabel • Resp: $_responseLabel',   // [219]
                      style: const TextStyle(color: Colors.white70, fontSize: 12)), // Réduit de 2 pts (14->12)
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() { _dbPeakHold = _dbInstant; _peakHoldTs = DateTime.now(); }); // [246]
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1128),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Reset Peak',
                          style: TextStyle(fontSize: 10), // Réduit de 2 pts (12->10)
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Couleur des digits',
                        onPressed: _pickColor,
                        icon: const Icon(Icons.color_lens, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Boutons Start/Stop                                     // [225]
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,
                  foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                onPressed: _running ? null : _start,                         // [233]
                child: const Icon(Icons.play_arrow),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,
                  foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                onPressed: _running ? _stop : null,                          // [240]
                child: const Icon(Icons.stop),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniTile(String label, double value) {                             // [254]
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), // Réduit de 40%
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        borderRadius: BorderRadius.circular(6), // Réduit de 40%
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 7)), // Réduit de 40%
          const SizedBox(height: 2), // Réduit de 40%
          Text('${value.isFinite ? value.toStringAsFixed(1) : '-∞'} dB',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)), // Réduit de 40%
        ],
      ),
    );
  }

  Widget _bigDigits(String txt, Color color) {                               // [272]
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        txt,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 100,
          color: color,
          letterSpacing: 1.5,
          shadows: const [
            Shadow(offset: Offset(0, 0), blurRadius: 10, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {             // [289]
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// Page plein écran avec gros afficheur                                       // [304]
class DecibelFullscreenPage extends StatelessWidget {
  final ValueNotifier<double> liveDb;                                        // [306]
  final Color digitColor;                                                    // [307]
  const DecibelFullscreenPage({super.key, required this.liveDb, required this.digitColor}); // [308]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,                                         // [312]
      body: SafeArea(
        child: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: liveDb,
            builder: (_, v, __) => FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '${v.toStringAsFixed(1)} dB',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 160,
                  color: digitColor,
                  letterSpacing: 2,
                  shadows: const [Shadow(blurRadius: 16, color: Colors.redAccent)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------- IIR Biquad + pondérations A/C (approx 44.1 kHz) ---------------- // [330]
class Biquad {                                                               // [331]
  // Direct Form I
  double b0, b1, b2, a0, a1, a2;                                             // [333]
  double x1 = 0, x2 = 0, y1 = 0, y2 = 0;                                     // [334]

  Biquad(this.b0, this.b1, this.b2, this.a0, this.a1, this.a2);              // [336]

  double process(double x) {                                                 // [338]
    final y = (b0/a0)*x + (b1/a0)*x1 + (b2/a0)*x2 - (a1/a0)*y1 - (a2/a0)*y2; // [339]
    x2 = x1; x1 = x; y2 = y1; y1 = y;                                        // [340]
    return y;                                                                // [341]
  }

  // Pondération A (approx)                                                   // [343]
  static Biquad aWeighting(int fs) {
    // Coeffs simples basés sur un modèle bilinéaire pour Fs=44100            // [345]
    // (approximations pratiques pour appli utilitaire)                       // [346]
    // Ces coeffs donnent la courbe A proche (erreur < qq dB typiquement).    // [347]
    return Biquad(
      0.255741125204258, -0.511482250408516, 0.255741125204258,              // b0,b1,b2
      1.0, -1.69065929318241, 0.73248077421585,                              // a0,a1,a2
    );
  }

  // Pondération C (approx)                                                   // [353]
  static Biquad cWeighting(int fs) {
    return Biquad(
      0.217683334308543, -0.435366668617086, 0.217683334308543,
      1.0, -1.60335831800512, 0.67038548434305,
    );
  }
}

/// Dialog pour choisir la couleur des digits
class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF3B30), // Rouge
      const Color(0xFFFF9500), // Orange
      const Color(0xFFFFCC00), // Jaune
      const Color(0xFF34C759), // Vert
      const Color(0xFF007AFF), // Bleu
      const Color(0xFF5856D6), // Violet
      const Color(0xFFFF2D92), // Rose
      const Color(0xFFFFFFFF), // Blanc
    ];

    return AlertDialog(
      title: const Text('Couleur des digits'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors.map((color) => GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: _selectedColor == color 
                ? Border.all(color: Colors.white, width: 3)
                : null,
            ),
          ),
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
