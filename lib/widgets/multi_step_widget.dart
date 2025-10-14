import 'package:flutter/material.dart';

/// Defines a reusable multi-step process widget using Flutter's Stepper.
class MultiStepProcess<T> extends StatefulWidget {
  /// Data for each step: title, subtitle, content builder, optional validation and callbacks
  final List<StepData<T>> steps;

  /// Called when all steps are completed
  final VoidCallback onCompleted;

  const MultiStepProcess({
    super.key,
    required this.steps,
    required this.onCompleted,
  });

  @override
  _MultiStepProcessState<T> createState() => _MultiStepProcessState<T>();
}

class _MultiStepProcessState<T> extends State<MultiStepProcess<T>> {
  int _currentStep = 0;
  final Map<int, T?> _results = {};

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      onStepTapped: (index) => setState(() => _currentStep = index),
      controlsBuilder: (context, details) {
        final isLast = _currentStep == widget.steps.length - 1;
        return Row(
          children: [
            ElevatedButton(
              onPressed: details.onStepContinue,
              child: Text(isLast ? 'Finish' : 'Next'),
            ),
            if (_currentStep > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
          ],
        );
      },
      steps: widget.steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final sd = entry.value;
        return Step(
          title: Text(sd.title),
          subtitle: sd.subtitle != null ? Text(sd.subtitle!) : null,
          content: Builder(
            builder: (ctx) => sd.contentBuilder(ctx, _results[idx]),
          ),
          isActive: _currentStep == idx,
          state: _stepState(idx),
        );
      }).toList(),
    );
  }

  StepState _stepState(int index) {
    if (index < _currentStep) return StepState.complete;
    if (index == _currentStep) return StepState.editing;
    return StepState.indexed;
  }

  void _onStepContinue() {
    final step = widget.steps[_currentStep];
    final valid = step.validator?.call(_results[_currentStep]) ?? true;
    if (!valid) return;

    // Optionally save result
    if (step.onStepCompleted != null) {
      step.onStepCompleted!(_results[_currentStep]);
    }

    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onCompleted();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
}

/// Data model for each step
class StepData<T> {
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext, T?) contentBuilder;
  final bool Function(T?)? validator;
  final void Function(T?)? onStepCompleted;

  StepData({
    required this.title,
    this.subtitle,
    required this.contentBuilder,
    this.validator,
    this.onStepCompleted,
  });
}
