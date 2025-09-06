import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({Key? key}) : super(key: key);
  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> with TickerProviderStateMixin {
  Duration _initial = const Duration(minutes: 0); // Changé de 1 à 0
  Duration _remaining = const Duration(minutes: 0); // Changé de 1 à 0
  Timer? _ticker;
  bool _running = false;
  bool _isFinished = false; // Nouveau : pour détecter la fin
  bool _isBlinking = false; // Nouveau : pour le clignotement

  // Nouvelles variables pour les couleurs personnalisées
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.red;

  final List<Duration?> _mem = [null, null, null]; // 3 mémoires
  late final ValueNotifier<Duration> _remainingNotifier;
  late final AnimationController _spinCtrl;
  late final AnimationController _blinkCtrl; // Nouveau : contrôleur pour le clignotement

  @override
  void initState() {
    super.initState();
    _remainingNotifier = ValueNotifier<Duration>(_remaining);
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true); // Clignotement doux
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _spinCtrl.dispose();
    _blinkCtrl.dispose(); // Nouveau
    _remainingNotifier.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(100).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _apply(Duration d) {
    // Limiter à 99:59 maximum
    final maxMinutes = 99;
    final maxSeconds = 59;
    final clampedMinutes = d.inMinutes.clamp(0, maxMinutes);
    final clampedSeconds = d.inSeconds.remainder(60).clamp(0, maxSeconds);
    
    final clampedDuration = Duration(minutes: clampedMinutes, seconds: clampedSeconds);
    
    setState(() {
      _initial = clampedDuration;
      _remaining = clampedDuration;
      _remainingNotifier.value = clampedDuration;
    });
  }

  void _nudge(int minutes, int seconds) {
    // Calculer le nouveau temps en minutes et secondes
    int newMinutes = _remaining.inMinutes + minutes;
    int newSeconds = _remaining.inSeconds.remainder(60) + seconds;
    
    // Ajuster les minutes si les secondes dépassent 60 ou sont négatives
    if (newSeconds >= 60) {
      newMinutes += newSeconds ~/ 60;
      newSeconds = newSeconds % 60;
    } else if (newSeconds < 0) {
      newMinutes -= 1;
      newSeconds += 60;
    }
    
    // Limiter à 99:59 maximum et 0:00 minimum
    newMinutes = newMinutes.clamp(0, 99);
    newSeconds = newSeconds.clamp(0, 59);
    
    // Créer la nouvelle durée
    final newDuration = Duration(minutes: newMinutes, seconds: newSeconds);
    
    // Appliquer seulement si c'est valide
    if (newMinutes >= 0 && newSeconds >= 0) {
      _apply(newDuration);
    }
  }

  Future<void> _editTimeDialog() async {
    final d = await showDialog<Duration>(
      context: context,
      builder: (_) => const _TimeEditDialog(),
    );
    if (d != null) _apply(d);
  }

  void _start() {
    if (_remaining.inSeconds == 0) _apply(_initial);
    setState(() {
      _running = true;
      _isFinished = false; // Reset l'état de fin
      _isBlinking = false; // Reset le clignotement
    });

    // Plein ecran avec les couleurs personnalisées
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => _FullScreenCountdown(
          remaining: _remainingNotifier,
          total: _initial,
          spin: _spinCtrl,
          onClose: _pause, // Back = pause
          backgroundColor: _backgroundColor, // Passer la couleur de fond personnalisée
          textColor: _textColor, // Passer la couleur de texte personnalisée
        ),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        setState(() {
          _remaining = Duration.zero;
          _remainingNotifier.value = _remaining;
          _running = false;
          _isFinished = true; // Marquer comme terminé
          _isBlinking = true; // Démarrer le clignotement
        });
        if (Navigator.canPop(context)) Navigator.pop(context); // ferme plein ecran
        
        // Démarrer le décompte inversé
        _startReverseCountdown();
      } else {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
          _remainingNotifier.value = _remaining;
        });
      }
    });
  }

  // Nouveau : décompte inversé après la fin
  void _startReverseCountdown() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _remaining = _remaining + const Duration(seconds: 1);
        _remainingNotifier.value = _remaining;
      });
      
      // Arrêter quand on atteint le temps initial
      if (_remaining.inMinutes >= _initial.inMinutes && _remaining.inSeconds >= _initial.inSeconds) {
        t.cancel();
        setState(() {
          _isBlinking = false; // Arrêter le clignotement
        });
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remaining = _initial;
      _remainingNotifier.value = _remaining;
    });
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // Nouvelle méthode pour changer les couleurs
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Choisir les couleurs', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sélecteur de couleur de fond
            ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: const Text('Couleur de fond', style: TextStyle(color: Colors.white)),
              onTap: () => _pickColor(true),
            ),
            // Sélecteur de couleur de texte
            ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _textColor,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: const Text('Couleur du texte', style: TextStyle(color: Colors.white)),
              onTap: () => _pickColor(false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // Méthode pour ouvrir le sélecteur de couleur
  void _pickColor(bool isBackground) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isBackground ? 'Choisir la couleur de fond' : 'Choisir la couleur du texte',
          style: const TextStyle(color: Colors.white)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Palette de couleurs simples
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorOption(Colors.red, 'Rouge'),
                _ColorOption(Colors.blue, 'Bleu'),
                _ColorOption(Colors.green, 'Vert'),
                _ColorOption(Colors.orange, 'Orange'),
                _ColorOption(Colors.purple, 'Violet'),
                _ColorOption(Colors.yellow, 'Jaune'),
                _ColorOption(Colors.cyan, 'Cyan'),
                _ColorOption(Colors.pink, 'Rose'),
                _ColorOption(Colors.white, 'Blanc'),
                _ColorOption(Colors.grey, 'Gris'),
                _ColorOption(Colors.brown, 'Marron'),
                _ColorOption(Colors.indigo, 'Indigo'),
              ].map((colorOption) => GestureDetector(
                onTap: () {
                  setState(() {
                    if (isBackground) {
                      _backgroundColor = colorOption.color;
                    } else {
                      _textColor = colorOption.color;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorOption.color,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      colorOption.label,
                      style: TextStyle(
                        color: colorOption.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            // Aperçu de la couleur actuellement sélectionnée
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: isBackground ? _backgroundColor : _textColor,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Aperçu - ${isBackground ? 'Fond' : 'Texte'}',
                  style: TextStyle(
                    color: (isBackground ? _backgroundColor : _textColor).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // Supprimer toutes les variables et méthodes HSL qui ne sont plus utilisées
  // _currentHue, _currentSaturation, _currentLightness
  // _generateColorPalette(), _lightenColor(), _darkenColor(), _getCurrentHSLColor()

  void _saveMem(int i) => setState(() => _mem[i] = _remaining);
  void _recallMem(int i) { final d = _mem[i]; if (d != null) _apply(d); }

  @override
  Widget build(BuildContext context) {
    final timeWidget = _TimeDisplay(
      timeText: _fmt(_remaining), 
      onTapEdit: _editTimeDialog,
      onMinusMinutes: () => _nudge(-5, 0),
      onPlusMinutes: () => _nudge(5, 0),
      onMinusSeconds: () => _nudge(0, -5),
      onPlusSeconds: () => _nudge(0, 5),
      isFinished: _isFinished,
      isBlinking: _isBlinking,
      blinkController: _blinkCtrl,
      backgroundColor: _backgroundColor, // Nouveau
      textColor: _textColor, // Nouveau
    );
    final controls = _Controls(
      running: _running, 
      onPlay: _start, 
      onPause: _pause, 
      onColorPicker: _showColorPicker, // Remplacé reset par colorPicker
      backgroundColor: _backgroundColor, // Nouveau
      textColor: _textColor, // Nouveau
    );
    final memButtons = _MemoryColumn(
      mem: _mem, 
      onSave: _saveMem, 
      onRecall: _recallMem,
      backgroundColor: _backgroundColor, // Nouveau
      textColor: _textColor, // Nouveau
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.5),
          border: Border.all(color: const Color(0xFF0A1128), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (_, c) => c.maxWidth > 680
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Center(child: memButtons)),
                    Expanded(child: Center(child: timeWidget)),
                    Expanded(child: Center(child: controls)),
                  ],
                )
              : Column(
                  children: [
                    memButtons,
                    const SizedBox(height: 16),
                    timeWidget,
                    const SizedBox(height: 16),
                    controls,
                  ],
                ),
        ),
      ),
    );
  }
}

class _Nudgers extends StatelessWidget {
  final VoidCallback onMinus, onPlus;
  const _Nudgers({required this.onMinus, required this.onPlus});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roundBtn(icon: Icons.remove_rounded, label: "-5s", onTap: onMinus),
          _roundBtn(icon: Icons.add_rounded, label: "+5s", onTap: onPlus),
        ],
      );
  Widget _roundBtn({required IconData icon, required String label, required VoidCallback onTap}) => Column(
        children: [
          Ink(
            decoration: const ShapeDecoration(
              color: Colors.transparent,
              shape: CircleBorder(side: BorderSide(color: Colors.white54)),
            ),
            child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
}

class _TimeDisplay extends StatelessWidget {
  final String timeText; 
  final VoidCallback onTapEdit;
  final VoidCallback onMinusMinutes, onPlusMinutes, onMinusSeconds, onPlusSeconds;
  final bool isFinished;
  final bool isBlinking;
  final AnimationController? blinkController;
  final Color backgroundColor; // Nouveau
  final Color textColor; // Nouveau
  
  const _TimeDisplay({
    required this.timeText, 
    required this.onTapEdit,
    required this.onMinusMinutes,
    required this.onPlusMinutes,
    required this.onMinusSeconds,
    required this.onPlusSeconds,
    required this.isFinished,
    required this.isBlinking,
    this.blinkController,
    required this.backgroundColor, // Nouveau
    required this.textColor, // Nouveau
  });
  
  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Horloge centrale avec couleurs personnalisées
      GestureDetector(
        onTap: onTapEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor, // Couleur personnalisée
            border: Border.all(
              color: textColor, // Couleur personnalisée
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: isBlinking && blinkController != null ? blinkController! : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              final opacity = isBlinking && blinkController != null ? blinkController!.value : 1.0;
              return Opacity(
                opacity: opacity,
                child: Text(
                  timeText,
                  style: TextStyle(
                    color: textColor, // Couleur personnalisée
                    fontSize: 48, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Boutons simplifiés et plus petits
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minutes (gauche)
          _compactBtn(icon: Icons.remove, onTap: onMinusMinutes, label: '5m'),
          const SizedBox(width: 8),
          _compactBtn(icon: Icons.add, onTap: onPlusMinutes, label: '5m'),
          const SizedBox(width: 24), // Espacement entre minutes et secondes
          // Secondes (droite)
          _compactBtn(icon: Icons.remove, onTap: onMinusSeconds, label: '5s'),
          const SizedBox(width: 8),
          _compactBtn(icon: Icons.add, onTap: onPlusSeconds, label: '5s'),
        ],
      ),
    ],
  );
  
  Widget _compactBtn({required IconData icon, required VoidCallback onTap, required String label}) => Column(
    children: [
      Container(
        width: 32, // Plus petit
        height: 32, // Plus petit
        decoration: BoxDecoration(
          color: backgroundColor, // Couleur personnalisée
          border: Border.all(color: textColor, width: 2), // Couleur personnalisée
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          icon: Icon(icon, color: textColor, size: 14), // Plus petit
          onPressed: onTap,
          padding: EdgeInsets.zero, // Pas de padding
          constraints: const BoxConstraints(), // Pas de contraintes
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label, 
        style: TextStyle(color: textColor, fontSize: 8), // Plus petit
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _Controls extends StatelessWidget {
  final bool running; 
  final VoidCallback onPlay, onPause, onColorPicker; // Remplacé onReset par onColorPicker
  final Color backgroundColor; // Nouveau
  final Color textColor; // Nouveau
  
  const _Controls({
    required this.running, 
    required this.onPlay, 
    required this.onPause, 
    required this.onColorPicker, // Remplacé onReset par onColorPicker
    required this.backgroundColor, // Nouveau
    required this.textColor, // Nouveau
  });
  
  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      foregroundColor: textColor, // Couleur personnalisée
      backgroundColor: backgroundColor, // Couleur personnalisée
      elevation: 0,
      side: BorderSide(color: textColor, width: 2), // Couleur personnalisée
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      textStyle: const TextStyle(fontSize: 14),
    );
    
    return Wrap(
      alignment: WrapAlignment.center, 
      spacing: 12, 
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: style, 
          onPressed: running ? null : onPlay,  
          icon: const Icon(Icons.play_arrow_rounded), 
          label: const Text("Play")
        ),
        ElevatedButton.icon(
          style: style, 
          onPressed: running ? onPause : null, 
          icon: const Icon(Icons.pause_rounded),      
          label: const Text("Pause")
        ),
        ElevatedButton.icon(
          style: style, 
          onPressed: onColorPicker, // Remplacé onReset par onColorPicker
          icon: const Icon(Icons.palette_rounded), // Icône palette au lieu de refresh
          label: const Text(""), // Texte vide au lieu de "Couleurs"
        ),
      ],
    );
  }
}

class _MemoryColumn extends StatelessWidget {
  final List<Duration?> mem; 
  final void Function(int) onSave, onRecall;
  final Color backgroundColor; // Nouveau
  final Color textColor; // Nouveau
  
  const _MemoryColumn({
    required this.mem, 
    required this.onSave, 
    required this.onRecall,
    required this.backgroundColor, // Nouveau
    required this.textColor, // Nouveau
  });
  
  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(100).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (i) {
      final label = mem[i] != null ? _fmt(mem[i]!) : 'M${i + 1}';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          width: 60,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor, // Couleur personnalisée
              backgroundColor: backgroundColor, // Couleur personnalisée
              side: BorderSide(color: textColor, width: 2), // Couleur personnalisée
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 10),
            ),
            onPressed: () => onRecall(i),
            onLongPress: () => onSave(i),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );
    }),
  );
}

class _FullScreenCountdown extends StatelessWidget {
  final ValueNotifier<Duration> remaining;
  final Duration total;
  final AnimationController spin;
  final VoidCallback onClose;
  final Color backgroundColor; // Nouveau : couleur de fond personnalisée
  final Color textColor; // Nouveau : couleur de texte personnalisée
  
  const _FullScreenCountdown({
    required this.remaining, 
    required this.total, 
    required this.spin, 
    required this.onClose,
    required this.backgroundColor, // Nouveau
    required this.textColor, // Nouveau
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalSec = total.inSeconds == 0 ? 1 : total.inSeconds;
    return WillPopScope(
      onWillPop: () async { onClose(); return false; },
      child: Scaffold(
        backgroundColor: backgroundColor, // Utiliser la couleur personnalisée
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ValueListenableBuilder<Duration>(
                  valueListenable: remaining,
                  builder: (_, d, __) {
                    final ratio = 1.0 - (d.inSeconds / totalSec);
                    return CustomPaint(
                      painter: _RingPainter(
                        progress: ratio,
                        backgroundColor: backgroundColor, // Passer la couleur de fond
                        textColor: textColor, // Passer la couleur de texte
                      ),
                      child: SizedBox(
                        width: 260, height: 260,
                        child: Center(
                          child: Text(
                            _fmt(d),
                            style: TextStyle(
                              color: textColor, // Utiliser la couleur personnalisée
                              fontSize: 64, 
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: textColor, size: 28), // Utiliser la couleur personnalisée
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours; return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0 a 1
  final Color backgroundColor; // Nouveau : couleur de fond personnalisée
  final Color textColor; // Nouveau : couleur de texte personnalisée
  
  _RingPainter({
    required this.progress,
    required this.backgroundColor, // Nouveau
    required this.textColor, // Nouveau
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width/2, size.height/2);
    final r = size.width/2 - 8;

    final bg = Paint()
      ..color = backgroundColor.withOpacity(0.7) // Cercle de fond avec la couleur personnalisée
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final fg = Paint()
      ..shader = LinearGradient(
        colors: [textColor, textColor.withOpacity(0.7)] // Progression avec la couleur personnalisée
      ).createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawCircle(c, r, bg); // fond
    final start = -pi/2;
    final sweep = 2*pi*progress;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, fg);
  }
  
  @override
  bool shouldRepaint(covariant _RingPainter old) => 
    old.progress != progress || 
    old.backgroundColor != backgroundColor || 
    old.textColor != textColor;
}

class _TimeEditDialog extends StatefulWidget {
  const _TimeEditDialog({Key? key}) : super(key: key);
  @override
  State<_TimeEditDialog> createState() => _TimeEditDialogState();
}

class _TimeEditDialogState extends State<_TimeEditDialog> {
  final TextEditingController _c = TextEditingController(text: '01:00');
  Duration? _parse(String txt) {
    final parts = txt.trim().split(':').map((e) => e.trim()).toList();
    int h=0,m=0,s=0;
    try {
      if (parts.length == 2) { m = int.parse(parts[0]); s = int.parse(parts[1]); }
      else if (parts.length == 3) { h = int.parse(parts[0]); m = int.parse(parts[1]); s = int.parse(parts[2]); }
      else { return null; }
      if (h<0||m<0||s<0) return null;
      return Duration(hours: h, minutes: m, seconds: s);
    } catch (_) { return null; }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A1128),
      title: const Text('Modifier le temps', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _c,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'MM:SS ou H:MM:SS',
          hintStyle: TextStyle(color: Colors.white54),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          onPressed: () { final d = _parse(_c.text); if (d != null) Navigator.pop(context, d); },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// Garder la classe _ColorOption simple
class _ColorOption {
  final Color color;
  final String label;
  
  _ColorOption(this.color, this.label);
}
