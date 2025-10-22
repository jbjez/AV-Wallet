import 'package:flutter/material.dart';

/// Styles de boutons réutilisables pour l'application AV Wallet
class ButtonStyles {
  /// Style pour les boutons d'action principaux (Photo, Calcul, Reset)
  static ButtonStyle get actionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey[900],
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(12),
    elevation: 0,
  );

  /// Style pour les boutons d'action secondaires
  static ButtonStyle get secondaryActionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    elevation: 0,
  );

  /// Style pour les boutons de navigation
  static ButtonStyle get navigationButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey[800],
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
  );

  /// Style pour les boutons de confirmation
  static ButtonStyle get confirmButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700],
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    elevation: 2,
  );

  /// Style pour les boutons d'annulation
  static ButtonStyle get cancelButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.red[700],
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    elevation: 2,
  );
}

/// Constantes pour les icônes et tailles des boutons d'action
class ActionButtonConstants {
  /// Taille standard des icônes pour les boutons d'action
  static const double iconSize = 28.0;
  
  /// Taille des icônes pour les boutons secondaires
  static const double secondaryIconSize = 20.0;
  
  /// Espacement standard entre les boutons d'action
  static const double buttonSpacing = 25.0;
  
  /// Espacement réduit entre les boutons
  static const double compactButtonSpacing = 8.0;
  
  /// Icônes standard pour les actions
  static const IconData photoIcon = Icons.camera_alt;
  static const IconData calculateIcon = Icons.calculate;
  static const IconData resetIcon = Icons.refresh;
  static const IconData settingsIcon = Icons.settings;
  static const IconData saveIcon = Icons.save;
  static const IconData exportIcon = Icons.download;
  static const IconData editIcon = Icons.edit;
  static const IconData deleteIcon = Icons.delete;
  static const IconData addIcon = Icons.add;
  static const IconData removeIcon = Icons.remove;
  static const IconData commentIcon = Icons.chat_bubble_outline;
}

