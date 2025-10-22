import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Script pour générer l'icône de l'application avec logo réduit de 20% et fond bleu nuit
Future<void> generateAppIcon() async {
  print('Génération de l\'icône de l\'application...');
  
  // Charger l'image du logo
  final ByteData logoData = await rootBundle.load('assets/logo2.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();
  final ui.Codec logoCodec = await ui.instantiateImageCodec(logoBytes);
  final ui.FrameInfo logoFrame = await logoCodec.getNextFrame();
  final ui.Image logoImage = logoFrame.image;
  
  // Taille de l'icône finale (Android recommande 512x512)
  const int iconSize = 512;
  
  // Créer un canvas pour dessiner l'icône
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  
  // Dessiner le fond bleu nuit avec opacité 0.3
  final Paint backgroundPaint = Paint()
    ..color = const Color(0xFF0F172A).withOpacity(0.3);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, iconSize.toDouble(), iconSize.toDouble()),
    backgroundPaint,
  );
  
  // Calculer la taille du logo (réduit de 20%)
  final double logoSize = iconSize * 0.8; // 80% de la taille originale = réduction de 20%
  final double logoOffset = (iconSize - logoSize) / 2; // Centrer le logo
  
  // Dessiner le logo au centre
  canvas.drawImageRect(
    logoImage,
    Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
    Rect.fromLTWH(logoOffset, logoOffset, logoSize, logoSize),
    Paint(),
  );
  
  // Convertir en image
  final ui.Picture picture = recorder.endRecording();
  final ui.Image finalImage = await picture.toImage(iconSize, iconSize);
  
  // Sauvegarder l'image
  final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    final File iconFile = File('assets/generated_app_icon.png');
    await iconFile.writeAsBytes(byteData.buffer.asUint8List());
    print('Icône générée avec succès: ${iconFile.path}');
  }
  
  // Nettoyer
  logoImage.dispose();
  finalImage.dispose();
  picture.dispose();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await generateAppIcon();
}
