#!/bin/bash

# Script de développement pour reset rapide de l'application AV Wallet
# Usage: ./reset_dev.sh

echo "🔄 AV Wallet - Reset de Développement"
echo "====================================="
echo ""

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier si nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

echo "⚠️  ATTENTION: Ce script va effectuer un reset complet de l'application"
echo "   Cela supprimera toutes les données locales (Hive + SharedPreferences)"
echo ""

read -p "Êtes-vous sûr de vouloir continuer ? (oui/non): " -r
if [[ ! $REPLY =~ ^[Oo](ui)?$ ]]; then
    echo "❌ Opération annulée."
    exit 0
fi

echo ""
echo "🔄 Nettoyage des données de développement..."

# Arrêter l'application si elle tourne
echo "📱 Arrêt de l'application..."
flutter clean

# Nettoyer les données de l'émulateur/simulateur
echo "🧹 Nettoyage des données de l'émulateur..."

# Android
if command -v adb &> /dev/null; then
    echo "   - Nettoyage Android..."
    adb shell pm clear com.example.av_wallet_hive 2>/dev/null || true
fi

# iOS (nécessite un simulateur iOS)
if command -v xcrun &> /dev/null; then
    echo "   - Nettoyage iOS..."
    xcrun simctl uninstall booted com.example.av_wallet_hive 2>/dev/null || true
fi

# Nettoyer les caches Flutter
echo "🧹 Nettoyage des caches Flutter..."
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf ios/Pods/
rm -rf android/.gradle/

# Réinstaller les dépendances
echo "📦 Réinstallation des dépendances..."
flutter pub get

# Nettoyer les données Hive locales (si l'app a été compilée)
echo "🗄️  Nettoyage des données Hive..."
find . -name "*.hive" -delete 2>/dev/null || true
find . -name "*.lock" -delete 2>/dev/null || true

echo ""
echo "✅ Reset de développement terminé !"
echo ""
echo "📱 Prochaines étapes:"
echo "   1. Relancez l'application: flutter run"
echo "   2. L'application se comportera comme une première installation"
echo "   3. Toutes les données locales ont été supprimées"
echo ""
echo "🚀 Vous pouvez maintenant tester le comportement de première visite !"
