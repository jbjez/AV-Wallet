import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArMeasureUnityPage extends StatefulWidget {
  const ArMeasureUnityPage({Key? key}) : super(key: key);
  @override
  State<ArMeasureUnityPage> createState() => _ArMeasureUnityPageState();
}

class _ArMeasureUnityPageState extends State<ArMeasureUnityPage> with SingleTickerProviderStateMixin {
  // UnityWidgetController? _unityCtrl;
  double? _distanceM;
  Offset? _focusPos;
  late final AnimationController _focusCtrl;
  late final Animation<double> _focusAnim;
  String _selectedObjectType = "measure_point";

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _focusAnim = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    // _unityCtrl?.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  void _onUnityCreated(dynamic controller) {
    // _unityCtrl = controller;
    print('AR Measure Unity - Unity créé avec succès');
  }

  void _onUnityMessage(dynamic msg) {
    try {
      final map = json.decode(msg.toString());
      if (map['type'] == 'distance') {
        setState(() {
          _distanceM = (map['value'] as num?)?.toDouble();
        });
        print('AR Measure Unity - Distance reçue: ${_distanceM?.toStringAsFixed(3)} m');
      } else if (map['type'] == 'object_placed') {
        print('AR Measure Unity - Objet placé: ${map['objectType']} at ${map['position']}');
      }
    } catch (e) {
      print('AR Measure Unity - Erreur parsing message: $e');
    }
  }

  void _triggerFocusAt(Offset p) {
    setState(() => _focusPos = p);
    _focusCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _focusPos = null);
    });
  }

  void _resetUnity() {
    // _unityCtrl?.postMessage(
    //   'ObjectManager',
    //   'ResetMeasure',
    //   '',
    // );
    setState(() => _distanceM = null);
    print('AR Measure Unity - Reset demandé');
  }

  void _selectObject(String objectType) {
    setState(() {
      _selectedObjectType = objectType;
    });
    // _unityCtrl?.postMessage(
    //   'ObjectManager',
    //   'PlaceObject',
    //   objectType,
    // );
    print('AR Measure Unity - Objet sélectionné: $objectType');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = (_distanceM == null) ? 'AR Measure' : '${_distanceM!.toStringAsFixed(2)} m';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // UnityWidget temporairement désactivé
          Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Unity AR Measure\n(Unity temporairement désactivé)',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
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
                      onPressed: () => _selectObject("measure_point"),
                      backgroundColor: _selectedObjectType == "measure_point" ? Colors.orange : Colors.white,
                      child: const Icon(Icons.straighten, color: Colors.black),
                      tooltip: 'Mesurer',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_projector',
                      onPressed: () => _selectObject("projector"),
                      backgroundColor: _selectedObjectType == "projector" ? Colors.blue : Colors.white,
                      child: const Icon(Icons.videocam, color: Colors.black),
                      tooltip: 'Projecteur',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_screen',
                      onPressed: () => _selectObject("screen"),
                      backgroundColor: _selectedObjectType == "screen" ? Colors.grey : Colors.white,
                      child: const Icon(Icons.tv, color: Colors.black),
                      tooltip: 'Écran',
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'select_speaker',
                      onPressed: () => _selectObject("speaker"),
                      backgroundColor: _selectedObjectType == "speaker" ? Colors.brown : Colors.white,
                      child: const Icon(Icons.volume_up, color: Colors.black),
                      tooltip: 'Haut-parleur',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: _resetUnity,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.refresh, color: Colors.black),
                  tooltip: 'Reset',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}