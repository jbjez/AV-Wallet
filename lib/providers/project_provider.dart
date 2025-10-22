import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/preset.dart';
import '../services/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectState {
  final List<Project> projects;
  final int selectedProjectIndex;
  final bool isLoading;
  final bool isInitialized;

  ProjectState({
    required this.projects, 
    required this.selectedProjectIndex,
    this.isLoading = false,
    this.isInitialized = false,
  });

  Project get selectedProject => projects[selectedProjectIndex];
  
  // Méthode pour obtenir le nom traduit d'un projet
  String getTranslatedProjectName(Project project, AppLocalizations localizations) {
    // Si c'est un projet par défaut (nom court comme '1', '2', '3'), utiliser la traduction
    if (project.name.length <= 2 && int.tryParse(project.name) != null) {
      switch (project.name) {
        case '1':
          return localizations.defaultProject1;
        case '2':
          return localizations.defaultProject2;
        case '3':
          return localizations.defaultProject3;
        default:
          return '${localizations.defaultProjectName} ${project.name}';
      }
    }
    
    // Si c'est un projet avec l'ancien format 'default_project_X', utiliser la traduction
    if (project.name.startsWith('default_project_')) {
      final number = project.name.replaceFirst('default_project_', '');
      switch (number) {
        case '1':
          return localizations.defaultProject1;
        case '2':
          return localizations.defaultProject2;
        case '3':
          return localizations.defaultProject3;
        default:
          return '${localizations.defaultProjectName} $number';
      }
    }
    
    // Si c'est un projet avec l'ancien format 'projet X', le migrer vers 'default_project_X'
    if (project.name.startsWith('projet ')) {
      final number = project.name.replaceFirst('projet ', '');
      // Migrer automatiquement vers le format avec clé de traduction
      project.name = 'default_project_$number';
      project.save(); // Sauvegarder la migration
      
      switch (number) {
        case '1':
          return localizations.defaultProject1;
        case '2':
          return localizations.defaultProject2;
        case '3':
          return localizations.defaultProject3;
        default:
          return '${localizations.defaultProjectName} $number';
      }
    }
    
    // Sinon, retourner le nom original (projet personnalisé)
    return project.name;
  }

  ProjectState copyWith({
    List<Project>? projects, 
    int? selectedProjectIndex,
    bool? isLoading,
    bool? isInitialized,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      selectedProjectIndex: selectedProjectIndex ?? this.selectedProjectIndex,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  late Box<Project> _box;
  bool _isInitializing = false;

  ProjectNotifier()
      : super(ProjectState(projects: [], selectedProjectIndex: 0, isLoading: true)) {
    _initAsync();
  }


  // Initialisation asynchrone non-bloquante
  Future<void> _initAsync() async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      state = state.copyWith(isLoading: true);
      
      // Attendre que HiveService soit complètement initialisé
      debugPrint('DEBUG ProjectProvider - Attente de l\'initialisation de HiveService...');
      await HiveService.initialize();
      debugPrint('DEBUG ProjectProvider - HiveService initialisé');
      
      // Attendre un peu plus pour s'assurer que tous les adapters sont enregistrés
      await Future.delayed(const Duration(milliseconds: 100));
      
      // S'assurer que l'adapter Project est enregistré
      if (!Hive.isAdapterRegistered(2)) {
        debugPrint('DEBUG ProjectProvider - Enregistrement de l\'adapter Project');
        Hive.registerAdapter(ProjectAdapter());
      } else {
        debugPrint('DEBUG ProjectProvider - Adapter Project déjà enregistré');
      }
      
      // Utiliser la box globale 'projects' qui a l'adapter Project enregistré
      debugPrint('DEBUG ProjectProvider - Ouverture de la box projects...');
      _box = await Hive.openBox<Project>('projects');
      debugPrint('DEBUG ProjectProvider - Box projects ouverte avec succès');
      
      // Initialiser les projets par défaut si nécessaire
      await _initializeDefaultProjects();
      
      // Charger les projets depuis SharedPreferences (contournement Hive)
      final prefs = await SharedPreferences.getInstance();
      final updatedProjects = <Project>[];
      
      // Créer un projet par défaut avec les paramètres de SharedPreferences
      final defaultProject = Project(id: '1', name: 'default_project_1');
      final location = prefs.getString('project_1_location');
      final mountingDate = prefs.getString('project_1_mounting_date');
      final period = prefs.getString('project_1_period');
      
      debugPrint('DEBUG ProjectProvider - Paramètres SharedPreferences (init):');
      debugPrint('  - Location: $location');
      debugPrint('  - Mounting Date: $mountingDate');
      debugPrint('  - Period: $period');
      
      // Créer un projet mis à jour avec les paramètres de SharedPreferences
      final updatedProject = defaultProject.copyWith(
        location: location?.isNotEmpty == true ? location : defaultProject.location,
        mountingDate: mountingDate?.isNotEmpty == true ? mountingDate : defaultProject.mountingDate,
        period: period?.isNotEmpty == true ? period : defaultProject.period,
      );
      
      updatedProjects.add(updatedProject);
      
      debugPrint('DEBUG ProjectProvider - Projets chargés depuis SharedPreferences: ${updatedProjects.length}');
      
      state = state.copyWith(
        projects: updatedProjects,
        isLoading: false,
        isInitialized: true,
      );
      
      // Essayer de sauvegarder dans Hive en arrière-plan (sans bloquer)
      _trySaveToHiveInBackground(updatedProject);
    } catch (e) {
      debugPrint('DEBUG ProjectProvider - Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, créer des projets par défaut en mémoire
      final fallbackProjects = [
        Project(id: '1', name: 'default_project_1'),
        Project(id: '2', name: 'default_project_2'),
        Project(id: '3', name: 'default_project_3'),
      ];
      
      state = state.copyWith(
        projects: fallbackProjects,
        isLoading: false,
        isInitialized: true,
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initializeDefaultProjects() async {
    debugPrint('DEBUG ProjectProvider - Initialisation des projets par défaut');
    debugPrint('DEBUG ProjectProvider - Box vide: ${_box.isEmpty}');
    debugPrint('DEBUG ProjectProvider - Nombre de projets dans la box: ${_box.length}');
    
    if (_box.isEmpty) {
      debugPrint('DEBUG ProjectProvider - Création des projets par défaut');
      // Créer des projets par défaut avec des noms génériques
      // Ces noms seront remplacés par des traductions dans l'UI
      await _box.add(Project(id: '1', name: 'default_project_1'));
      await _box.add(Project(id: '2', name: 'default_project_2'));
      await _box.add(Project(id: '3', name: 'default_project_3'));
      debugPrint('DEBUG ProjectProvider - Projets par défaut créés: ${_box.length}');
    } else {
      debugPrint('DEBUG ProjectProvider - Migration des projets existants');
      // Migrer les projets existants si nécessaire
      await _migrateExistingProjects();
    }
  }
  
  Future<void> _migrateExistingProjects() async {
    final projects = _box.values.toList();
    bool hasChanges = false;
    
    for (final project in projects) {
      // Si le projet a un nom court comme '1', '2', '3', le migrer vers 'default_project_X'
      if (project.name.length <= 2 && int.tryParse(project.name) != null) {
        final newName = 'default_project_${project.name}';
        project.name = newName;
        await project.save();
        hasChanges = true;
      }
      // Si le projet a l'ancien format 'projet X', le migrer vers 'default_project_X'
      else if (project.name.startsWith('projet ')) {
        final number = project.name.replaceFirst('projet ', '');
        final newName = 'default_project_$number';
        project.name = newName;
        await project.save();
        hasChanges = true;
      }
    }
    
    // Si des changements ont été effectués, mettre à jour l'état
    if (hasChanges) {
      final updatedProjects = _box.values.toList();
      state = state.copyWith(projects: updatedProjects);
    }
  }

  // Méthode publique pour forcer le rechargement si nécessaire
  Future<void> refreshProjects() async {
    if (!state.isInitialized) return;
    
    try {
      state = state.copyWith(isLoading: true);
      
      // Charger les paramètres depuis SharedPreferences directement (contournement Hive)
      final prefs = await SharedPreferences.getInstance();
      final updatedProjects = <Project>[];
      
      // Créer un projet par défaut avec les paramètres de SharedPreferences
      final defaultProject = Project(id: '1', name: 'default_project_1');
      final name = prefs.getString('project_1_name');
      final location = prefs.getString('project_1_location');
      final mountingDate = prefs.getString('project_1_mounting_date');
      final period = prefs.getString('project_1_period');
      
      debugPrint('DEBUG ProjectProvider - Paramètres SharedPreferences:');
      debugPrint('  - Name: $name');
      debugPrint('  - Location: $location');
      debugPrint('  - Mounting Date: $mountingDate');
      debugPrint('  - Period: $period');
      
      // Créer un projet mis à jour avec les paramètres de SharedPreferences
      final updatedProject = defaultProject.copyWith(
        name: name?.isNotEmpty == true ? name : defaultProject.name,
        location: location?.isNotEmpty == true ? location : defaultProject.location,
        mountingDate: mountingDate?.isNotEmpty == true ? mountingDate : defaultProject.mountingDate,
        period: period?.isNotEmpty == true ? period : defaultProject.period,
      );
      
      updatedProjects.add(updatedProject);
      
      debugPrint('DEBUG ProjectProvider - Projet mis à jour avec SharedPreferences: ${updatedProjects.length}');
      state = state.copyWith(projects: updatedProjects, isLoading: false);
      
      // Essayer de sauvegarder dans Hive en arrière-plan (sans bloquer)
      _trySaveToHiveInBackground(updatedProject);
      
    } catch (e) {
      debugPrint('DEBUG ProjectProvider - Erreur lors du rafraîchissement: $e');
      state = state.copyWith(isLoading: false);
    }
  }
  
  // Sauvegarder dans Hive en arrière-plan sans bloquer
  Future<void> _trySaveToHiveInBackground(Project project) async {
    try {
      if (!_box.isOpen) {
        _box = await Hive.openBox<Project>('projects');
      }
      
      final existingIndex = _box.values.toList().indexWhere((p) => p.id == project.id);
      if (existingIndex != -1) {
        await _box.putAt(existingIndex, project);
      } else {
        await _box.add(project);
      }
      debugPrint('DEBUG ProjectProvider - Projet aussi sauvegardé dans Hive');
    } catch (e) {
      debugPrint('DEBUG ProjectProvider - Erreur Hive ignorée (SharedPreferences OK): $e');
    }
  }

  void selectProject(int index) {
    if (index >= 0 && index < state.projects.length) {
      state = state.copyWith(selectedProjectIndex: index);
    } else {
      debugPrint('DEBUG ProjectProvider - Index invalide: $index (projets disponibles: ${state.projects.length})');
    }
  }

  void addProject(Project project) {
    // Ajouter le projet de manière asynchrone mais mettre à jour l'état immédiatement
    Future.microtask(() async {
      await _box.add(project);
    });
    
    // Mettre à jour l'état immédiatement pour l'UI
    final newProjects = [...state.projects, project];
    state = state.copyWith(
      projects: newProjects, 
      selectedProjectIndex: newProjects.length - 1
    );
  }

  void updateProject(Project updatedProject) async {
    // Trouver l'index du projet à mettre à jour
    final index = state.projects.indexWhere((p) => p.id == updatedProject.id);
    if (index == -1) {
      debugPrint('DEBUG ProjectProvider - Projet non trouvé avec ID: ${updatedProject.id}');
      debugPrint('DEBUG ProjectProvider - Projets disponibles: ${state.projects.map((p) => '${p.id}: ${p.name}').join(', ')}');
      return;
    }
    
    // Vérifier si la box est vide
    if (_box.isEmpty) {
      debugPrint('DEBUG ProjectProvider - Box vide, création d\'un projet par défaut');
      await _box.add(updatedProject);
    } else {
      // Sauvegarder dans la box spécifique à l'utilisateur en utilisant l'index
      await _box.putAt(index, updatedProject);
    }
    
    // Mettre à jour seulement le projet modifié
    final newProjects = List<Project>.from(state.projects);
    newProjects[index] = updatedProject;
    state = state.copyWith(projects: newProjects);
    
    debugPrint('DEBUG ProjectProvider - Projet mis à jour avec succès: ${updatedProject.name}');
  }

  void deleteProject(int index) async {
    if (index < 0 || index >= state.projects.length) return;
    
    await state.projects[index].delete();
    final newProjects = _box.values.toList();
    
    final newSelectedIndex = newProjects.isEmpty 
        ? 0 
        : (index == 0 ? 0 : index - 1);
    
    state = state.copyWith(
      projects: newProjects,
      selectedProjectIndex: newSelectedIndex,
    );
  }

  void addPresetToCurrentProject(Preset preset) async {
    if (state.projects.isEmpty) return;
    
    final project = state.selectedProject;
    final updatedProject = project.copyWith(presets: [...project.presets, preset]);
    
    // Sauvegarder dans la box spécifique à l'utilisateur en utilisant l'index
    await _box.putAt(state.selectedProjectIndex, updatedProject);
    
    // Mettre à jour seulement le projet modifié
    final newProjects = List<Project>.from(state.projects);
    newProjects[state.selectedProjectIndex] = updatedProject;
    state = state.copyWith(projects: newProjects);
  }

  void removePresetFromCurrentProject(int presetIndex) async {
    if (state.projects.isEmpty) return;
    
    final project = state.selectedProject;
    if (presetIndex >= 0 && presetIndex < project.presets.length) {
      final updatedPresets = List<Preset>.from(project.presets);
      updatedPresets.removeAt(presetIndex);
      final updatedProject = project.copyWith(presets: updatedPresets);
      
      // Sauvegarder dans la box spécifique à l'utilisateur en utilisant l'index
      await _box.putAt(state.selectedProjectIndex, updatedProject);
      
      // Mettre à jour seulement le projet modifié
      final newProjects = List<Project>.from(state.projects);
      newProjects[state.selectedProjectIndex] = updatedProject;
      state = state.copyWith(projects: newProjects);
    }
  }

  void movePresetToProject(
      int fromProjectIndex, int presetIndex, int toProjectIndex) async {
    if (fromProjectIndex < 0 || fromProjectIndex >= state.projects.length ||
        toProjectIndex < 0 || toProjectIndex >= state.projects.length) {
      return;
    }
    
    final fromProject = state.projects[fromProjectIndex];
    final toProject = state.projects[toProjectIndex];
    
    if (presetIndex >= 0 && presetIndex < fromProject.presets.length) {
      final preset = fromProject.presets[presetIndex];
      
      // Créer les projets mis à jour
      final updatedFromPresets = List<Preset>.from(fromProject.presets);
      updatedFromPresets.removeAt(presetIndex);
      final updatedFromProject = fromProject.copyWith(presets: updatedFromPresets);
      
      final updatedToPresets = List<Preset>.from(toProject.presets);
      updatedToPresets.add(preset);
      final updatedToProject = toProject.copyWith(presets: updatedToPresets);
      
      // Sauvegarder dans la box spécifique à l'utilisateur en utilisant l'index
      await _box.putAt(fromProjectIndex, updatedFromProject);
      await _box.putAt(toProjectIndex, updatedToProject);
      
      // Mettre à jour seulement les projets modifiés
      final newProjects = List<Project>.from(state.projects);
      newProjects[fromProjectIndex] = updatedFromProject;
      newProjects[toProjectIndex] = updatedToProject;
      state = state.copyWith(projects: newProjects);
    }
  }

}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>(
    (ref) {
  final notifier = ProjectNotifier();
  // Initialisation automatique comme pour CatalogueProvider
  Future.delayed(const Duration(milliseconds: 200), () {
    debugPrint('ProjectProvider: Starting delayed initialization');
    notifier._initAsync();
  });
  return notifier;
});
