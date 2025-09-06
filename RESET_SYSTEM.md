# Système de Reset - AV Wallet

Ce document explique comment utiliser le système de reset intégré dans l'application AV Wallet.

## 🎯 Objectif

Le système de reset permet de simuler une première visite de l'application en supprimant toutes les données locales stockées. C'est particulièrement utile pour :
- Tester le comportement de première installation
- Déboguer des problèmes de données corrompues
- Permettre aux utilisateurs de repartir à zéro

## 🔧 Fonctionnalités

### 1. Reset Complet de l'Application
- **Supprime** : Toutes les données Hive, SharedPreferences, sessions d'authentification
- **Conserve** : Rien (simule une première installation)
- **Accès** : Paramètres → "Réinitialiser l'application"

### 2. Reset des Données Utilisateur
- **Supprime** : Projets, panier, données utilisateur spécifiques
- **Conserve** : Préférences d'application (thème, langue, etc.)
- **Accès** : Paramètres → "Réinitialiser les données utilisateur"

## 📱 Utilisation dans l'Interface

### Via l'Application
1. Ouvrir l'application AV Wallet
2. Aller dans **Paramètres** (icône utilisateur → Paramètres)
3. Choisir l'option de reset souhaitée :
   - **Réinitialiser les données utilisateur** (orange) : Supprime uniquement les données utilisateur
   - **Réinitialiser l'application** (rouge) : Reset complet
4. Confirmer l'action dans le dialogue

### Via les Scripts de Développement

#### Script Shell (Recommandé)
```bash
./reset_dev.sh
```
Ce script :
- Nettoie tous les caches Flutter
- Supprime les données de l'émulateur/simulateur
- Réinstalle les dépendances
- Prépare l'application pour un test de première visite

#### Script Dart
```bash
dart run lib/scripts/reset_app.dart
```
Ce script :
- Effectue un reset complet via le code
- Demande confirmation avant exécution
- Affiche des messages détaillés

## 🗄️ Données Supprimées

### Reset Complet
- **Hive Database** :
  - `catalogue` - Articles du catalogue
  - `presets` - Presets utilisateur
  - `projects` - Projets utilisateur
  - `cart` - Panier d'achat
  - `page_states` - États des pages
  - `lenses` - Données d'objectifs
  - `user_data` - Données utilisateur
  - `app_settings` - Paramètres d'application

- **SharedPreferences** :
  - `remember_me` - Se souvenir de moi
  - `user_id` - ID utilisateur
  - `user_email` - Email utilisateur
  - `theme_mode` - Mode thème
  - `languageCode` - Langue
  - `click_count` - Compteur de clics
  - `first_launch` - Première visite
  - `onboarding_completed` - Onboarding terminé
  - `app_version` - Version de l'app
  - `last_sync` - Dernière synchronisation
  - `user_preferences` - Préférences utilisateur
  - `app_settings` - Paramètres d'app

### Reset Données Utilisateur
- **Hive Database** :
  - `projects` - Projets utilisateur
  - `cart` - Panier d'achat
  - `user_data` - Données utilisateur

- **SharedPreferences** :
  - `remember_me` - Se souvenir de moi
  - `user_id` - ID utilisateur
  - `user_email` - Email utilisateur

## 🔍 Détection de Première Visite

L'application peut détecter si c'est une première visite :

```dart
// Vérifier si c'est la première visite
bool isFirstVisit = await ResetService.isFirstVisit();

// Marquer la première visite comme terminée
await ResetService.markFirstVisitCompleted();
```

## 🛠️ Développement

### Ajout de Nouvelles Données à Reset

1. **Pour Hive** : Ajouter le nom de la box dans `ResetService._clearAllHiveData()`
2. **Pour SharedPreferences** : Ajouter la clé dans `ResetService._clearAllSharedPreferences()`

### Personnalisation

Le système est modulaire et peut être étendu :
- `ResetService.performCompleteReset()` : Reset complet
- `ResetService.performUserDataReset()` : Reset données utilisateur
- `ResetService.isFirstVisit()` : Détection première visite
- `ResetService.markFirstVisitCompleted()` : Marquer visite terminée

## ⚠️ Avertissements

- **Irréversible** : Les données supprimées ne peuvent pas être récupérées
- **Déconnexion** : L'utilisateur sera déconnecté après un reset complet
- **Perte de données** : Tous les projets et préférences seront perdus
- **Test uniquement** : Utiliser uniquement en développement ou si nécessaire

## 🐛 Dépannage

### Erreurs Communes

1. **"Erreur lors du reset"** :
   - Vérifier que l'application n'est pas en cours d'utilisation
   - Relancer l'application après le reset

2. **"Supabase not available"** :
   - Normal si Supabase n'est pas configuré
   - Le reset continue sans problème

3. **"Could not delete box"** :
   - Normal si la box n'existe pas
   - Le reset continue avec les autres données

### Logs

Les logs détaillés sont disponibles dans la console :
- `ResetService` : Logs du service de reset
- `AuthService` : Logs d'authentification
- `HiveService` : Logs de la base de données

## 📝 Notes

- Le système est conçu pour être robuste et continuer même si certaines opérations échouent
- Les méthodes de fallback sont incluses pour assurer la compatibilité
- Le reset est asynchrone et peut prendre quelques secondes
- L'interface utilisateur affiche des indicateurs de progression
