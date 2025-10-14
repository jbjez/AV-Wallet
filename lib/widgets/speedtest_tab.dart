// lib/pages/network_speed_test_page.dart
// -------------------------------------------------------
// SpeedTest compact (7-8 s) : ~5s Down + ~2s Up
// UI compacte, sans zone vide inutile
// -------------------------------------------------------

import 'dart:async';                                   // [L01]
import 'dart:math';                                    // [L02]
import 'dart:typed_data';                              // [L03]
import 'package:flutter/material.dart';                // [L04]
import 'package:http/http.dart' as http;               // [L05]
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SpeedtestTab extends StatefulWidget {    // [L07]
  const SpeedtestTab({super.key});             // [L08]
  @override
  State<SpeedtestTab> createState() => _SpeedtestTabState(); // [L09]
}

class _SpeedtestTabState extends State<SpeedtestTab> { // [L11]
  // ---- Réglages ----                                             // [L12]
  static const _downDuration = Duration(seconds: 5);                 // [L13]
  static const _upDuration   = Duration(seconds: 2);                 // [L14]
  static const _pad = EdgeInsets.all(12);                            // [L15]
  static const _darkBlue = Color(0xFF0A1128);                        // [L16]

  // Endpoints Cloudflare Speed (CORS ok)                            // [L18]
  static const _downUrl = 'https://speed.cloudflare.com/__down?bytes=15000000'; // ~15 MB  [L19]
  static const _upUrl   = 'https://speed.cloudflare.com/__up';                    // POST     [L20]

  bool _running = false;                                             // [L22]
  double _downMbps = 0;                                              // [L23]
  double _upMbps = 0;                                                // [L24]
  String _phase = '';                                                // [L25]
  double _progress = 0; // 0..1                                       // [L26]
  double _currentSpeed = 0; // Pour l'aiguille du compteur            // [L27]

  void _updateSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
  }

  Future<void> _start() async {                                      // [L28]
    if (_running) return;                                            // [L29]
    final loc = AppLocalizations.of(context)!;                       // [L29.5]
    setState(() {                                                    // [L30]
      _running = true;                                               // [L31]
      _downMbps = 0;                                                 // [L32]
      _upMbps = 0;                                                   // [L33]
      _progress = 0;                                                 // [L34]
      _phase = loc.speedtest_downloading;                            // [L35]
    });                                                              // [L36]

    // ---- DOWNLOAD PHASE (~5s) ----                                 // [L38]
    final downBytes = await _timeBoundDownload(_downDuration);       // [L39]
    final downMbps = _toMbps(downBytes, _downDuration);              // [L40]
    if (!mounted) return;                                            // [L41]
    setState(() {                                                    // [L42]
      _downMbps = downMbps;                                          // [L43]
      _phase = loc.speedtest_uploading;                              // [L44]
      _progress = 5 / 7.0;                                           // [L45]
    });                                                              // [L46]

    // ---- UPLOAD PHASE (~2s) ----                                    // [L48]
    final upBytes = await _timeBoundUpload(_upDuration);             // [L49]
    final upMbps = _toMbps(upBytes, _upDuration);                    // [L50]
    if (!mounted) return;                                            // [L51]
    setState(() {                                                    // [L52]
      _upMbps = upMbps;                                              // [L53]
      _phase = loc.speedtest_completed;                              // [L54]
      _progress = 1;                                                 // [L55]
      _running = false;                                              // [L56]
    });                                                              // [L57]
  }                                                                  // [L58]

  // Mesure download limitée en temps                                 // [L60]
  Future<int> _timeBoundDownload(Duration d) async {                 // [L61]
    final sw = Stopwatch()..start();                                  // [L62]
    int total = 0;                                                    // [L63]
    // On boucle pour occuper toute la durée (si 15MB trop vite)      // [L64]
    while (sw.elapsed < d) {                                          // [L65]
      final resp = await http.get(Uri.parse(_downUrl));               // [L66]
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {      // [L67]
        total += resp.bodyBytes.length;                                // [L68]
        // Calcul vitesse instantanée                                  // [L69]
        final currentMbps = _toMbps(total, sw.elapsed);                // [L70]
        _updateSpeed(currentMbps);                                     // [L71]
      } else {                                                         // [L72]
        break;                                                         // [L73]
      }                                                                // [L74]
      // progress lissé                                                // [L75]
      if (mounted) {                                                   // [L76]
        final f = sw.elapsed.inMilliseconds / (d.inMilliseconds);      // [L77]
        setState(() => _progress = max(0.01, min(5/7.0 * f, 5/7.0)));  // [L78]
      }                                                                // [L79]
    }                                                                  // [L80]
    return total;                                                      // [L81]
  }                                                                    // [L82]

  // Mesure upload limitée en temps                                    // [L81]
  Future<int> _timeBoundUpload(Duration d) async {                    // [L82]
    final sw = Stopwatch()..start();                                  // [L83]
    int total = 0;                                                    // [L84]
    final rnd = Random();                                             // [L85]
    // buffer ~512 KB, renvoyé en boucle pendant ~2s                   // [L86]
    final buf = Uint8List.fromList(List<int>.generate(512 * 1024, (_) => rnd.nextInt(256))); // [L87]

    while (sw.elapsed < d) {                                          // [L88]
      final resp = await http.post(Uri.parse(_upUrl), body: buf);     // [L89]
      if (resp.statusCode >= 200 && resp.statusCode < 300) {          // [L90]
        total += buf.length;                                          // [L91]
        // Calcul vitesse instantanée                                  // [L92]
        final currentMbps = _toMbps(total, sw.elapsed);                // [L93]
        _updateSpeed(currentMbps);                                     // [L94]
      } else {                                                        // [L95]
        break;                                                        // [L96]
      }                                                               // [L97]
      if (mounted) {                                                  // [L98]
        final f = sw.elapsed.inMilliseconds / d.inMilliseconds;       // [L99]
        setState(() => _progress = 5/7.0 + (2/7.0) * min(1, f));      // [L100]
      }                                                               // [L101]
    }                                                                 // [L102]
    return total;                                                     // [L103]
  }                                                                   // [L104]

  double _toMbps(int bytes, Duration d) {                             // [L103]
    if (d.inMilliseconds == 0) return 0;                              // [L104]
    final bits = bytes * 8;                                           // [L105]
    final mbits = bits / 1e6;                                         // [L106]
    return double.parse((mbits / (d.inMilliseconds/1000)).toStringAsFixed(2)); // [L107]
  }                                                                    // [L108]

  @override
  Widget build(BuildContext context) {                                 // [L110]
    final loc = AppLocalizations.of(context)!;                         // [L110.5]
    // Initialiser la phase si elle est vide
    if (_phase.isEmpty) {
      _phase = loc.speedtest_ready;
    }
    return Container(                                                  // [L111]
      margin: const EdgeInsets.all(16),                                // [L112]
      decoration: BoxDecoration(                                       // [L113]
        color: _darkBlue.withOpacity(0.3),                             // [L114]
        border: Border.all(color: Colors.white, width: 1),             // [L115]
        borderRadius: BorderRadius.circular(12),                       // [L116]
      ),
      child: Padding(                                                  // [L118]
        padding: _pad,                                                  // [L119]
        child: Column(                                                  // [L120]
          mainAxisSize: MainAxisSize.min,                               // [L121]
          crossAxisAlignment: CrossAxisAlignment.stretch,               // [L122]
          children: [
            _CompactCard(                                               // [L123]
              phase: _phase, running: _running, progress: _progress,   // [L124]
              downMbps: _downMbps, upMbps: _upMbps,                     // [L125]
              onStart: _start,                                          // [L126]
              currentSpeed: _currentSpeed,                              // [L127]
              loc: loc,                                                 // [L127.5]
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- UI compacte : une seule carte -------------------      // [L140]
class _CompactCard extends StatelessWidget {                                 // [L141]
  final String phase; final bool running; final double progress;             // [L142]
  final double downMbps; final double upMbps; final VoidCallback onStart;    // [L143]
  final double currentSpeed; final AppLocalizations loc;                     // [L144]
  const _CompactCard({required this.phase, required this.running, // [L145]
    required this.progress, required this.downMbps, required this.upMbps, required this.onStart,
    required this.currentSpeed, required this.loc}); // [L146]

  @override
  Widget build(BuildContext context) {                                        // [L147]
    final glass = Colors.white.withOpacity(0.12);                             // [L148]
    return Container(                                                         // [L149]
      padding: const EdgeInsets.all(14),                                      // [L150]
      decoration: BoxDecoration(                                              // [L151]
        color: glass, borderRadius: BorderRadius.circular(16),                // [L152]
        border: Border.all(color: Colors.white24, width: 1),                  // [L153]
      ),
      child: Column(                                                          // [L154]
        mainAxisSize: MainAxisSize.min,                                       // [L155]
          children: [
            // Ligne résultats ultra compacte                                  // [L156]
            Row(                                                                // [L157]
              children: [
                Expanded(                                                       // [L158]
                  child: _Metric(label: loc.speedtest_download, value: downMbps, icon: Icons.download, loc: loc), // [L159]
                ),
                const SizedBox(width: 8),                                       // [L160]
                Expanded(                                                       // [L161]
                  child: _Metric(label: loc.speedtest_upload, value: upMbps, icon: Icons.upload, loc: loc), // [L162]
                ),
              ],
            ),
            const SizedBox(height: 12),                                         // [L164]
            // Compteur avec aiguille                                           // [L165]
            _SpeedGauge(                                                         // [L166]
              currentSpeed: currentSpeed,                                       // [L167]
              loc: loc,                                                         // [L167.5]
            ),
            const SizedBox(height: 10),                                         // [L170]
            // Barre de progression fine                                        // [L171]
            ClipRRect(                                                           // [L172]
              borderRadius: BorderRadius.circular(8),                            // [L173]
              child: LinearProgressIndicator(                                    // [L174]
                value: running ? (progress.clamp(0, 1)) : 0, minHeight: 6,      // [L175]
                backgroundColor: Colors.white12,                                 // [L176]
              ),
            ),
            const SizedBox(height: 8),                                          // [L178]
            // Légende phase + bouton Start                                      // [L179]
            Row(                                                                 // [L180]
              children: [
                Expanded(                                                        // [L181]
                  child: Text(phase, style: const TextStyle(color: Colors.white70, fontSize: 12)), // [L182]
                ),
                ElevatedButton(                                                  // [L183]
                  onPressed: running ? null : onStart,                           // [L184]
                  style: ElevatedButton.styleFrom(                               // [L185]
                    backgroundColor: Colors.white, foregroundColor: Colors.black, // [L186]
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // [L187]
                  ),
                  child: Text(running ? loc.speedtest_running : loc.speedtest_start, style: const TextStyle(fontSize: 12)), // [L188]
                )
              ],
            ),
          ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {                                       // [L190]
  final String label; final double value; final IconData icon; final AppLocalizations loc; // [L191]
  const _Metric({required this.label, required this.value, required this.icon, required this.loc}); // [L192]
  @override
  Widget build(BuildContext context) {                                         // [L193]
    return Container(                                                          // [L194]
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),        // [L195]
      decoration: BoxDecoration(                                               // [L196]
        color: Colors.white.withOpacity(0.08),                                  // [L197]
        borderRadius: BorderRadius.circular(12),                                // [L198]
        border: Border.all(color: Colors.white24, width: 1),                    // [L199]
      ),
      child: Row(                                                               // [L200]
        children: [
          Icon(icon, color: Colors.white, size: 18),                            // [L201]
          const SizedBox(width: 8),                                             // [L202]
          Expanded(                                                             // [L203]
            child: Column(                                                      // [L204]
              crossAxisAlignment: CrossAxisAlignment.start,                     // [L205]
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)), // [L206]
                Text(                                                           // [L207]
                  value > 0 ? '${value.toStringAsFixed(2)} ${loc.speedtest_mbps}' : '-- ${loc.speedtest_mbps}',   // [L208]
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), // [L209]
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Compteur avec aiguille 0-600 Mb/s
class _SpeedGauge extends StatelessWidget {
  final double currentSpeed;
  final AppLocalizations loc;

  const _SpeedGauge({
    required this.currentSpeed,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul direct de l'angle de l'aiguille basé sur la vitesse
    final normalizedSpeed = (currentSpeed / 600).clamp(0.0, 1.0);
    final needleAngle = normalizedSpeed * pi - pi / 2; // -π/2 à π/2 (demi-cercle)
    
    return Container(
      height: 108,
      width: 162,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: CustomPaint(
        painter: _GaugePainter(
          value: currentSpeed,
          needleAngle: needleAngle,
        ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentSpeed.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loc.speedtest_mbps,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double needleAngle;

  _GaugePainter({
    required this.value,
    required this.needleAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw gauge arc
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -pi / 2,
      pi,
      false,
      arcPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final progressAngle = (value / 600) * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );

    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + cos(needleAngle) * (radius - 15),
      center.dy + sin(needleAngle) * (radius - 15),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2, centerPaint);

    // Draw scale marks
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;

    for (int i = 0; i <= 6; i++) {
      final tickValue = i * 100; // 0, 100, 200, 300, 400, 500, 600
      final tickAngle = (tickValue / 600) * pi - pi / 2;
      final tickStart = Offset(
        center.dx + cos(tickAngle) * (radius - 8),
        center.dy + sin(tickAngle) * (radius - 8),
      );
      final tickEnd = Offset(
        center.dx + cos(tickAngle) * (radius - 3),
        center.dy + sin(tickAngle) * (radius - 3),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
