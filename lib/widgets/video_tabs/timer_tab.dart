import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pages/timer_tab.dart';

class TimerTabWidget extends ConsumerWidget {
  const TimerTabWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TimerTab();
  }
}
