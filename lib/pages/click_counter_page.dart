import 'package:flutter/material.dart';
import '../widgets/click_counter_widget.dart';

class ClickCounterPage extends StatelessWidget {
  const ClickCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compteur de Clics'),
      ),
      body: const ClickCounterWidget(child: SizedBox()),
    );
  }
}
