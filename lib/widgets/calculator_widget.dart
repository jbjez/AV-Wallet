import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  double _secondNumber = 0;
  bool _waitingForOperand = false;
  final List<String> _calculationHistory = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _operation = '';
        _firstNumber = 0;
        _secondNumber = 0;
        _waitingForOperand = false;
      } else if (value == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (value == '=') {
        _secondNumber = double.parse(_display);
        String calculation = '$_firstNumber $_operation $_secondNumber = ';
        _calculate();
        calculation += _display;
        _calculationHistory.add(calculation);
      } else if (['+', '-', '×', '÷', '%'].contains(value)) {
        _firstNumber = double.parse(_display);
        _operation = value;
        _waitingForOperand = true;
      } else if (value == '±') {
        if (_display != '0') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (value == '.') {
        if (!_display.contains('.')) {
          _display += '.';
        }
      } else {
        if (_waitingForOperand) {
          _display = value;
          _waitingForOperand = false;
        } else {
          _display = _display == '0' ? value : _display + value;
        }
      }
    });
  }

  void _calculate() {
    switch (_operation) {
      case '+':
        _display = (_firstNumber + _secondNumber).toString();
        break;
      case '-':
        _display = (_firstNumber - _secondNumber).toString();
        break;
      case '×':
        _display = (_firstNumber * _secondNumber).toString();
        break;
      case '÷':
        if (_secondNumber != 0) {
          _display = (_firstNumber / _secondNumber).toString();
        } else {
          _display = 'Error';
        }
        break;
      case '%':
        _display = (_firstNumber % _secondNumber).toString();
        break;
    }
    
    // Format the result
    if (_display != 'Error') {
      double result = double.parse(_display);
      if (result == result.toInt()) {
        _display = result.toInt().toString();
      } else {
        _display = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    }
    
    _operation = '';
    _waitingForOperand = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.3),
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Calculatrice
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Display
                  Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildButton('C', Colors.red),
                        _buildButton('⌫', Colors.orange),
                        _buildButton('%', Colors.blue),
                        _buildButton('÷', Colors.blue),
                        
                        _buildButton('7', Colors.grey[800]!),
                        _buildButton('8', Colors.grey[800]!),
                        _buildButton('9', Colors.grey[800]!),
                        _buildButton('×', Colors.blue),
                        
                        _buildButton('4', Colors.grey[800]!),
                        _buildButton('5', Colors.grey[800]!),
                        _buildButton('6', Colors.grey[800]!),
                        _buildButton('-', Colors.blue),
                        
                        _buildButton('1', Colors.grey[800]!),
                        _buildButton('2', Colors.grey[800]!),
                        _buildButton('3', Colors.grey[800]!),
                        _buildButton('+', Colors.blue),
                        
                        _buildButton('±', Colors.grey[600]!),
                        _buildButton('0', Colors.grey[800]!),
                        _buildButton('.', Colors.grey[600]!),
                        _buildButton('=', Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Widget Export
          Expanded(
            flex: 1,
            child: _buildExportWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onButtonPressed(text),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportWidget() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique des calculs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_calculationHistory.length} calculs',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _calculationHistory.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun calcul effectué',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _calculationHistory.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1), // Réduit de 2 à 1
                        child: Text(
                          _calculationHistory[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculationHistory.isEmpty ? null : _exportCalculations,
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text('Exporter', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculationHistory.isEmpty ? null : _clearHistory,
                  icon: const Icon(Icons.clear, size: 20),
                  label: const Text('Effacer', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportCalculations() {
    if (_calculationHistory.isEmpty) return;
    
    final String content = _calculationHistory.join('\n');
    final String timestamp = DateTime.now().toString().substring(0, 19);
    final String exportContent = 'Calculs exportés le $timestamp\n\n$content';
    
    Share.share(exportContent, subject: 'Historique des calculs');
  }

  void _clearHistory() {
    setState(() {
      _calculationHistory.clear();
    });
  }
}
