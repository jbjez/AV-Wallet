# Migration du Catalogue Complet vers Hive

## Vue d'ensemble

Ce service gère la migration de toutes les données du catalogue (Lumière, Vidéo, Son, Divers) vers la base de données Hive locale.

## Fichiers impliqués

- `catalogue_migration_service.dart` - Service principal de migration
- `test_catalogue_migration_script.dart` - Script de test exécutable
- `catalogue_data.dart` - Source des données du catalogue

## Fonctionnalités

### CatalogueMigrationService

- **`migrateCatalogueData()`** - Migre tout le catalogue vers Hive
- **`migrateNewCategories()`** - Migre seulement les nouvelles catégories
- **`needsMigration()`** - Vérifie si une migration complète est nécessaire
- **`needsNewCategoriesMigration()`** - Vérifie si de nouvelles catégories doivent être migrées
- **`getTotalItemCount()`** - Retourne le nombre total d'items dans Hive
- **`getExistingCategories()`** - Retourne les catégories présentes dans Hive

### Données migrées

Le service migre toutes les catégories du catalogue :

#### Lumière (70+ modèles)
- **Elation** : Artiste, Proteus, Smarty, Rayzor
- **Robe** : MegaPointe, Pointe, ESPRITE, FORTE
- **Martin** : MAC Encore, Ayrton Diablo
- **Ayrton** : Huracán-X, Diablo
- **Astera** : Titan Tube
- **SGM** : P-6

#### Vidéo (26 modèles)
- **Écrans** : LG UL3J (7), Samsung QB (7)
- **Vidéoprojecteurs** : Panasonic, Barco, Christie, Epson, LG

#### Son (25+ modèles)
- **L-Acoustics** : KARA, KIVA, X12, X15, KS28, LA4X, LA8
- **Martin** : LEO-M, LEO-L, ULTRA-X40, ULTRA-X42
- **DB Technologies** : V8, V12, M4, M6, B22, B18, D80, D20

#### Divers (8+ modèles)
- **Traiteur** : Machine à café, Plaque chauffante, Mixeur, Thermos
- **Backstage** : Sèche-cheveux, Lampe miroir, Bouilloire, Steamer

## Intégration

La migration est automatiquement exécutée au démarrage de l'application via le `CatalogueProvider` :

```dart
// Dans catalogue_provider.dart
await CatalogueMigrationService.migrateNewCategories();
```

## Test de la migration

### Script de test
```bash
dart run lib/scripts/test_catalogue_migration_script.dart
```

### Test manuel
```dart
import '../services/catalogue_migration_service.dart';

// Migration des nouvelles catégories
await CatalogueMigrationService.migrateNewCategories();

// Vérification des catégories existantes
final categories = await CatalogueMigrationService.getExistingCategories();
```

## Structure des données

Chaque item contient :
- `id` - Identifiant unique
- `name` - Nom de l'item
- `description` - Description complète
- `categorie` - Catégorie principale (Lumière, Vidéo, Son, Divers)
- `sousCategorie` - Sous-catégorie (Spot, Wash, Écran, etc.)
- `marque` - Marque du produit
- `produit` - Modèle du produit
- `dimensions` - Dimensions physiques
- `poids` - Poids
- `conso` - Consommation électrique
- Propriétés spécifiques selon la catégorie (angle, lux, dmx, etc.)

## Logs

Le service utilise le logger `CatalogueMigrationService` pour tracer :
- Début et fin de migration
- Nombre d'items migrés par catégorie
- Erreurs éventuelles

## Gestion d'erreurs

- Vérification intelligente des catégories existantes
- Migration incrémentale des nouvelles catégories
- Gestion des erreurs de base de données
- Logs détaillés pour le debugging

## Avantages

- **Migration incrémentale** : Seules les nouvelles catégories sont migrées
- **Performance optimisée** : Évite la duplication des données
- **Maintenance simplifiée** : Un seul service pour toutes les catégories
- **Flexibilité** : Facile d'ajouter de nouvelles catégories





