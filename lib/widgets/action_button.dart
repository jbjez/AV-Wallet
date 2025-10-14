import 'package:flutter/material.dart';
import '../theme/button_styles.dart';

/// Widget personnalisé pour les boutons d'action avec icônes
class ActionButton extends StatelessWidget {
  /// Icône du bouton
  final IconData icon;
  
  /// Texte du bouton (optionnel)
  final String? text;
  
  /// Fonction appelée lors du clic
  final VoidCallback? onPressed;
  
  /// Style du bouton (par défaut: actionButtonStyle)
  final ButtonStyle? style;
  
  /// Taille de l'icône (par défaut: 28px)
  final double iconSize;
  
  /// Taille du texte
  final double? textSize;
  
  /// Couleur de l'icône et du texte
  final Color? color;
  
  /// Espacement entre l'icône et le texte
  final double spacing;
  
  /// Indique si le bouton est désactivé
  final bool enabled;

  const ActionButton({
    super.key,
    required this.icon,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  });

  /// Constructeur pour le bouton Photo
  const ActionButton.photo({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.photoIcon;

  /// Constructeur pour le bouton Calcul
  const ActionButton.calculate({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.calculateIcon;

  /// Constructeur pour le bouton Reset
  const ActionButton.reset({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.resetIcon;

  /// Constructeur pour le bouton Settings
  const ActionButton.settings({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.settingsIcon;

  /// Constructeur pour le bouton Save
  const ActionButton.save({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.saveIcon;

  /// Constructeur pour le bouton Export
  const ActionButton.export({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.exportIcon;

  /// Constructeur pour le bouton Commentaire
  const ActionButton.comment({
    super.key,
    this.text,
    this.onPressed,
    this.style,
    this.iconSize = ActionButtonConstants.iconSize,
    this.textSize,
    this.color,
    this.spacing = 4.0,
    this.enabled = true,
  }) : icon = ActionButtonConstants.commentIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? ButtonStyles.actionButtonStyle;
    final effectiveColor = color ?? Colors.white;
    final effectiveTextSize = textSize ?? 12.0;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: effectiveStyle,
      child: text != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: effectiveColor,
                ),
                SizedBox(width: spacing),
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: effectiveTextSize,
                    color: effectiveColor,
                  ),
                ),
              ],
            )
          : Icon(
              icon,
              size: iconSize,
              color: effectiveColor,
            ),
    );
  }
}

/// Widget pour une rangée de boutons d'action avec espacement automatique
class ActionButtonRow extends StatelessWidget {
  /// Liste des boutons à afficher
  final List<ActionButton> buttons;
  
  /// Espacement entre les boutons
  final double spacing;
  
  /// Alignement des boutons
  final MainAxisAlignment alignment;

  const ActionButtonRow({
    super.key,
    required this.buttons,
    this.spacing = ActionButtonConstants.buttonSpacing,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons
          .expand((button) => [
                button,
                if (button != buttons.last) SizedBox(width: spacing),
              ])
          .toList(),
    );
  }
}

