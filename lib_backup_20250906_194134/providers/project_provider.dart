import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/preset.dart';

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
  static const String boxName = 'projects';
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
      
      // Ouvrir la box Hive
      _box = await Hive.openBox<Project>(boxName);
      
      // Initialiser les projets par défaut si nécessaire
      await _initializeDefaultProjects();
      
      // Charger les projets
      final projects = _box.values.toList();
      
      state = state.copyWith(
        projects: projects,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
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
    if (_box.isEmpty) {
      // Créer des projets par défaut avec des noms génériques
      // Ces noms seront remplacés par des traductions dans l'UI
      await _box.add(Project(id: '1', name: 'default_project_1'));
      await _box.add(Project(id: '2', name: 'default_project_2'));
      await _box.add(Project(id: '3', name: 'default_project_3'));
    } else {
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
      final projects = _box.values.toList();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectProject(int index) {
    if (index >= 0 && index < state.projects.length) {
      state = state.copyWith(selectedProjectIndex: index);
    }
  }

  void addProject(Project project) async {
    await _box.add(project);
    // Mettre à jour seulement la liste des projets sans recharger tout
    final newProjects = _box.values.toList();
    state = state.copyWith(
      projects: newProjects, 
      selectedProjectIndex: newProjects.length - 1
    );
  }

  void renameProject(int index, String newName) async {
    if (index < 0 || index >= state.projects.length) return;
    
    final project = state.projects[index];
    project.name = newName;
    await project.save();
    
    // Mettre à jour seulement le projet modifié
    final newProjects = List<Project>.from(state.projects);
    newProjects[index] = project;
    state = state.copyWith(projects: newProjects);
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
    project.presets.add(preset);
    await project.save();
    
    // Mettre à jour seulement le projet modifié
    final newProjects = List<Project>.from(state.projects);
    final currentIndex = state.selectedProjectIndex;
    newProjects[currentIndex] = project;
    state = state.copyWith(projects: newProjects);
  }

  void removePresetFromCurrentProject(int presetIndex) async {
    if (state.projects.isEmpty) return;
    
    final project = state.selectedProject;
    if (presetIndex >= 0 && presetIndex < project.presets.length) {
      project.presets.removeAt(presetIndex);
      await project.save();
      
      // Mettre à jour seulement le projet modifié
      final newProjects = List<Project>.from(state.projects);
      final currentIndex = state.selectedProjectIndex;
      newProjects[currentIndex] = project;
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
      final preset = fromProject.presets.removeAt(presetIndex);
      await fromProject.save();
      toProject.presets.add(preset);
      await toProject.save();
      
      // Mettre à jour seulement les projets modifiés
      final newProjects = List<Project>.from(state.projects);
      newProjects[fromProjectIndex] = fromProject;
      newProjects[toProjectIndex] = toProject;
      state = state.copyWith(projects: newProjects);
    }
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>(
    (ref) => ProjectNotifier());
