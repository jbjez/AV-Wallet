// lib/pages/divers_menu_page.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/preset_widget.dart';
import '../widgets/speedtest_tab.dart';
import '../providers/preset_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/uniform_bottom_nav_bar.dart';

class DiversMenuPage extends ConsumerStatefulWidget {
  const DiversMenuPage({super.key});

  @override
  ConsumerState<DiversMenuPage> createState() => _DiversMenuPageState();
}

class _DiversMenuPageState extends ConsumerState<DiversMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }







  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.more_horiz,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.15,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Bande Passante'),
                            Tab(icon: Icon(Icons.calculate)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PresetWidget(
                          onPresetSelected: (preset) {
                            setState(() {
                              final presets = ref.read(presetProvider);
                              final index = presets.indexWhere((p) => p.id == preset.id);
                              if (index != -1) {
                                ref.read(presetProvider.notifier).selectPreset(index);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildBandePassante(),
                              _buildCalculatrice(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 6),
    );
  }

  Widget _buildBandePassante() {
    return const SpeedtestTab();
  }

  Widget _buildCalculatrice() {
    return const CalculatorPageCompact();
  }
}

// Version compacte de la calculatrice pour l'onglet Divers
class CalculatorPageCompact extends StatefulWidget {
  const CalculatorPageCompact({super.key});

  @override
  State<CalculatorPageCompact> createState() => _CalculatorPageCompactState();
}

class _CalculatorPageCompactState extends State<CalculatorPageCompact> {
  static const Color darkBlue = Color(0xFF0A1128);
  static const Color glass = Color.fromARGB(140, 255, 255, 255);
  static const EdgeInsets pad = EdgeInsets.symmetric(horizontal: 8);

  String _display = '0';
  double? _accumulator;
  String? _pendingOp;
  bool _replaceOnNextDigit = false;
  List<String> _calculationHistory = [];

  void _inputDigit(String d) {
    setState(() {
      if (_replaceOnNextDigit || _display == '0') {
        _display = d;
        _replaceOnNextDigit = false;
      } else {
        _display += d;
      }
    });
  }

  void _inputDot() {
    setState(() {
      if (_replaceOnNextDigit) {
        _display = '0.';
        _replaceOnNextDigit = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  double _asNumber() {
    final sanitized = _display.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(sanitized) ?? 0.0;
  }

  void _clear() {
    setState(() {
      _display = '0';
      _accumulator = null;
      _pendingOp = null;
      _replaceOnNextDigit = false;
    });
  }

  void _toggleSign() {
    setState(() {
      final n = _asNumber() * -1;
      _display = _format(n);
    });
  }

  void _percent() {
    setState(() {
      final n = _asNumber() / 100.0;
      _display = _format(n);
      _replaceOnNextDigit = true;
    });
  }

  String _format(double n) {
    final s = n.toStringAsFixed(10);
    var trimmed = s.replaceFirst(RegExp(r'\.?0+$'), '');
    if (trimmed == '-0') trimmed = '0';
    return trimmed;
  }

  void _operate(String op) {
    setState(() {
      final current = _asNumber();
      if (_accumulator == null) {
        _accumulator = current;
      } else if (_pendingOp != null) {
        _accumulator = _eval(_accumulator!, current, _pendingOp!);
        _display = _format(_accumulator!);
      }
      _pendingOp = op;
      _replaceOnNextDigit = true;
    });
  }

  void _equals() {
    setState(() {
      if (_accumulator != null && _pendingOp != null) {
        final current = _asNumber();
        final result = _eval(_accumulator!, current, _pendingOp!);
        _calculationHistory.add('${_format(_accumulator!)} ${_pendingOp!} ${_format(current)} = ${_format(result)}');
        _accumulator = result;
        _display = _format(_accumulator!);
        _pendingOp = null;
        _replaceOnNextDigit = true;
      }
    });
  }

  double _eval(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? 0 : a / b;
      default: return b;
    }
  }

  void _appendUnit(String unit) {
    setState(() { _display = '${_format(_asNumber())} $unit'; });
  }

  void _ampsFromWatts230V() {
    final watts = _asNumber();
    final amps = watts / 230.0;
    setState(() { _display = '${_format(amps)} A'; });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Élargie de 20% (80% de la largeur)
        decoration: const BoxDecoration(
          color: darkBlue,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _displayPanel(),
              const SizedBox(height: 6),
              _avChips(),
              const SizedBox(height: 6),
              Expanded(child: _keypad()),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayPanel() {
    return Container(
      width: double.infinity,
      margin: pad,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          _display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _avChips() {
    return Padding(
      padding: pad,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _chip('kg', () => _appendUnit('kg'))),
          const SizedBox(width: 4),
          Expanded(child: _chip('W', () => _appendUnit('W'))),
          const SizedBox(width: 4),
          Expanded(child: _chip('A @230V', _ampsFromWatts230V)),
          const SizedBox(width: 4),
          Expanded(child: _chip('m', () => _appendUnit('m'))),
          const SizedBox(width: 4),
          Expanded(child: _chip('m²', () => _appendUnit('m²'))),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: glass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    final keys = <_KeyDefCompact>[
      _KeyDefCompact('C', onTap: _clear, kind: KeyKindCompact.fn),
      _KeyDefCompact('±', onTap: _toggleSign, kind: KeyKindCompact.fn),
      _KeyDefCompact('%', onTap: _percent, kind: KeyKindCompact.fn),
      _KeyDefCompact('÷', onTap: () => _operate('÷'), kind: KeyKindCompact.op),
      _KeyDefCompact('7', onTap: () => _inputDigit('7')),
      _KeyDefCompact('8', onTap: () => _inputDigit('8')),
      _KeyDefCompact('9', onTap: () => _inputDigit('9')),
      _KeyDefCompact('×', onTap: () => _operate('×'), kind: KeyKindCompact.op),
      _KeyDefCompact('4', onTap: () => _inputDigit('4')),
      _KeyDefCompact('5', onTap: () => _inputDigit('5')),
      _KeyDefCompact('6', onTap: () => _inputDigit('6')),
      _KeyDefCompact('-', onTap: () => _operate('-'), kind: KeyKindCompact.op),
      _KeyDefCompact('1', onTap: () => _inputDigit('1')),
      _KeyDefCompact('2', onTap: () => _inputDigit('2')),
      _KeyDefCompact('3', onTap: () => _inputDigit('3')),
      _KeyDefCompact('+', onTap: () => _operate('+'), kind: KeyKindCompact.op),
      _KeyDefCompact('0', onTap: () => _inputDigit('0'), flex: 2),
      _KeyDefCompact('.', onTap: _inputDot),
      _KeyDefCompact('=', onTap: _equals, kind: KeyKindCompact.eq),
    ];

    return Padding(
      padding: pad,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final colW = (width - 3 * 4) / 4;
          return Wrap(
            spacing: 4,
            runSpacing: 14, // Espacement vertical augmenté de 10px (4 + 10 = 14)
            children: keys.map((k) {
              final w = k.flex == 2 ? colW * 2 + 4 : colW;
              return SizedBox(
                width: w,
                height: 32,
                child: _GlassButtonCompact(
                  label: k.label,
                  onTap: k.onTap,
                  kind: k.kind,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

enum KeyKindCompact { num, op, fn, eq }

class _KeyDefCompact {
  final String label;
  final VoidCallback onTap;
  final int flex;
  final KeyKindCompact kind;
  _KeyDefCompact(this.label, {required this.onTap, this.flex = 1, this.kind = KeyKindCompact.num});
}

class _GlassButtonCompact extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final KeyKindCompact kind;
  const _GlassButtonCompact({required this.label, required this.onTap, required this.kind});

  @override
  Widget build(BuildContext context) {
    final isOp = kind == KeyKindCompact.op;
    final isEq = kind == KeyKindCompact.eq;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _StateColorsCompact.bg(kind),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isEq ? Colors.black87 : Colors.white,
            fontSize: 12,
            fontWeight: isOp || isEq ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StateColorsCompact {
  static const glass = Color.fromARGB(140, 255, 255, 255);
  static Color bg(KeyKindCompact k) {
    switch (k) {
      case KeyKindCompact.op: return glass;
      case KeyKindCompact.eq: return Colors.amber;
      case KeyKindCompact.fn: return glass;
      case KeyKindCompact.num: return glass;
    }
  }
}

