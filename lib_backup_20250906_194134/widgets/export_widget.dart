import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../providers/preset_provider.dart';
import '../models/cart_item.dart';
import '../models/catalogue_item.dart';

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDarkMode ? Colors.grey[900] : Colors.white; // Blanc en mode jour
    
    return PopupMenuButton<String>(
      icon: Icon(
        customIcon ?? Icons.upload,
        color: isDarkMode ? Colors.white : Colors.white, // Blanc dans tous les cas
        size: 24,
      ),
      tooltip: tooltip ?? 'Exporter',
      color: buttonColor,
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
        _showSnackBar(context, 'Erreur lors de la génération du PDF: $e', Colors.red);
      }
    }
  }

  String _buildSimpleMessage() {
    final date = exportDate ?? DateTime.now();
    return '$title\n📅 ${date.toString().split('.')[0]}\n\nBy AVWallet®';
  }

  Future<File> _generatePdf() async {
    // Créer le document PDF
    final pdf = pw.Document();
    
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
        _showSnackBar(context, 'Fichier PDF partagé via SMS', Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Erreur lors de l\'export SMS: $e', Colors.red);
      }
    }
  }

  Future<void> _exportViaWhatsApp(BuildContext context, String message, File pdfFile) async {
    try {
      // Pour WhatsApp, on peut partager le fichier PDF
      await Share.shareXFiles([XFile(pdfFile.path)], text: message);
      if (context.mounted) {
        _showSnackBar(context, 'Fichier PDF partagé via WhatsApp', Colors.green);
      }
    } catch (e) {
      // Fallback vers WhatsApp Web si l'app n'est pas disponible
      try {
        final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        
        if (launched) {
          if (context.mounted) {
            _showSnackBar(context, 'WhatsApp Web ouvert avec le message pré-rempli', Colors.green);
          }
        } else {
          throw Exception('Impossible d\'ouvrir WhatsApp Web');
        }
      } catch (e2) {
        if (context.mounted) {
          _showSnackBar(context, 'Erreur lors de l\'export WhatsApp: $e2', Colors.red);
        }
      }
    }
  }

  Future<void> _exportViaEmail(BuildContext context, WidgetRef ref, String message, File pdfFile) async {
    try {
      // Pour Email, on peut partager le fichier PDF
      await Share.shareXFiles([XFile(pdfFile.path)], text: message);
      if (context.mounted) {
        _showSnackBar(context, 'Fichier PDF partagé via Email', Colors.green);
      }
    } catch (e) {
      // Fallback vers l'app email si disponible
      try {
        final canOpenEmail = await canLaunchUrl(Uri.parse('mailto:'));
        
        if (!canOpenEmail) {
          if (context.mounted) {
            _showSnackBar(context, 'App email non disponible sur cet appareil', Colors.orange);
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
            _showSnackBar(context, 'App email ouverte avec le message pré-rempli', Colors.green);
          }
        } else {
          throw Exception('Impossible d\'ouvrir l\'app email');
        }
      } catch (e2) {
        if (context.mounted) {
          _showSnackBar(context, 'Erreur lors de l\'export email: $e2', Colors.red);
        }
      }
    }
  }

  void _exportToProject(BuildContext context, WidgetRef ref, String exportMessage, File pdfFile) {
    try {
      // Récupérer le preset actif
      final activePreset = ref.read(activePresetProvider);
      if (activePreset == null) {
        _showSnackBar(context, 'Aucun preset actif pour l\'export', Colors.orange);
        return;
      }

      // Ajouter le contenu exporté au preset actif
      final updatedPreset = activePreset.copyWith(
        items: [
          ...activePreset.items,
          // Créer un nouvel élément pour l'export
          CartItem(
            item: CatalogueItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: 'Export: $title',
              description: exportMessage,
              categorie: 'Export',
              sousCategorie: 'Système',
              marque: 'Système',
              produit: 'Export: $title',
              dimensions: '0x0x0',
              poids: '0',
              conso: '0',
              imageUrl: '',
            ),
            quantity: 1,
          ),
        ],
      );

      // Mettre à jour le preset
      ref.read(presetProvider.notifier).updatePreset(updatedPreset);
      
      _showSnackBar(
        context, 
        'Export ajouté au preset "${activePreset.name}" avec fichier PDF', 
        Colors.green
      );
    } catch (e) {
      _showSnackBar(
        context, 
        'Erreur lors de l\'export vers le projet: $e', 
        Colors.red
      );
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
        
        // Résumé du mur LED
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
                pw.Text('CONFIGURATION DU MUR', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Mur LED:', style: pw.TextStyle(fontSize: 12)),
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
                    pw.Text('Dimensions:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['dimensions'] ?? 'N/A'} dalles', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nombre de dalles:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['nb_dalles'] ?? '0'}', 
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
                    pw.Text('Ratio:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['ratio'] ?? 'N/A'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Poids total:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['poids_total'] ?? '0.0 kg'}', 
                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Consommation:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('${projectSummary!['consommation_total'] ?? '0 W'}', 
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
        
        // Plan schématique du mur avec dessin
        pw.SizedBox(height: 20),
        pw.Text('PLAN SCHÉMATIQUE DU MUR', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text('Représentation visuelle du mur LED', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15),
              if (projectSummary != null) ...[
                _buildWallDrawing(),
                pw.SizedBox(height: 15),
                pw.Text('Dimensions: ${projectSummary!['dimensions'] ?? 'N/A'} dalles', style: pw.TextStyle(fontSize: 12)),
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
}
