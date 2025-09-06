#!/bin/bash

echo "🔥 FORCE RESET AV Wallet"
echo "========================"

# Arrêter l'application si elle tourne
echo "🛑 Arrêt de l'application..."
pkill -f "flutter run" 2>/dev/null || true

# Nettoyer les caches Flutter
echo "🧹 Nettoyage des caches Flutter..."
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf ios/Pods/
rm -rf android/.gradle/

# Nettoyer les données de l'émulateur/simulateur
echo "📱 Nettoyage des données de l'émulateur..."

# Android
if command -v adb &> /dev/null; then
    echo "   - Android..."
    adb shell pm clear com.example.av_wallet_hive 2>/dev/null || true
    adb shell rm -rf /data/data/com.example.av_wallet_hive 2>/dev/null || true
fi

# iOS
if command -v xcrun &> /dev/null; then
    echo "   - iOS..."
    xcrun simctl uninstall booted com.example.av_wallet_hive 2>/dev/null || true
    xcrun simctl erase all 2>/dev/null || true
fi

# Nettoyer TOUS les fichiers Hive
echo "🗄️ Nettoyage agressif des données Hive..."
find . -name "*.hive" -delete 2>/dev/null || true
find . -name "*.lock" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true

# Nettoyer les dossiers de données iOS
echo "🍎 Nettoyage des données iOS..."
rm -rf ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Documents/*.hive 2>/dev/null || true
rm -rf ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Library/Application\ Support/*.hive 2>/dev/null || true

# Nettoyer les dossiers de données Android
echo "🤖 Nettoyage des données Android..."
rm -rf ~/.android/avd/*/userdata-qemu.img 2>/dev/null || true

# Réinstaller les dépendances
echo "📦 Réinstallation des dépendances..."
flutter pub get

echo ""
echo "✅ FORCE RESET TERMINÉ !"
echo ""
echo "📱 Prochaines étapes:"
echo "   1. Relancez l'application: flutter run"
echo "   2. L'application va afficher la page de connexion"
echo "   3. TOUTES les données locales ont été supprimées"
echo "   4. Vos presets et projets ne seront plus là"
echo ""
echo "🚀 L'application est maintenant comme neuve !"
