import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../providers/preset_provider.dart';
import '../providers/project_provider.dart';
import '../providers/project_calculation_provider.dart';
import '../providers/preset_pdf_provider.dart';
import '../models/project_calculation.dart';
import '../models/preset.dart';
import '../models/project.dart';
import '../widgets/action_button.dart';
import '../theme/button_styles.dart';

class ExportWidget extends ConsumerWidget {
  final String title;
  final String content;
  final String? presetName;
  final DateTime? exportDate;
  final List<Map<String, String>>? additionalData;
  final IconData? customIcon;
  final Color? backgroundColor;
  final String? tooltip;
  
  // Nouvelles propriétés pour les données du patch
  final List<Map<String, dynamic>>? patchInputs;
  final List<Map<String, dynamic>>? patchOutputs;
  final Map<String, dynamic>? patchSummary;
  
  // Nouvelles propriétés pour les données de projet
  final List<Map<String, dynamic>>? projectData;
  final String? projectType; // 'weight', 'power', 'light', 'dmx', 'driver'
  final Map<String, dynamic>? projectSummary;
  final String? fileName; // Nom de fichier personnalisé
  
  // Propriétés pour les photos
  final List<String>? photoPaths; // Chemins vers les photos à inclure
  final String? projectName; // Nom du projet pour récupérer les photos
  
  // Propriétés pour les PDFs de calculs importés
  final List<Map<String, dynamic>>? importedPdfs; // PDFs de calculs importés

  const ExportWidget({
    super.key,
    required this.title,
    required this.content,
    this.presetName,
    this.exportDate,
    this.additionalData,
    this.customIcon,
    this.backgroundColor,
    this.tooltip,
    this.patchInputs,
    this.patchOutputs,
    this.patchSummary,
    this.projectData,
    this.projectType,
    this.projectSummary,
    this.fileName,
    this.photoPaths,
    this.projectName,
    this.importedPdfs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Utiliser la même couleur que le bouton calcul : Colors.blueGrey[900]
    final buttonColor = Colors.blueGrey[900]!;
    
    final ButtonStyle effectiveStyle = backgroundColor != null
        ? ButtonStyles.actionButtonStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll<Color>(backgroundColor!),
          )
        : ButtonStyles.actionButtonStyle;
    
    return PopupMenuButton<String>(
      tooltip: tooltip ?? 'Exporter',
      color: backgroundColor ?? buttonColor, // Aligner la couleur du menu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'project',
          child: Row(
            children: [
              Icon(Icons.folder, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                'Vers Projet',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sms',
          child: Row(
            children: [
              Icon(Icons.sms, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(
                'SMS',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'whatsapp',
          child: Row(
            children: [
              Icon(Icons.chat_bubble, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(
                'WhatsApp',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'email',
          child: Row(
            children: [
              Icon(Icons.email, color: Colors.lightBlue, size: 20),
              const SizedBox(width: 12),
              Text(
                'Email',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleExport(context, ref, value),
      child: ActionButton(
        icon: customIcon ?? Icons.cloud_upload,
        iconSize: 28,
        color: Colors.white, // Toujours blanc pour la cohérence
        style: effectiveStyle,
        enabled: true,
      ),
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, String exportType) async {
    try {
      // Générer le PDF
      final pdfFile = await _generatePdf(ref, context);
      
      // Construire le message simple (titre + date)
      String exportMessage = _buildSimpleMessage();
      
      // Gérer l'export selon le type
      switch (exportType) {
        case 'project':
          if (context.mounted) _exportToProject(context, ref, exportMessage, pdfFile);
          break;
        case 'sms':
          if (context.mounted) _exportViaSms(context, exportMessage, pdfFile);
          break;
        case 'whatsapp':
          if (context.mounted) _exportViaWhatsApp(context, exportMessage, pdfFile);
          break;
        case 'email':
          if (context.mounted) _exportViaEmail(context, ref, exportMessage, pdfFile);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        // Erreur silencieuse - pas de SnackBar
      }
    }
  }

  String _buildSimpleMessage() {
    final date = exportDate ?? DateTime.now();
    return '$title\n📅 ${date.toString().split('.')[0]}\n\nBy AVWallet®';
  }

  Future<List<String>> _getProjectPhotos() async {
    final List<String> photos = [];
    
    // Si des chemins de photos sont fournis directement
    if (photoPaths != null && photoPaths!.isNotEmpty) {
      photos.addAll(photoPaths!);
    }
    
    // Si un nom de projet est fourni, récupérer les photos du projet
    if (projectName != null) {
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
        debugPrint('Erreur lors de la récupération des photos: $e');
      }
    }
    
    return photos;
  }

  // Méthode pour récupérer les détails du projet actuel
  Map<String, String?> _getProjectDetails(WidgetRef ref, BuildContext context) {
    try {
      final projectState = ref.read(projectProvider);
      final project = projectState.selectedProject;
      
      // Fonction helper pour traduire le nom du projet
      String getTranslatedProjectName(Project project) {
        switch (project.name) {
          case 'default_project_1':
            return 'Projet 1';
          case 'default_project_2':
            return 'Projet 2';
          case 'default_project_3':
            return 'Projet 3';
          default:
            return project.name;
        }
      }
      
      return {
        'name': getTranslatedProjectName(project),
        'location': project.location,
        'mountingDate': project.mountingDate,
        'period': project.period,
      };
    } catch (e) {
      debugPrint('Erreur récupération détails projet: $e');
      return {
        'name': 'Projet',
        'location': null,
        'mountingDate': null,
        'period': null,
      };
    }
  }

  Future<File> _generatePdf(WidgetRef ref, BuildContext context) async {
    try {
    // Créer le document PDF
    final pdf = pw.Document();
    
    // Récupérer les photos du projet et les détails du projet
    final photos = await _getProjectPhotos();
    final projectDetails = _getProjectDetails(ref, context);
    
    // Ajouter la page avec pagination automatique
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Date: ${(exportDate ?? DateTime.now()).toString().split('.')[0]}', 
                       style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 15),
                
                // Section NomProjet avec détails du projet
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NomProjet',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        projectDetails['name'] ?? 'Projet',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Lieu: ${projectDetails['location'] ?? 'Non défini'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Date montage: ${projectDetails['mountingDate'] ?? 'Non définie'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Période: ${projectDetails['period'] ?? 'Non définie'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Divider(color: PdfColors.grey, thickness: 1),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Divider(color: PdfColors.grey, thickness: 1),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'By ',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                    pw.Text(
                      'AVWallet',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                    ),
                    pw.Text(
                      '®',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                      textAlign: pw.TextAlign.start,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Contenu selon le type de projet
            if (projectType != null) ...[
              _buildProjectContent(),
            ] else if (patchInputs != null && patchInputs!.isNotEmpty) ...[
              // Tableau INPUT
              pw.Text('INPUT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildInputTableFromData(),
              pw.SizedBox(height: 20),
              
              // Tableau OUTPUT
              if (patchOutputs != null && patchOutputs!.isNotEmpty) ...[
                pw.Text('OUTPUT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildOutputTableFromData(),
                pw.SizedBox(height: 20),
              ],
              
              // Résumé
              if (patchSummary != null) ...[
                pw.Text('RÉSUMÉ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildSummaryTableFromData(),
                pw.SizedBox(height: 20),
              ],
            ] else ...[
              // Contenu par défaut
              pw.Text('RÉSUMÉ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(content, style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
            ],
              
              // Section PDFs de calculs importés - toujours ajoutée si des PDFs existent
              if (importedPdfs != null && importedPdfs!.isNotEmpty) ...[
                pw.Text('CALCULS IMPORTÉS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildImportedPdfsSection(importedPdfs!),
                pw.SizedBox(height: 20),
              ],
            
            // Section Photos - toujours ajoutée si des photos existent
            if (photos.isNotEmpty) ...[
              pw.Text('PHOTOS DU PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildPhotosSection(photos),
              pw.SizedBox(height: 20),
            ],
          ];
        },
      ),
    );
      
      // Sauvegarder le PDF avec gestion d'erreur améliorée
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = this.fileName ?? 'export_$timestamp';
      final filePath = '${directory.path}/$fileName.pdf';
      
      debugPrint('Sauvegarde PDF vers: $filePath');
    
    // Générer les bytes du PDF
    final pdfBytes = await pdf.save();
      debugPrint('PDF généré: ${pdfBytes.length} bytes');
      
      // Créer le fichier
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // Vérifier que le fichier existe et est lisible
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('Fichier PDF créé: $filePath ($fileSize bytes)');
        
        // Forcer la synchronisation du système de fichiers
        // Le fichier est déjà synchronisé après writeAsBytes
        
        return file;
      } else {
        throw Exception('Le fichier PDF n\'a pas pu être créé');
      }
    } catch (e) {
      debugPrint('Erreur lors de la génération du PDF: $e');
      rethrow;
    }
  }



  // Méthode helper pour récupérer tous les fichiers à partager
  Future<List<XFile>> _getAllFilesToShare(File pdfFile) async {
    final allFilesToShare = <XFile>[XFile(pdfFile.path)];
    
    // Ajouter tous les PDFs importés
    if (importedPdfs != null && importedPdfs!.isNotEmpty) {
      for (final pdfMap in importedPdfs!) {
        final pdfPath = pdfMap['path'] as String;
        final pdfFile = File(pdfPath);
        
        if (await pdfFile.exists()) {
          allFilesToShare.add(XFile(pdfPath));
        }
      }
    }
    
    // Ajouter toutes les photos du projet
    final photos = await _getProjectPhotos();
    for (final photoPath in photos) {
      final photoFile = File(photoPath);
      if (await photoFile.exists()) {
        allFilesToShare.add(XFile(photoPath));
      }
    }
    
    return allFilesToShare;
  }

  Future<void> _exportViaSms(BuildContext context, String message, File pdfFile) async {
    try {
      // Récupérer tous les fichiers à partager
      final allFilesToShare = await _getAllFilesToShare(pdfFile);
      
      await Share.shareXFiles(allFilesToShare, text: message);
      debugPrint('Export SMS réussi avec ${allFilesToShare.length} fichiers');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${allFilesToShare.length} fichier(s) partagé(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'export SMS: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur SMS: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportViaWhatsApp(BuildContext context, String message, File pdfFile) async {
    try {
      debugPrint('Tentative d\'export WhatsApp avec fichier: ${pdfFile.path}');
      
      // Vérifier que le fichier existe et est accessible
      if (!await pdfFile.exists()) {
        throw Exception('Le fichier PDF n\'existe pas: ${pdfFile.path}');
      }
      
      final fileSize = await pdfFile.length();
      debugPrint('Taille du fichier PDF: $fileSize bytes');
      
      // Pour WhatsApp, partager tous les fichiers
      final allFilesToShare = await _getAllFilesToShare(pdfFile);
      await Share.shareXFiles(allFilesToShare, text: message);
      debugPrint('Export WhatsApp réussi avec ${allFilesToShare.length} fichiers');
      
      if (context.mounted) {
        // Export WhatsApp réussi - pas de SnackBar
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'export WhatsApp: $e');
      // Fallback vers WhatsApp Web si l'app n'est pas disponible
      try {
        final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        
        if (launched) {
          debugPrint('WhatsApp Web ouvert');
          if (context.mounted) {
            // WhatsApp Web ouvert - pas de SnackBar
          }
        } else {
          throw Exception('Impossible d\'ouvrir WhatsApp Web');
        }
      } catch (e2) {
        debugPrint('Erreur WhatsApp Web: $e2');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur WhatsApp: ${e2.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _exportViaEmail(BuildContext context, WidgetRef ref, String message, File pdfFile) async {
    try {
      debugPrint('Tentative d\'export Email avec fichier: ${pdfFile.path}');
      
      // Vérifier que le fichier existe et est accessible
      if (!await pdfFile.exists()) {
        throw Exception('Le fichier PDF n\'existe pas: ${pdfFile.path}');
      }
      
      final fileSize = await pdfFile.length();
      debugPrint('Taille du fichier PDF: $fileSize bytes');
      
      // Pour Email, partager tous les fichiers
      final allFilesToShare = await _getAllFilesToShare(pdfFile);
      await Share.shareXFiles(allFilesToShare, text: message);
      debugPrint('Export Email réussi avec ${allFilesToShare.length} fichiers');
      
      if (context.mounted) {
        // Export Email réussi - pas de SnackBar
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'export Email: $e');
      // Fallback vers l'app email si disponible
      try {
        final canOpenEmail = await canLaunchUrl(Uri.parse('mailto:'));
        
        if (!canOpenEmail) {
          debugPrint('App email non disponible');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('App email non disponible')),
            );
          }
          return;
        }

        final subject = presetName != null 
            ? '$title - $presetName'
            : title;
        
        final emailUrl = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(message)}');
        final launched = await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
        
        if (launched) {
          debugPrint('App email ouverte');
          if (context.mounted) {
            // App email ouverte - pas de SnackBar
          }
        } else {
          throw Exception('Impossible d\'ouvrir l\'app email');
        }
      } catch (e2) {
        debugPrint('Erreur app email: $e2');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur Email: ${e2.toString()}')),
          );
        }
      }
    }
  }

  void _exportToProject(BuildContext context, WidgetRef ref, String exportMessage, File pdfFile) async {
    try {
      // Récupérer le preset actif et le projet
      final activePreset = ref.read(activePresetProvider);
      final project = ref.read(projectProvider).selectedProject;
      
      // Si pas de preset actif, créer un preset par défaut
      if (activePreset == null) {
        final defaultPreset = Preset(
          id: 'default_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Preset par défaut',
          items: [],
        );
        ref.read(presetProvider.notifier).addPreset(defaultPreset);
        ref.read(presetProvider.notifier).setActivePresetIndex(0);
      }

      // Récupérer à nouveau les valeurs après création si nécessaire
      final finalPreset = ref.read(activePresetProvider) ?? Preset(
        id: 'default_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Preset par défaut',
        items: [],
      );
      
      final finalProject = ref.read(projectProvider).selectedProject ?? Project(
        id: 'default_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Projet par défaut',
      );

      // Ajouter seulement le calcul aux calculs du projet (PAS d'article au preset)
      final calculationType = _getCalculationTypeFromProjectType(projectType);
      final calculation = ProjectCalculation(
        id: 'export_${DateTime.now().millisecondsSinceEpoch}',
        projectId: finalProject.id,
        name: title, // Utiliser directement le titre passé en paramètre
        totalPower: (projectSummary?['totalPower'] as num?)?.toDouble() ?? 0.0,
        totalWeight: 0.0, // TODO: à remplacer par la vraie valeur si on l'a plus tard
        createdAt: DateTime.now(),
        type: calculationType ?? 'general',
        data: {
          'exportType': projectType ?? 'general',
          'presetName': finalPreset.name,
          'fileName': pdfFile.path.split('/').last,
          'summary': projectSummary?.toString() ?? '',
          'description': 'Export généré le ${DateTime.now().toString().substring(0, 16)}',
        },
        filePath: pdfFile.path,
      );
      
      ref.read(projectCalculationProvider.notifier).addCalculation(calculation);
      debugPrint('DEBUG ExportWidget - Calcul ajouté au projectCalculationProvider: ${calculation.id}');
      
      // AUSSI sauvegarder dans presetPdfProvider pour que les badges fonctionnent
      final pdfMap = {
        'id': calculation.id,
        'name': calculation.name,
        'path': pdfFile.path,
        'presetId': finalPreset.id,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'type': calculationType ?? 'general',
        'projectType': projectType ?? 'general',
      };
      
      debugPrint('DEBUG ExportWidget - Ajout PDF au presetPdfProvider: ${finalPreset.id}');
      debugPrint('DEBUG ExportWidget - PDF Map: $pdfMap');
      
      await ref.read(presetPdfProvider(finalPreset.id).notifier).addPdf(pdfMap);
      debugPrint('DEBUG ExportWidget - PDF ajouté avec succès au presetPdfProvider');
      
    } catch (e) {
      // Erreur silencieuse - pas de SnackBar
    }
  }

  String? _getCalculationTypeFromProjectType(String? projectType) {
    switch (projectType) {
      case 'weight':
        return 'poids';
      case 'power':
        return 'puissance';
      case 'light':
        return 'dmx';
      case 'dmx':
        return 'dmx';
      case 'driver':
        return 'led';
      case 'led_wall':
        return 'led';
      case 'faisceau':
        return 'faisceau';
      case 'structure':
        return 'charge';
      case 'amp':
        return 'son';
      case 'proj':
        return 'proj';
      case 'video':
        return 'video';
      default:
        return 'general'; // Type général pour les exports non spécifiques
    }
  }

  pw.Widget _buildProjectContent() {
    switch (projectType) {
      case 'weight':
        return _buildWeightProjectContent();
      case 'power':
        return _buildPowerProjectContent();
      case 'light':
        return _buildLightProjectContent();
      case 'dmx':
        return _buildDmxProjectContent();
      case 'driver':
        return _buildDriverProjectContent();
      case 'led_wall':
        return _buildLedWallProjectContent();
      case 'sound':
        return _buildSoundProjectContent();
      case 'structure':
        return _buildStructureProjectContent();
      default:
        return pw.Text('Type de projet non reconnu', style: pw.TextStyle(fontSize: 12));
    }
  }

  pw.Widget _buildWeightProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RÉSUMÉ POIDS PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Résumé global
        if (projectSummary != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('TOTAL GLOBAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids total:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalWeight'] ?? '0.00'} kg', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre d\'articles:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalItems'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre d\'exports:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalExports'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre de presets:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['presetCount'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
        ],
        
        // Détail par preset
        if (projectData != null && projectData!.isNotEmpty) ...[
          pw.Text('DÉTAIL PAR PRESET', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...projectData!.map((presetData) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${presetData['presetName'] ?? 'Preset'}', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${presetData['totalWeight'] ?? '0.00'} kg', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Articles:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${presetData['itemCount'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  pw.Widget _buildPowerProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RÉSUMÉ PUISSANCE PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Résumé global
        if (projectSummary != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('TOTAL GLOBAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Puissance totale:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalPower'] ?? '0.00'} W', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre d\'articles:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalItems'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre d\'exports:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['totalExports'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre de presets:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['presetCount'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
        ],
        
        // Détail par preset
        if (projectData != null && projectData!.isNotEmpty) ...[
          pw.Text('DÉTAIL PAR PRESET', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...projectData!.map((presetData) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${presetData['presetName'] ?? 'Preset'}', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Puissance:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${presetData['totalPower'] ?? '0.00'} W', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Articles:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${presetData['itemCount'] ?? '0'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  pw.Widget _buildLightProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RÉSUMÉ LUMIÈRE PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Contenu spécifique à la lumière
        pw.Text(content, style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 20),
        
        // Données additionnelles
        if (additionalData != null && additionalData!.isNotEmpty) ...[
          pw.Text('DONNÉES TECHNIQUES', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...additionalData!.map((data) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${data.keys.first}:', style: pw.TextStyle(fontSize: 11)),
                pw.Text(data.values.first, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          )),
        ],
      ],
    );
  }

  pw.Widget _buildDmxProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RÉSUMÉ DMX PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Contenu DMX
        pw.Text(content, style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 20),
        
        // Données additionnelles
        if (additionalData != null && additionalData!.isNotEmpty) ...[
          pw.Text('CONFIGURATION DMX', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...additionalData!.map((data) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${data.keys.first}:', style: pw.TextStyle(fontSize: 11)),
                pw.Text(data.values.first, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          )),
        ],
      ],
    );
  }

  pw.Widget _buildDriverProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RÉSUMÉ DRIVER LED PROJET', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Contenu Driver LED
        pw.Text(content, style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 20),
        
        // Données additionnelles
        if (additionalData != null && additionalData!.isNotEmpty) ...[
          pw.Text('CONFIGURATION DRIVER', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...additionalData!.map((data) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${data.keys.first}:', style: pw.TextStyle(fontSize: 11)),
                pw.Text(data.values.first, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          )),
        ],
      ],
    );
  }

  pw.Widget _buildInputTableFromData() {
    if (patchInputs == null || patchInputs!.isEmpty) {
      return pw.Text('Aucune donnée INPUT disponible');
    }
    
    // Créer le tableau
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),   // N°
        1: const pw.FixedColumnWidth(120),  // Source (maintenant en 2ème)
        2: const pw.FixedColumnWidth(80),   // Nom Piste (maintenant en 3ème)
        3: const pw.FixedColumnWidth(100),  // Microphone
        4: const pw.FixedColumnWidth(100),  // Pied de micro
        5: const pw.FixedColumnWidth(80),   // Type
        6: const pw.FixedColumnWidth(60),   // Qté
      },
      children: [
        // En-tête du tableau
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('N°', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Source', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Nom Piste', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Microphone', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Pied de micro', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Données du tableau
        ...patchInputs!.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${index + 1}', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['source'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['trackName'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['microphone'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['microphoneStand'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['type'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${data['quantity'] ?? 1}', style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildOutputTableFromData() {
    if (patchOutputs == null || patchOutputs!.isEmpty) {
      return pw.Text('Aucune donnée OUTPUT disponible');
    }
    
    // Créer le tableau
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),   // N°
        1: const pw.FixedColumnWidth(80),   // Nom Piste
        2: const pw.FixedColumnWidth(120),  // Destination
        3: const pw.FixedColumnWidth(100),  // Type
        4: const pw.FixedColumnWidth(80),   // Stéréo/Mono
        5: const pw.FixedColumnWidth(60),   // Qté
      },
      children: [
        // En-tête du tableau
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('N°', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Nom Piste', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Destination', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Stéréo/Mono', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Données du tableau
        ...patchOutputs!.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${index + 1}', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['trackName'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['destination'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['type'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(data['stereoMono'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${data['quantity'] ?? 1}', style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildSummaryTableFromData() {
    if (patchSummary == null || patchSummary!.isEmpty) {
      return pw.Text('Aucun résumé disponible');
    }
    
    // Créer le tableau de résumé
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(200),  // Description
        1: const pw.FixedColumnWidth(100),  // Valeur
      },
      children: [
        // En-tête du tableau
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Valeur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Données du résumé
        ...patchSummary!.entries.map((entry) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('${entry.value}', style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildLedWallProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MUR LED - PLAN ET DÉTAILS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Informations sur le matériel sélectionné
        if (projectSummary != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('MATÉRIEL SÉLECTIONNÉ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Modèle:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['mur_led'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Marque:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['marque'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Produit:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['produit'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dimensions par dalle:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['dimensions_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Résolution par dalle:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['resolution_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids par dalle:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['poids_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Consommation par dalle:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['consommation_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 15),
        ],
          
        // Calculs détaillés
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.green300),
              borderRadius: pw.BorderRadius.circular(8),
            color: PdfColors.green50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
              pw.Text('CALCULS DÉTAILLÉS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
              
              // Configuration du mur
              pw.Text('Configuration du mur:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
              pw.Text('• Nombre de dalles: ${projectSummary?['nb_dalles'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Disposition: ${projectSummary?['largeur_mur'] ?? 'N/A'}x${projectSummary?['hauteur_mur'] ?? 'N/A'} dalles', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Dimensions totales: ${projectSummary?['largeur_totale'] ?? 'N/A'}m x ${projectSummary?['hauteur_totale'] ?? 'N/A'}m', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              
              // Calculs pixellaires
              pw.Text('Calculs pixellaires:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
              pw.Text('• Résolution totale: ${projectSummary?['largeur_pixels'] ?? 'N/A'}px x ${projectSummary?['hauteur_pixels'] ?? 'N/A'}px', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Mégapixels: ${projectSummary?['megapixels'] ?? 'N/A'} Mpx', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Ratio: ${projectSummary?['ratio'] ?? 'N/A'}:1', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              
              // Totaux
              pw.Text('Totaux:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
              pw.Text('• Poids total: ${projectSummary?['poids_total'] ?? 'N/A'} kg', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Consommation totale: ${projectSummary?['conso_total'] ?? 'N/A'} W', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        
        // Schéma de montage
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.orange300),
            borderRadius: pw.BorderRadius.circular(8),
            color: PdfColors.orange50,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
              pw.Text('SCHÉMA DE MONTAGE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              
              // Schéma ASCII du mur LED
              pw.Text('Vue de face:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
              pw.Text(_generateLedWallSchema(), style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 8),
              
              // Instructions de montage
              pw.Text('Instructions de montage:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('• Commencer par le coin inférieur gauche', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Monter dalle par dalle de gauche à droite', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Vérifier la connectique entre chaque dalle', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Contrôler l\'alignement et la planéité', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  /// Génère le contenu PDF pour les calculs Son (Amplification)
  pw.Widget _buildSoundProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CALCULS AMPLIFICATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Résumé des calculs d'amplification
        if (projectSummary != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue300),
              borderRadius: pw.BorderRadius.circular(8),
              color: PdfColors.blue50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RÉSUMÉ AMPLIFICATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                
                // Détails des enceintes et amplificateurs
                if (projectSummary!['speakers'] != null) ...[
                  pw.Text('Enceintes sélectionnées:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                  ...projectSummary!['speakers'].map<String, pw.Widget>((speaker) => 
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                      child: pw.Text('• ${speaker['name']} x${speaker['quantity']}', style: const pw.TextStyle(fontSize: 10)),
                    )
                  ).toList(),
                  pw.SizedBox(height: 8),
                ],
                
                if (projectSummary!['amplifiers'] != null) ...[
                  pw.Text('Amplificateurs nécessaires:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                  ...projectSummary!['amplifiers'].map<String, pw.Widget>((amp) => 
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                      child: pw.Text('• ${amp['name']} x${amp['quantity']}', style: const pw.TextStyle(fontSize: 10)),
                    )
                  ).toList(),
                  pw.SizedBox(height: 8),
                ],
                
                // Calculs de puissance
                if (projectSummary!['power_calculations'] != null) ...[
                  pw.Text('Calculs de puissance:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                  pw.Text('• Puissance totale requise: ${projectSummary!['power_calculations']['total_required']} W', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('• Puissance totale disponible: ${projectSummary!['power_calculations']['total_available']} W', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('• Utilisation: ${projectSummary!['power_calculations']['utilization']}%', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 8),
                ],
                
                // Avertissements
                if (projectSummary!['warnings'] != null && projectSummary!['warnings'].isNotEmpty) ...[
                  pw.Text('Avertissements:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                pw.SizedBox(height: 4),
                  ...projectSummary!['warnings'].map<String, pw.Widget>((warning) => 
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                      child: pw.Text('⚠ $warning', style: pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                    )
                  ).toList(),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 15),
        ],
        
        // Détails techniques
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('DÉTAILS TECHNIQUES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('• Impédance des enceintes: ${projectSummary?['impedance'] ?? 'Non spécifiée'} Ω', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Mode d\'amplification: ${projectSummary?['amplifier_mode'] ?? 'Non spécifié'}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Marge de sécurité: ${projectSummary?['safety_margin'] ?? '1.5'}x', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('• Canaux en parallèle: ${projectSummary?['parallel_channels'] ?? 'Non spécifié'}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  /// Génère un schéma ASCII du mur LED
  String _generateLedWallSchema() {
    if (projectSummary == null) return 'Schéma non disponible';
    
    final largeur = int.tryParse(projectSummary!['largeur_mur']?.toString() ?? '1') ?? 1;
    final hauteur = int.tryParse(projectSummary!['hauteur_mur']?.toString() ?? '1') ?? 1;
    
    final buffer = StringBuffer();
    
    // En-tête
    buffer.writeln('┌${'─' * (largeur * 4 - 1)}┐');
    
    // Corps du mur
    for (int y = 0; y < hauteur; y++) {
      buffer.write('│');
      for (int x = 0; x < largeur; x++) {
        buffer.write('███');
        if (x < largeur - 1) buffer.write(' ');
      }
      buffer.writeln('│');
    }
    
    // Pied
    buffer.writeln('└${'─' * (largeur * 4 - 1)}┘');
    
    // Légende
    buffer.writeln();
    buffer.writeln('Légende:');
    buffer.writeln('███ = Dalle LED');
    buffer.writeln('Dimensions: ${largeur}x$hauteur dalles');
    
    return buffer.toString();
  }

  /// Génère la section des photos pour l'export
  pw.Widget _buildPhotosSection(List<String> photos) {
    if (photos.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PHOTOS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...photos.map((photoPath) {
          try {
            final file = File(photoPath);
            if (file.existsSync()) {
              final imageBytes = file.readAsBytesSync();
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Image(
                      pw.MemoryImage(imageBytes),
                      width: 200,
                      height: 150,
                ),
              );
            }
          } catch (e) {
            debugPrint('Erreur lors du chargement de la photo $photoPath: $e');
          }
          return pw.SizedBox.shrink();
        }),
      ],
    );
  }

  /// Génère la section des PDFs de calculs importés pour l'export
  pw.Widget _buildImportedPdfsSection(List<Map<String, dynamic>> pdfs) {
    if (pdfs.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CALCULS IMPORTÉS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...pdfs.map((pdfMap) {
          final pdfName = pdfMap['name'] as String;
          final pdfPath = pdfMap['path'] as String;
          final createdAt = pdfMap['createdAt'] as int?;
          
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('📄 $pdfName', 
                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Fichier: ${pdfPath.split('/').last}', 
                       style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                if (createdAt != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text('Créé le: ${DateTime.fromMillisecondsSinceEpoch(createdAt).toString().substring(0, 16)}', 
                         style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildStructureProjectContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CALCUL DE CHARGE STRUCTURE', 
               style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        
        // Résumé du calcul
        pw.Text('RÉSUMÉ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        
        if (projectSummary != null) ...[
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Structure:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['structure']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Distance:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['distance']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Type de charge:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['chargeType']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Charge maximale:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['maxLoad']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Poids structure:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['structureWeight']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Flèche maximale:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['maxDeflection']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Ratio flèche:', style: pw.TextStyle(fontSize: 12)),
              pw.Text(projectSummary!['deflectionRatio']?.toString() ?? '', 
                     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
        
        pw.SizedBox(height: 15),
        pw.Text('Détails du calcul généré le ${DateTime.now().toString().substring(0, 16)}', 
               style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }
}
