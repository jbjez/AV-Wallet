# Migration des Données Vidéo vers Hive

## Vue d'ensemble

Ce service gère la migration des données d'écrans et vidéoprojecteurs vers la base de données Hive locale.

## Fichiers impliqués

- `screen_migration_service.dart` - Service principal de migration
- `test_screen_migration.dart` - Tests et utilitaires de vérification
- `test_screen_migration_script.dart` - Script de test exécutable

## Fonctionnalités

### ScreenMigrationService

- **`migrateScreenData()`** - Migre tous les items vidéo vers Hive
- **`needsMigration()`** - Vérifie si une migration est nécessaire
- **`getVideoItemCount()`** - Retourne le nombre d'items vidéo dans Hive

### Données migrées

Le service migre 26 items vidéo :

#### Écrans (14 modèles)
**LG - Série UL3J (7 modèles)**
- 32", 43", 55", 65", 75", 86", 98"

**Samsung - Série QB (7 modèles)**
- 32" (Full HD), 43", 55", 65", 75", 85", 98" (4K UHD)

#### Vidéoprojecteurs (12 modèles)
**Panasonic (2 modèles)**
- PT-DZ10K (10 600 lm), PT-RZ12K (12 000 lm)

**Barco (3 modèles)**
- UDX-4K40 FLEX (37 500 lm), F80-Q12 (12 000 lm), G62-W14 (11 500 lm)

**Christie (4 modèles)**
- Crimson WU31 (31 500 lm), M 4K25 RGB (25 000 lm), M 4K25 RGB (2) (25 300 lm), Roadie 4K45 (43 000 lm)

**Epson (1 modèle)**
- EB-L20000U (20 000 lm)

**LG (2 modèles)**
- ProBeam BU60PST (6 000 lm), BF60PST (6 000 lm)

## Intégration

La migration est automatiquement exécutée au démarrage de l'application via le `CatalogueProvider` :

```dart
// Dans catalogue_provider.dart
await ScreenMigrationService.migrateScreenData();
```

## Test de la migration

### Script de test
```bash
dart run lib/scripts/test_screen_migration_script.dart
```

### Test manuel
```dart
import '../services/test_screen_migration.dart';

// Test de migration
await TestScreenMigration.testMigration();

// Nettoyage pour retest
await TestScreenMigration.cleanupScreens();
```

## Structure des données

Chaque écran contient :
- `id` - Identifiant unique
- `name` - Nom de l'écran
- `description` - Description complète
- `categorie` - "Vidéo"
- `sousCategorie` - "Écran"
- `marque` - Marque (LG, Samsung)
- `produit` - Modèle du produit
- `taille` - Taille en pouces
- `dimensions` - Dimensions physiques
- `poids` - Poids
- `conso` - Consommation électrique
- `resolution` - Résolution (1920x1080, 3840x2160)

## Logs

Le service utilise le logger `ScreenMigrationService` pour tracer :
- Début et fin de migration
- Nombre d'items migrés
- Erreurs éventuelles

## Gestion d'erreurs

- Vérification de l'existence des données avant migration
- Gestion des erreurs de base de données
- Logs détaillés pour le debugging
