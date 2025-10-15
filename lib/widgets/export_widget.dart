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
import '../models/cart_item.dart';
import '../models/catalogue_item.dart';
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Couleur adaptée au thème : Grey 900 opacité 0.5 en mode nuit, bleu nuit opacité 0.5 en mode jour
    final buttonColor = isDarkMode 
        ? Colors.grey[900]!.withOpacity(0.5)
        : Colors.blue[900]!.withOpacity(0.5);
    
    return PopupMenuButton<String>(
      child: ActionButton(
        icon: customIcon ?? Icons.cloud_upload,
        iconSize: 28,
        color: Colors.white, // Toujours blanc pour la cohérence
        style: ButtonStyles.actionButtonStyle,
        enabled: true,
      ),
      tooltip: tooltip ?? 'Exporter',
      color: buttonColor, // Même couleur que ActionButton
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
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, String exportType) async {
    try {
      // Générer le PDF
      final pdfFile = await _generatePdf();
      
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

  Future<File> _generatePdf() async {
    // Créer le document PDF
    final pdf = pw.Document();
    
    // Récupérer les photos du projet
    final photos = await _getProjectPhotos();
    
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
    
    // Sauvegarder le PDF
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = this.fileName ?? 'export_$timestamp';
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  pw.Widget _buildInputTable() {
    // Extraire les données INPUT du contenu
    final inputLines = content.split('\n')
        .where((line) => line.contains('|') && line.contains('INPUT'))
        .map((line) => line.split('|').map((e) => e.trim()).toList())
        .toList();
    
    if (inputLines.isEmpty) {
      return pw.Text('Aucune donnée INPUT disponible');
    }
    
    // Créer le tableau
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),   // N°
        1: const pw.FixedColumnWidth(80),   // Nom Piste
        2: const pw.FixedColumnWidth(120),  // Source
        3: const pw.FixedColumnWidth(100),  // Microphone
        4: const pw.FixedColumnWidth(80),   // Type
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
              child: pw.Text('Source', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Microphone', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
        ...inputLines.map((row) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[0].replaceAll('.', ''), style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[1], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[2], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[3], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[4], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[5], style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildOutputTable() {
    // Extraire les données OUTPUT du contenu
    final outputLines = content.split('\n')
        .where((line) => line.contains('|') && line.contains('OUTPUT'))
        .map((line) => line.split('|').map((e) => e.trim()).toList())
        .toList();
    
    if (outputLines.isEmpty) {
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
        ...outputLines.map((row) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[0].replaceAll('.', ''), style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[1], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[2], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[3], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[4], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[5], style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildSummaryTable() {
    // Extraire les données de résumé du contenu
    final summaryLines = content.split('\n')
        .where((line) => line.contains(':') && line.contains('RÉSUMÉ'))
        .map((line) => line.split(':').map((e) => e.trim()).toList())
        .toList();
    
    if (summaryLines.isEmpty) {
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
        ...summaryLines.map((row) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[1], style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        )),
      ],
    );
  }

  Future<void> _exportViaSms(BuildContext context, String message, File pdfFile) async {
    try {
      // Pour SMS, utiliser le même système que WhatsApp et Email avec fichier PDF
      await Share.shareXFiles([XFile(pdfFile.path)], text: message);
      if (context.mounted) {
        // Export SMS réussi - pas de SnackBar
      }
    } catch (e) {
      if (context.mounted) {
        // Erreur SMS silencieuse - pas de SnackBar
      }
    }
  }

  Future<void> _exportViaWhatsApp(BuildContext context, String message, File pdfFile) async {
    try {
      // Pour WhatsApp, on peut partager le fichier PDF
      await Share.shareXFiles([XFile(pdfFile.path)], text: message);
      if (context.mounted) {
        // Export WhatsApp réussi - pas de SnackBar
      }
    } catch (e) {
      // Fallback vers WhatsApp Web si l'app n'est pas disponible
      try {
        final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        
        if (launched) {
          if (context.mounted) {
            // WhatsApp Web ouvert - pas de SnackBar
          }
        } else {
          throw Exception('Impossible d\'ouvrir WhatsApp Web');
        }
      } catch (e2) {
        if (context.mounted) {
          // Erreur WhatsApp silencieuse - pas de SnackBar
        }
      }
    }
  }

  Future<void> _exportViaEmail(BuildContext context, WidgetRef ref, String message, File pdfFile) async {
    try {
      // Pour Email, on peut partager le fichier PDF
      await Share.shareXFiles([XFile(pdfFile.path)], text: message);
      if (context.mounted) {
        // Export Email réussi - pas de SnackBar
      }
    } catch (e) {
      // Fallback vers l'app email si disponible
      try {
        final canOpenEmail = await canLaunchUrl(Uri.parse('mailto:'));
        
        if (!canOpenEmail) {
          if (context.mounted) {
            // App email non disponible - pas de SnackBar
          }
          return;
        }

        final subject = presetName != null 
            ? '$title - $presetName'
            : title;
        
        final emailUrl = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(message)}');
        final launched = await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
        
        if (launched) {
          if (context.mounted) {
            // App email ouverte - pas de SnackBar
          }
        } else {
          throw Exception('Impossible d\'ouvrir l\'app email');
        }
      } catch (e2) {
        if (context.mounted) {
          // Erreur email silencieuse - pas de SnackBar
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
      
      // Si pas de projet sélectionné, créer un projet par défaut
      if (project == null) {
        final defaultProject = Project(
          id: 'default_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Projet par défaut',
        );
        ref.read(projectProvider.notifier).addProject(defaultProject);
        // Sélectionner le dernier projet ajouté (qui sera à la fin de la liste)
        final projects = ref.read(projectProvider).projects;
        ref.read(projectProvider.notifier).selectProject(projects.length - 1);
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
        name: _getCalculationDisplayName(calculationType, title),
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

  String _getCalculationDisplayName(String? calculationType, String originalTitle) {
    // Créer un nom court et descriptif basé sur le type de calcul
    switch (calculationType) {
      case 'dmx':
        return 'Calcul DMX';
      case 'faisceau':
        return 'Calcul Faisceau';
      case 'proj':
        return 'Calcul Projection';
      case 'video':
        return 'Calcul Vidéo';
      case 'son':
        return 'Calcul Son';
      case 'structure':
        return 'Calcul Structure';
      case 'puissance':
        return 'Calcul Puissance';
      case 'poids':
        return 'Calcul Poids';
      case 'general':
        return 'Calcul Général';
      default:
        return 'Calcul ${calculationType ?? 'Export'}';
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: backgroundColor == Colors.green ? 2 : 3),
      ),
    );
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
                pw.Text('${data.values.first}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
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
                pw.Text('${data.values.first}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
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
                pw.Text('${data.values.first}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
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
          
          // Configuration du mur
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CONFIGURATION DU MUR', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dimensions (dalles):', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['dimensions'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dimensions totales:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['dimensions_totales'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre total de dalles:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['nb_dalles'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Résolution totale:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['resolution_totale'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Mégapixels:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['megapixels'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ratio d\'aspect:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['ratio'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids total:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['poids_total'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Consommation totale:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['consommation_total'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
        ],
        
        // Détail des composants
        if (projectData != null && projectData!.isNotEmpty) ...[
          pw.Text('DÉTAIL DES COMPOSANTS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...projectData!.map((component) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${component['type'] ?? 'Composant'} - ${component['produit'] ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Marque:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['marque'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Quantité:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['quantite'] ?? '0'} dalles', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dimensions dalle:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['dimensions_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Résolution dalle:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['resolution_dalle'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids unitaire:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['poids_unitaire'] ?? '0.0 kg'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Consommation unitaire:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['consommation_unitaire'] ?? '0 W'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids total:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['poids_total'] ?? '0.0 kg'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Consommation totale:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text('${component['consommation_total'] ?? '0 W'}', 
                           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )),
        ],
        
        // Schéma du mur avec quadrillage amélioré
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text('SCHÉMA DU MUR LED', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15),
              if (projectSummary != null) ...[
                _buildEnhancedWallDrawing(),
                pw.SizedBox(height: 15),
                pw.Text('Dimensions: ${projectSummary!['dimensions'] ?? 'N/A'} dalles', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Dimensions totales: ${projectSummary!['dimensions_totales'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Résolution: ${projectSummary!['resolution_totale'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Ratio d\'aspect: ${projectSummary!['ratio'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Total: ${projectSummary!['nb_dalles'] ?? '0'} dalles', style: pw.TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildWallDrawing() {
    if (projectSummary == null) return pw.SizedBox.shrink();
    
    // Extraire les dimensions du mur
    final dimensions = projectSummary!['dimensions']?.toString() ?? '1 x 1';
    final parts = dimensions.split(' x ');
    if (parts.length != 2) return pw.SizedBox.shrink();
    
    final width = int.tryParse(parts[0].trim()) ?? 1;
    final height = int.tryParse(parts[1].trim()) ?? 1;
    
    // Calculer la taille des carrés en respectant les proportions
    final maxSize = 200.0; // Taille maximale du dessin
    final tileSize = (maxSize / (width > height ? width : height)).clamp(8.0, 20.0);
    
    return pw.Container(
      width: width * tileSize,
      height: height * tileSize,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        children: List.generate(height, (rowIndex) {
          return pw.TableRow(
            children: List.generate(width, (colIndex) {
              final index = rowIndex * width + colIndex;
              return pw.Container(
                width: tileSize,
                height: tileSize,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '${index + 1}',
                    style: pw.TextStyle(
                      fontSize: (tileSize * 0.3).clamp(6.0, 10.0),
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  pw.Widget _buildEnhancedWallDrawing() {
    if (projectSummary == null) return pw.SizedBox.shrink();
    
    // Extraire les dimensions du mur
    final width = projectSummary!['largeur_dalles'] ?? 1;
    final height = projectSummary!['hauteur_dalles'] ?? 1;
    final resX = projectSummary!['resX'] ?? 200;
    final resY = projectSummary!['resY'] ?? 200;
    
    // Calculer la taille des carrés en respectant les proportions
    final maxSize = 300.0; // Taille maximale du dessin
    final tileSize = (maxSize / (width > height ? width : height)).clamp(12.0, 25.0);
    
    return pw.Container(
      width: width * tileSize,
      height: height * tileSize,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        children: List.generate(height, (rowIndex) {
          return pw.TableRow(
            children: List.generate(width, (colIndex) {
              final index = colIndex * height + rowIndex;
              return pw.Container(
                width: tileSize,
                height: tileSize,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                ),
                child: pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '${index + 1}',
                        style: pw.TextStyle(
                          fontSize: (tileSize * 0.25).clamp(6.0, 10.0),
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${resX}x${resY}',
                        style: pw.TextStyle(
                          fontSize: (tileSize * 0.15).clamp(4.0, 8.0),
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  pw.Widget _buildPhotosSection(List<String> photos) {
    if (photos.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
            debugPrint('Erreur lors du chargement de la photo $photoPath: $e');
          }
          return pw.SizedBox.shrink();
        }).toList(),
      ],
    );
  }
}
