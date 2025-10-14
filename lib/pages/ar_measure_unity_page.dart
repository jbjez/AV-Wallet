import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../services/unity_service.dart';
import '../widgets/uniform_bottom_nav_bar.dart';

class ArMeasureUnityPage extends ConsumerStatefulWidget {
  const ArMeasureUnityPage({Key? key}) : super(key: key);
  @override
  ConsumerState<ArMeasureUnityPage> createState() => _ArMeasureUnityPageState();
}

class _ArMeasureUnityPageState extends ConsumerState<ArMeasureUnityPage> with SingleTickerProviderStateMixin {
  double? _distanceM;
  Offset? _focusPos;
  late final AnimationController _focusCtrl;
  late final Animation<double> _focusAnim;
  String _selectedObjectType = "measure_point";
  bool _isUnityVisible = false;
  late UnityService _unityService;

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _focusAnim = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);
    _unityService = UnityService();
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    super.dispose();
  }

  /// Affiche Unity en plein écran
  Future<void> _showUnity() async {
    try {
      setState(() {
        _isUnityVisible = true;
      });
      await _unityService.showUnity();
      print('AR Measure Unity - Unity affiché avec succès');
    } catch (e) {
      print('AR Measure Unity - Erreur lors de l\'affichage Unity: $e');
      setState(() {
        _isUnityVisible = false;
      });
    }
  }

  /// Cache Unity et retourne à Flutter
  Future<void> _hideUnity() async {
    try {
      await _unityService.hideUnity();
      setState(() {
        _isUnityVisible = false;
      });
      print('AR Measure Unity - Unity masqué avec succès');
    } catch (e) {
      print('AR Measure Unity - Erreur lors du masquage Unity: $e');
    }
  }

  void _triggerFocusAt(Offset p) {
    setState(() => _focusPos = p);
    _focusCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _focusPos = null);
    });
  }

  /// Reset la mesure AR
  Future<void> _resetUnity() async {
    try {
      await _unityService.resetARMeasurement();
      setState(() {
        _distanceM = null;
      });
      print('AR Measure Unity - Reset demandé');
    } catch (e) {
      print('AR Measure Unity - Erreur lors du reset: $e');
    }
  }

  /// Sélectionne un type d'objet
  Future<void> _selectObject(String objectType) async {
    try {
      setState(() {
        _selectedObjectType = objectType;
      });
      await _unityService.selectObjectType(objectType);
      print('AR Measure Unity - Objet sélectionné: $objectType');
    } catch (e) {
      print('AR Measure Unity - Erreur lors de la sélection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (_distanceM == null) ? 'AR Measure' : '${_distanceM!.toStringAsFixed(2)} m';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isUnityVisible ? Icons.close : Icons.play_arrow),
            onPressed: _isUnityVisible ? _hideUnity : _showUnity,
            tooltip: _isUnityVisible ? 'Fermer Unity' : 'Ouvrir Unity',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interface Flutter pour contrôler Unity
          if (!_isUnityVisible) ...[
            // Écran d'accueil avec bouton pour ouvrir Unity
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    size: 100,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mesure AR Unity',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Appuyez sur le bouton pour ouvrir Unity',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _showUnity,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Ouvrir Unity AR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Capture pour focus ring
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (ev) => _triggerFocusAt(ev.localPosition),
              child: const SizedBox.expand(),
            ),
          ),
          if (_focusPos != null)
            Positioned(
              left: _focusPos!.dx - 40,
              top: _focusPos!.dy - 40,
              child: ScaleTransition(
                scale: _focusAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 1),
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Top bar
          SafeArea(
            child: Container(
              color: Colors.black.withOpacity(0.35),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          // Bottom actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'select_measure',
                      onPressed: () {}, // _selectObject("measure_point"),
                      backgroundColor: _selectedObjectType == "measure_point" ? Colors.orange : Colors.white,
                      child: const Icon(Icons.straighten, color: Colors.black),
                      tooltip: 'Mesurer',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_projector',
                      onPressed: () {}, // _selectObject("projector"),
                      backgroundColor: _selectedObjectType == "projector" ? Colors.blue : Colors.white,
                      child: const Icon(Icons.videocam, color: Colors.black),
                      tooltip: 'Projecteur',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_screen',
                      onPressed: () {}, // _selectObject("screen"),
                      backgroundColor: _selectedObjectType == "screen" ? Colors.grey : Colors.white,
                      child: const Icon(Icons.tv, color: Colors.black),
                      tooltip: 'Écran',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_speaker',
                      onPressed: () {}, // _selectObject("speaker"),
                      backgroundColor: _selectedObjectType == "speaker" ? Colors.brown : Colors.white,
                      child: const Icon(Icons.volume_up, color: Colors.black),
                      tooltip: 'Haut-parleur',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: () {}, // _resetUnity,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.refresh, color: Colors.black),
                  tooltip: 'Reset',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 6),
    );
  }
}