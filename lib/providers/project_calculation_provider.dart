import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_calculation.dart';

class ProjectCalculationNotifier extends StateNotifier<List<ProjectCalculation>> {
  ProjectCalculationNotifier() : super([]);

  void addCalculation(ProjectCalculation calculation) {
    state = [...state, calculation];
  }

  void removeCalculation(String id) {
    state = state.where((calc) => calc.id != id).toList();
  }

  List<ProjectCalculation> getCalculationsForExport(String projectId) {
    return state.where((calc) => calc.projectId == projectId).toList();
  }
}

final projectCalculationProvider = StateNotifierProvider<ProjectCalculationNotifier, List<ProjectCalculation>>((ref) {
  return ProjectCalculationNotifier();
});

final currentProjectCalculationsProvider = Provider<List<ProjectCalculation>>((ref) {
  final calculations = ref.watch(projectCalculationProvider);
  // Pour l'instant, retourner toutes les calculs
  // TODO: Filtrer par projet courant
  return calculations;
});