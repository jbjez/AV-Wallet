#!/bin/bash

echo "🚀 Script de Build Automatique Flutter"
echo "======================================"

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: ./auto_build.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  android    - Build et run sur Android"
    echo "  ios        - Build et run sur iOS"
    echo "  web        - Build et run sur le web"
    echo "  macos      - Build et run sur macOS"
    echo "  all        - Build sur toutes les plateformes"
    echo "  clean      - Nettoyer et rebuild"
    echo "  watch      - Mode watch avec hot reload"
    echo "  help       - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  ./auto_build.sh android"
    echo "  ./auto_build.sh watch"
    echo "  ./auto_build.sh clean"
}

# Fonction pour build Android
build_android() {
    echo "📱 Building pour Android..."
    flutter clean
    flutter pub get
    flutter build apk --debug
    echo "✅ Build Android terminé !"
}

# Fonction pour build iOS
build_ios() {
    echo "🍎 Building pour iOS..."
    flutter clean
    flutter pub get
    cd ios && pod install && cd ..
    flutter build ios --debug
    echo "✅ Build iOS terminé !"
}

# Fonction pour build Web
build_web() {
    echo "🌐 Building pour le Web..."
    flutter clean
    flutter pub get
    flutter build web
    echo "✅ Build Web terminé !"
}

# Fonction pour build macOS
build_macos() {
    echo "🖥️  Building pour macOS..."
    flutter clean
    flutter pub get
    flutter build macos
    echo "✅ Build macOS terminé !"
}

# Fonction pour nettoyer et rebuild
clean_build() {
    echo "🧹 Nettoyage et rebuild..."
    flutter clean
    flutter pub get
    flutter analyze
    echo "✅ Nettoyage terminé !"
}

# Fonction pour mode watch
watch_mode() {
    echo "👀 Mode Watch activé - Hot Reload automatique"
    echo "Appuyez sur Ctrl+C pour arrêter"
    flutter run --hot
}

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Traitement des arguments
case "${1:-help}" in
    "android")
        build_android
        ;;
    "ios")
        build_ios
        ;;
    "web")
        build_web
        ;;
    "macos")
        build_macos
        ;;
    "all")
        echo "🔄 Build sur toutes les plateformes..."
        build_android
        build_ios
        build_web
        build_macos
        ;;
    "clean")
        clean_build
        ;;
    "watch")
        watch_mode
        ;;
    "help"|*)
        show_help
        ;;
esac



