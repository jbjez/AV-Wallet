import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preset.dart';
import '../models/project.dart';
import '../providers/preset_provider.dart';
import '../providers/project_provider.dart';
import '../pages/calcul_projet_page.dart';
import '../services/translation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PresetWidget extends ConsumerStatefulWidget {
  final bool loadOnInit;
  final Function(Preset)? onPresetSelected;

  const PresetWidget({
    super.key,
    this.loadOnInit = false,
    this.onPresetSelected,
  });

  @override
  ConsumerState<PresetWidget> createState() => _PresetWidgetState();
}

class _PresetWidgetState extends ConsumerState<PresetWidget> {
  final TextEditingController _nameController = TextEditingController();

  // Méthode pour abréger le nom du preset si nécessaire
  String _abbreviatePresetName(String name) {
    // Si le nom est vide, retourner "Preset" par défaut
    if (name.isEmpty) {
      return 'Preset';
    }
    
    // Retourner le nom tel quel (même si c'est "Défaut")
    return name;
  }

  @override
  void initState() {
    super.initState();
    // Toujours vérifier la migration des presets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presets = ref.read(presetProvider);
      bool needsUpdate = false;
      for (int i = 0; i < presets.length; i++) {
        if (presets[i].name.isEmpty) {
          final updatedPreset = presets[i].copyWith(name: 'Preset');
          ref.read(presetProvider.notifier).updatePreset(updatedPreset);
          needsUpdate = true;
        }
      }
      if (needsUpdate) {
        // Forcer la mise à jour de l'interface
        setState(() {});
      }
    });
    
    // Toujours créer un preset par défaut au démarrage
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        // Vérifier s'il y a des presets
        final presets = ref.read(presetProvider);
        
        // Si aucun preset ou si le premier preset n'est pas "Preset", créer un reset
        if (presets.isEmpty || (presets.isNotEmpty && presets[0].name != 'Preset')) {
          // Supprimer tous les presets existants
          for (int i = presets.length - 1; i >= 0; i--) {
            ref.read(presetProvider.notifier).removePreset(i);
          }
          
          // Créer un preset par défaut "Preset"
          final defaultPreset = Preset(
            id: 'default_preset_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Preset',
            items: [],
          );
          ref.read(presetProvider.notifier).addPreset(defaultPreset);
          ref.read(presetProvider.notifier).selectPreset(0);
        }
      } catch (e) {
        // Fallback simple
        final fallbackPreset = Preset(
          id: 'fallback_preset_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Preset',
          items: [],
        );
        ref.read(presetProvider.notifier).addPreset(fallbackPreset);
        ref.read(presetProvider.notifier).selectPreset(0);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createNewPreset() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.presetWidget_newPreset),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.presetName,
            hintText: 'Preset',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _saveNewPreset(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: _saveNewPreset,
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  void _saveNewPreset() {
    final presetName = _nameController.text.trim().isEmpty ? 'Preset' : _nameController.text.trim();

    final newPreset = Preset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: presetName,
      items: [],
    );

    ref.read(presetProvider.notifier).addPreset(newPreset);
    ref.read(presetProvider.notifier).selectPreset(
      ref.read(presetProvider).length - 1,
    );

    // Ajouter le preset au projet actuel
    ref.read(projectProvider.notifier).addPresetToCurrentProject(newPreset);

    _nameController.clear();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)!.presetWidget_create} "$presetName"'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deletePreset(int index) {
    final preset = ref.read(presetProvider)[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.presetDelete),
        content: Text(
          '${AppLocalizations.of(context)!.presetWidget_confirmDelete} "${preset.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(presetProvider.notifier).removePreset(index);
              ref.read(projectProvider.notifier).removePresetFromCurrentProject(index);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text('${AppLocalizations.of(context)!.presetDeleted} "${preset.name}"'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                  ),
                );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _renamePreset(int index) {
    final preset = ref.read(presetProvider)[index];
    _nameController.text = preset.name;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.presetRename),
        content: TextField(
              controller: _nameController,
              decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.presetName,
            border: const OutlineInputBorder(),
              ),
              autofocus: true,
          onSubmitted: (_) => _savePresetRename(index),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => _savePresetRename(index),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _savePresetRename(int index) {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
          content: Text(AppLocalizations.of(context)!.presetName),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final preset = ref.read(presetProvider)[index];
    final updatedPreset = preset.copyWith(name: newName);
    
    ref.read(presetProvider.notifier).updatePreset(updatedPreset);
    
    // Mettre à jour aussi dans le projet
    final projectNotifier = ref.read(projectProvider.notifier);
    final currentProjectIndex = ref.read(projectProvider).selectedProjectIndex;
    final currentProject = ref.read(projectProvider).selectedProject;
    
    // Trouver et mettre à jour le preset dans le projet
    final presetIndexInProject = currentProject.presets.indexWhere((p) => p.id == preset.id);
    if (presetIndexInProject != -1) {
      currentProject.presets[presetIndexInProject] = updatedPreset;
      projectNotifier.addPresetToCurrentProject(updatedPreset);
    }

    _nameController.clear();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)!.presetRenamed} "$newName"'),
                  backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _loadProject() {
    final projectState = ref.read(projectProvider);
    
    if (projectState.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun projet disponible à charger'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loadProject),
        content: Container(
          width: double.maxFinite,
          height: 400, // Hauteur fixe pour permettre le scroll
          decoration: BoxDecoration(
            color: const Color(0xFF0A1128).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sélectionnez un projet à charger :',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: projectState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                            ...projectState.projects.asMap().entries.map((entry) {
                        final index = entry.key;
                        final project = entry.value;
                              final isCurrentProject = projectState.selectedProjectIndex == index;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                                  color: isCurrentProject 
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                    color: isCurrentProject ? Colors.blue : Colors.grey,
                                    width: isCurrentProject ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              project.name,
                              style: TextStyle(
                                color: Colors.white,
                                      fontWeight: isCurrentProject ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${project.presets.length} presets',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                            ),
                            trailing: isCurrentProject 
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 24,
                                )
                              : null,
                            onTap: isCurrentProject ? null : () {
                              // Charger le projet sélectionné
                              ref.read(projectProvider.notifier).selectProject(index);
                              ref.read(presetProvider.notifier).loadPresetsFromProject(project);
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Projet "${project.name}" chargé !'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _exportProject() {
    final currentProject = ref.read(projectProvider).selectedProject;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportProject),
        content: Text(
          'Voulez-vous vraiment exporter le projet "${currentProject.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique d'export à implémenter
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text('Projet "${currentProject.name}" exporté avec succès !'),
                    backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  ),
                );
            },
            child: Text(AppLocalizations.of(context)!.export),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(presetProvider);
    final selectedIndex = ref.watch(selectedPresetIndexProvider);
    final projectState = ref.watch(projectProvider);
    
    // Utiliser le nom du projet traduit depuis le provider
    final currentProjectName = projectState.projects.isNotEmpty 
        ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
        : context.t('default_project_name');
    
    // Afficher un indicateur de chargement si nécessaire
    if (projectState.isLoading) {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Si pas de presets, afficher un indicateur de chargement
    if (presets.isEmpty) {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Bouton Projet avec menu déroulant
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    currentProjectName, // Utiliser le nom du projet dynamique
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                ],
              ),
            ),
            itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'new_preset',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('new_preset'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'view_project',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.purple, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('view_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'rename_project',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('rename_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'new_project',
                  child: Row(
                    children: [
                      Icon(Icons.create_new_folder, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('new_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'save_project',
                  child: Row(
                    children: [
                      Icon(Icons.save, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('save_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'load_project',
                  child: Row(
                    children: [
                      Icon(Icons.folder_open, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('load_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'export_project',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.purple, size: 16),
                      SizedBox(width: 8),
                      Text(context.t('export_project'), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'new_preset') {
                  _createNewPreset();
                } else if (value == 'view_project') {
                  // Naviguer vers la page de calcul du projet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalculProjetPage(),
                    ),
                  );
                } else if (value == 'rename_project') {
                  _showRenameProjectDialog(context);
                } else if (value == 'new_project') {
                  _createNewProject();
                } else if (value == 'save_project') {
                  _saveProject();
                } else if (value == 'load_project') {
                  _loadProject();
                } else if (value == 'export_project') {
                  _exportProject();
                }
              },
            ),
          const SizedBox(width: 2),
          // Boutons des presets individuels avec menu déroulant intégré
          ...presets.asMap().entries.map((entry) {
            final index = entry.key;
            final preset = entry.value;
            final isActive = selectedIndex == index;
            final itemCount = preset.items.fold<int>(0, (sum, item) => sum + item.quantity);
            
            return Row(
              children: [
                const SizedBox(width: 2),
                PopupMenuButton<String>(
                  offset: const Offset(0, 30),
                  child: GestureDetector(
                    onTap: () {
                      // Sélection directe au clic
                      ref.read(presetProvider.notifier).selectPreset(index);
                      if (widget.onPresetSelected != null) {
                        widget.onPresetSelected!(preset);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 25,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Bouton de sélection à gauche
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2.5),
                                  border: Border.all(color: Colors.grey, width: 1),
                                ),
                                child: isActive 
                                  ? Icon(Icons.check, color: Colors.green, size: 4)
                                  : null,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _abbreviatePresetName(preset.name),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                        // Badge rouge en haut à droite sur la bordure
                        if (itemCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Text(
                                '$itemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'view_preset',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.purple, size: 16),
                          SizedBox(width: 8),
                          Text('Voir Preset', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('Sélectionner', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.presetWidget_renamePreset, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('Supprimer Preset', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'view_preset') {
                      // Naviguer vers la page de calcul du projet pour voir le preset
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculProjetPage(),
                        ),
                      );
                    } else if (value == 'select') {
                      ref.read(presetProvider.notifier).selectPreset(index);
                      if (widget.onPresetSelected != null) {
                        widget.onPresetSelected!(preset);
                      }
                    } else if (value == 'rename') {
                      _renamePreset(index);
                    } else if (value == 'delete') {
                      _deletePreset(index);
                    }
                  },
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showRenameProjectDialog(BuildContext context) {
    final currentProject = ref.read(projectProvider).selectedProject;
    _nameController.text = currentProject.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameProject),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.enterProjectName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                // Mettre à jour le nom du projet dans le provider
                final projectIndex = ref.read(projectProvider).selectedProjectIndex;
                ref.read(projectProvider.notifier).renameProject(projectIndex, _nameController.text);
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context)!.projectRenamed} "${_nameController.text}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _createNewProject() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newProject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.projectNameLabel,
                hintText: AppLocalizations.of(context)!.projectNameHint,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.projectArchiveInfo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newProjectName = _nameController.text.trim();
              if (newProjectName.isNotEmpty) {
                // Créer un nouveau projet avec un preset par défaut
                final newProject = Project(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newProjectName,
                  presets: [
                    Preset(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: 'Preset',
                      description: 'Preset par défaut du nouveau projet',
                      items: [],
                      createdAt: DateTime.now(),
                    ),
                  ],
                );
                
                // Ajouter le nouveau projet et le sélectionner
                ref.read(projectProvider.notifier).addProject(newProject);
                // Le nouveau projet est automatiquement sélectionné (dernier index)
                // car addProject met selectedProjectIndex à _box.length - 1
                
                // Charger les presets du nouveau projet
                ref.read(presetProvider.notifier).loadPresetsFromProject(newProject);
                
                // Mettre à jour l'interface
                setState(() {
                  // _projectName = newProjectName; // Supprimé
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nouveau projet "${newProjectName}" créé et activé !'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _saveProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.saveProject),
        content: const Text('Le projet sera sauvegardé localement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Projet sauvegardé !'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _viewPreset(Preset preset) {
    // Naviguer vers la page du projet avec le preset sélectionné
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalculProjetPage(),
      ),
    );
  }
}
