# Styles de Boutons AV Wallet

Ce dossier contient les styles de boutons réutilisables pour l'application AV Wallet.

## Fichiers

- `button_styles.dart` - Styles de boutons prédéfinis
- `../widgets/action_button.dart` - Widget personnalisé pour les boutons d'action

## Utilisation

### 1. Styles de boutons prédéfinis

```dart
import '../theme/button_styles.dart';

// Utilisation directe des styles
ElevatedButton(
  onPressed: () {},
  style: ButtonStyles.actionButtonStyle,
  child: Text('Mon bouton'),
)
```

### 2. Widget ActionButton

```dart
import '../widgets/action_button.dart';

// Boutons prédéfinis
ActionButton.photo(onPressed: () {})
ActionButton.calculate(onPressed: () {})
ActionButton.reset(onPressed: () {})

// Bouton personnalisé
ActionButton(
  icon: Icons.settings,
  text: 'Paramètres',
  onPressed: () {},
)

// Rangée de boutons
ActionButtonRow(
  buttons: [
    ActionButton.photo(onPressed: () {}),
    ActionButton.calculate(onPressed: () {}),
    ActionButton.reset(onPressed: () {}),
  ],
)
```

## Styles disponibles

### ButtonStyles

- `actionButtonStyle` - Style principal pour les boutons d'action
- `secondaryActionButtonStyle` - Style secondaire
- `navigationButtonStyle` - Style pour la navigation
- `confirmButtonStyle` - Style pour les confirmations (vert)
- `cancelButtonStyle` - Style pour les annulations (rouge)

### ActionButtonConstants

- `iconSize` - Taille standard des icônes (28px)
- `secondaryIconSize` - Taille des icônes secondaires (20px)
- `buttonSpacing` - Espacement entre boutons (25px)
- `compactButtonSpacing` - Espacement réduit (8px)

### Icônes prédéfinies

- `photoIcon` - Icons.camera_alt
- `calculateIcon` - Icons.calculate
- `resetIcon` - Icons.refresh
- `settingsIcon` - Icons.settings
- `saveIcon` - Icons.save
- `exportIcon` - Icons.download
- `editIcon` - Icons.edit
- `deleteIcon` - Icons.delete
- `addIcon` - Icons.add
- `removeIcon` - Icons.remove

## Exemples d'utilisation

Voir le fichier `../examples/button_usage_examples.dart` pour des exemples complets d'utilisation.

## Avantages

1. **Cohérence** - Tous les boutons ont le même style dans l'application
2. **Réutilisabilité** - Facile à utiliser dans toute l'application
3. **Maintenabilité** - Un seul endroit pour modifier les styles
4. **Flexibilité** - Possibilité de personnaliser chaque bouton individuellement
5. **Lisibilité** - Code plus propre et plus lisible




