#!/bin/bash

echo "🔄 Reset simple AV Wallet"
echo "========================"

# Nettoyer les caches Flutter
echo "🧹 Nettoyage des caches..."
flutter clean

# Nettoyer les données de l'émulateur Android
echo "📱 Nettoyage Android..."
adb shell pm clear com.example.av_wallet_hive 2>/dev/null || echo "Android non disponible"

# Nettoyer les données iOS
echo "🍎 Nettoyage iOS..."
xcrun simctl uninstall booted com.example.av_wallet_hive 2>/dev/null || echo "iOS non disponible"

# Nettoyer les fichiers de données Hive
echo "🗄️ Nettoyage Hive..."
find . -name "*.hive" -delete 2>/dev/null || true
find . -name "*.lock" -delete 2>/dev/null || true

echo ""
echo "✅ Reset terminé !"
echo "📱 Relancez l'application avec: flutter run"
echo "   L'application devrait maintenant afficher la page de connexion"
