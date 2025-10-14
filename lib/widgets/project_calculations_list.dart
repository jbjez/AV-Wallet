import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_calculation_provider.dart';
import '../models/project_calculation.dart';

class ProjectCalculationsList extends ConsumerWidget {
  final String? projectId;
  
  const ProjectCalculationsList({
    super.key,
    this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculations = ref.watch(projectCalculationProvider);
    
    // Filtrer par projectId si fourni
    final filteredCalculations = projectId != null 
        ? calculations.where((calc) => calc.projectId == projectId).toList()
        : calculations;

    if (filteredCalculations.isEmpty) {
      return const Center(
        child: Text('Aucun calcul disponible'),
      );
    }

    return ListView.builder(
      itemCount: filteredCalculations.length,
      itemBuilder: (context, index) {
        final calculation = filteredCalculations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(calculation.name),
            subtitle: Text('Puissance: ${calculation.totalPower}W - Poids: ${calculation.totalWeight}kg'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(projectCalculationProvider.notifier).removeCalculation(calculation.id);
              },
            ),
          ),
        );
      },
    );
  }
}