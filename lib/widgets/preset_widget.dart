import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../models/preset.dart';
import '../models/project.dart';
import '../providers/preset_provider.dart';
import '../providers/project_provider.dart';
import '../pages/calcul_projet_page.dart';
import '../services/translation_service.dart';
import '../services/freemium_access_service.dart';
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

  void _loadProject() async {
    // Vérifier l'accès aux projets (premium uniquement)
    final hasAccess = await FreemiumAccessService.canAccessProjects(context, ref);
    if (!hasAccess) {
      return; // Le dialog d'accès refusé est affiché automatiquement
    }
    
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

  void _exportProject() async {
    // Vérifier l'accès à l'export (premium uniquement)
    final hasAccess = await FreemiumAccessService.canExport(context, ref);
    if (!hasAccess) {
      return; // Le dialog d'accès refusé est affiché automatiquement
    }
    
    final currentProject = ref.read(projectProvider).selectedProject;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportProject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous exporter le projet "${currentProject.name}" ?'),
            const SizedBox(height: 16),
            Text(
              'L\'export inclura tous les PDFs disponibles :\n• Calculs de puissance\n• Calculs de poids\n• Exports de calculs\n• Photos éventuelles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _generateAndShareProjectFiles(currentProject);
            },
            child: Text(AppLocalizations.of(context)!.export),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndShareProjectFiles(Project project) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Génération des PDFs...'),
            ],
          ),
        ),
      );

      final List<File> filesToShare = [];
      final tempDir = await getTemporaryDirectory();
      final projectDir = Directory('${tempDir.path}/export_${project.name}_${DateTime.now().millisecondsSinceEpoch}');
      await projectDir.create(recursive: true);

      // 1. Générer le PDF de résumé du projet
      final projectSummaryPdf = await _generateProjectSummaryPdf(project, projectDir.path);
      if (projectSummaryPdf != null) {
        filesToShare.add(projectSummaryPdf);
      }

      // 2. Générer les PDFs de calculs de puissance et poids
      final powerPdf = await _generateCalculationPdf(project, 'power', projectDir.path);
      if (powerPdf != null) {
        filesToShare.add(powerPdf);
      }

      final weightPdf = await _generateCalculationPdf(project, 'weight', projectDir.path);
      if (weightPdf != null) {
        filesToShare.add(weightPdf);
      }

      // 3. Générer les PDFs des presets individuels
      for (final preset in project.presets) {
        final presetPdf = await _generatePresetPdf(preset, projectDir.path);
        if (presetPdf != null) {
          filesToShare.add(presetPdf);
        }
      }

      // Fermer le dialog de chargement
      if (context.mounted) Navigator.pop(context);

      if (filesToShare.isNotEmpty) {
        // Partager tous les fichiers
        await Share.shareXFiles(
          filesToShare.map((file) => XFile(file.path)).toList(),
          text: 'Export complet du projet "${project.name}"\n\nGénéré le ${DateTime.now().toString().split('.')[0]}\n\nBy AVWallet®',
          subject: 'Export Projet ${project.name}',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${filesToShare.length} fichiers exportés avec succès !'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun fichier à exporter pour ce projet'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> _generateProjectSummaryPdf(Project project, String outputPath) async {
    try {
      // Récupérer les photos du projet
      final List<String> photos = await _getProjectPhotos(project.name);

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Résumé du Projet',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'AVWallet®',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.Text(
                'Projet: ${project.name}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Date de création: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Presets (${project.presets.length}):',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...project.presets.map((preset) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, bottom: 8),
                child: pw.Text(
                  '• ${preset.name} (${preset.items.length} articles)',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              )),
              
              // Section Photos
              if (photos.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Text('PHOTOS DU PROJET', 
                       style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Photos capturées lors des mesures AR:', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...photos.map((photoPath) {
                  try {
                    final file = File(photoPath);
                    if (file.existsSync()) {
                      final imageBytes = file.readAsBytesSync();
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Photo: ${photoPath.split('/').last}', 
                                   style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Image(
                              pw.MemoryImage(imageBytes),
                              width: 200,
                              height: 150,
                              fit: pw.BoxFit.cover,
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erreur lors du chargement de la photo $photoPath: $e');
                  }
                  return pw.SizedBox.shrink();
                }).toList(),
              ],
            ];
          },
        ),
      );

      final file = File('$outputPath/resume_projet_${project.name}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Erreur génération PDF résumé: $e');
      return null;
    }
  }

  Future<File?> _generateCalculationPdf(Project project, String type, String outputPath) async {
    try {
      // Calculer les totaux pour ce type
      double totalValue = 0;
      int totalItems = 0;
      
      for (final preset in project.presets) {
        for (final item in preset.items) {
          totalItems += item.quantity;
          if (type == 'power') {
            // Calcul de puissance (exemple)
            final power = double.tryParse(item.item.conso.replaceAll(' W', '')) ?? 0;
            totalValue += power * item.quantity;
          } else {
            // Calcul de poids (exemple)
            final weight = double.tryParse(item.item.poids.replaceAll(' kg', '')) ?? 0;
            totalValue += weight * item.quantity;
          }
        }
      }

      // Récupérer les photos du projet
      final List<String> photos = await _getProjectPhotos(project.name);

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Calcul ${type == 'power' ? 'Puissance' : 'Poids'} - ${project.name}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'AVWallet®',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.Text(
                'Total ${type == 'power' ? 'Puissance' : 'Poids'}: ${type == 'power' ? (totalValue / 1000).toStringAsFixed(2) : totalValue.toStringAsFixed(2)} ${type == 'power' ? 'kW' : 'kg'}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Articles: $totalItems',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Détail par preset:',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...project.presets.map((preset) {
                double presetValue = 0;
                int presetItems = 0;
                
                for (final item in preset.items) {
                  presetItems += item.quantity;
                  if (type == 'power') {
                    final power = double.tryParse(item.item.conso.replaceAll(' W', '')) ?? 0;
                    presetValue += power * item.quantity;
                  } else {
                    final weight = double.tryParse(item.item.poids.replaceAll(' kg', '')) ?? 0;
                    presetValue += weight * item.quantity;
                  }
                }
                
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20, bottom: 8),
                  child: pw.Text(
                    '• ${preset.name}: ${type == 'power' ? (presetValue / 1000).toStringAsFixed(2) : presetValue.toStringAsFixed(2)} ${type == 'power' ? 'kW' : 'kg'} (${presetItems} articles)',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                );
              }),
              
              // Section Photos
              if (photos.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Text('PHOTOS DU PROJET', 
                       style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Photos capturées lors des mesures AR:', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...photos.map((photoPath) {
                  try {
                    final file = File(photoPath);
                    if (file.existsSync()) {
                      final imageBytes = file.readAsBytesSync();
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Photo: ${photoPath.split('/').last}', 
                                   style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Image(
                              pw.MemoryImage(imageBytes),
                              width: 200,
                              height: 150,
                              fit: pw.BoxFit.cover,
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erreur lors du chargement de la photo $photoPath: $e');
                  }
                  return pw.SizedBox.shrink();
                }).toList(),
              ],
            ];
          },
        ),
      );

      final file = File('$outputPath/calcul_${type}_${project.name}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Erreur génération PDF calcul: $e');
      return null;
    }
  }

  Future<File?> _generatePresetPdf(Preset preset, String outputPath) async {
    try {
      if (preset.items.isEmpty) return null;

      // Récupérer les photos du projet (on utilise le nom du preset comme nom de projet)
      final List<String> photos = await _getProjectPhotos(preset.name);

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Preset: ${preset.name}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'AVWallet®',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.Text(
                'Description: ${preset.description}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Articles (${preset.items.length}):',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Article', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Puissance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Poids', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...preset.items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item.item.marque} - ${item.item.produit}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.item.conso),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.item.poids),
                      ),
                    ],
                  )),
                ],
              ),
              
              // Section Photos
              if (photos.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Text('PHOTOS DU PROJET', 
                       style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Photos capturées lors des mesures AR:', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...photos.map((photoPath) {
                  try {
                    final file = File(photoPath);
                    if (file.existsSync()) {
                      final imageBytes = file.readAsBytesSync();
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Photo: ${photoPath.split('/').last}', 
                                   style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Image(
                              pw.MemoryImage(imageBytes),
                              width: 200,
                              height: 150,
                              fit: pw.BoxFit.cover,
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erreur lors du chargement de la photo $photoPath: $e');
                  }
                  return pw.SizedBox.shrink();
                }).toList(),
              ],
            ];
          },
        ),
      );

      final file = File('$outputPath/preset_${preset.name.replaceAll(' ', '_')}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Erreur génération PDF preset: $e');
      return null;
    }
  }

  Future<List<String>> _getProjectPhotos(String projectName) async {
    final List<String> photos = [];
    
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${documentsDir.path}/projets/$projectName/photos_ar');
      
      if (await projectDir.exists()) {
        final files = await projectDir.list().toList();
        for (final file in files) {
          if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
            photos.add(file.path);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des photos: $e');
    }
    
    return photos;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Première ligne : Bouton Projet + 2 premiers presets
          Row(
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
              // Premiers 2 presets sur la première ligne
              ...presets.take(2).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final preset = entry.value;
            final isActive = selectedIndex == index;
            final itemCount = preset.items.fold<int>(0, (sum, item) => sum + item.quantity);
            
            return Row(
              children: [
                const SizedBox(width: 2),
                Row(
                  children: [
                    // Bouton de sélection séparé - plus grand et plus facile à cliquer
                    GestureDetector(
                      onTap: () {
                        // Sélection directe au clic sur le bouton de sélection
                        ref.read(presetProvider.notifier).selectPreset(index);
                        if (widget.onPresetSelected != null) {
                          widget.onPresetSelected!(preset);
                        }
                      },
                      child: Container(
                        width: 20,
                        height: 25,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey[600],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive ? Colors.green[300]! : Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: isActive 
                            ? Icon(Icons.check, color: Colors.white, size: 12)
                            : Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // Bouton preset avec menu déroulant
                    PopupMenuButton<String>(
                      offset: const Offset(0, 30),
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
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'view_preset',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.view_preset, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.rename_preset, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.delete_preset, style: TextStyle(fontSize: 12)),
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
                        } else if (value == 'rename') {
                          _renamePreset(index);
                        } else if (value == 'delete') {
                          _deletePreset(index);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
            ],
          ),
          // Deuxième ligne : Presets restants (à partir du 3ème)
          if (presets.length > 2) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                // Espacement pour aligner avec les presets de la première ligne
                const SizedBox(width: 0),
                ...presets.skip(2).toList().asMap().entries.map((entry) {
                  final index = entry.key + 2; // Ajuster l'index pour les presets restants
                  final preset = entry.value;
                  final isActive = selectedIndex == index;
                  final itemCount = preset.items.fold<int>(0, (sum, item) => sum + item.quantity);
                  
                  return Row(
                    children: [
                      const SizedBox(width: 2),
                      Row(
                        children: [
                          // Bouton de sélection séparé - plus grand et plus facile à cliquer
                          GestureDetector(
                            onTap: () {
                              // Sélection directe au clic sur le bouton de sélection
                              ref.read(presetProvider.notifier).selectPreset(index);
                              if (widget.onPresetSelected != null) {
                                widget.onPresetSelected!(preset);
                              }
                            },
                            child: Container(
                              width: 20,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.grey[600],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive ? Colors.green[300]! : Colors.grey[400]!,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: isActive 
                                  ? Icon(Icons.check, color: Colors.white, size: 12)
                                  : Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Bouton preset avec menu déroulant
                          PopupMenuButton<String>(
                            offset: const Offset(0, 30),
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
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'view_preset',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, color: Colors.blue, size: 16),
                                    SizedBox(width: 8),
                                    Text(AppLocalizations.of(context)!.view_preset, style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.orange, size: 16),
                                    SizedBox(width: 8),
                                    Text(AppLocalizations.of(context)!.rename_preset, style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 16),
                                    SizedBox(width: 8),
                                    Text(AppLocalizations.of(context)!.delete_preset, style: TextStyle(fontSize: 12)),
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
                              } else if (value == 'rename') {
                                _renamePreset(index);
                              } else if (value == 'delete') {
                                _deletePreset(index);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Réduit de 50%
            ),
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
                print('Création du projet: ${newProject.name}');
                ref.read(projectProvider.notifier).addProject(newProject);
                
                // Charger les presets du nouveau projet
                ref.read(presetProvider.notifier).loadPresetsFromProject(newProject);
                print('Projet créé et presets chargés');
                
                // Mettre à jour l'interface
                setState(() {
                  // L'interface se mettra à jour automatiquement via les providers
                });
                
                Navigator.pop(context);
                // SnackBar supprimé comme demandé
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Réduit de 50%
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _saveProject() async {
    // Vérifier l'accès aux projets (premium uniquement)
    final hasAccess = await FreemiumAccessService.canAccessProjects(context, ref);
    if (!hasAccess) {
      return; // Le dialog d'accès refusé est affiché automatiquement
    }
    
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

}

