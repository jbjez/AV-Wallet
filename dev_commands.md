# 🚀 Commandes de Développement Flutter

## 📱 **Build et Run Automatiques**

### **Android (copier-coller)**
```bash
flutter clean && flutter pub get && flutter run -d android
```

### **iOS (copier-coller)**
```bash
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run -d ios
```

### **Web (copier-coller)**
```bash
flutter clean && flutter pub get && flutter run -d chrome
```

### **macOS (copier-coller)**
```bash
flutter clean && flutter pub get && flutter run -d macos
```

## 🔄 **Commandes Rapides**

### **Hot Reload (pendant le run)**
```bash
r
```

### **Hot Restart (pendant le run)**
```bash
R
```

### **Quitter (pendant le run)**
```bash
q
```

### **Nettoyer et Rebuild**
```bash
flutter clean && flutter pub get
```

### **Analyser le Code**
```bash
flutter analyze
```

### **Format le Code**
```bash
flutter format .
```

## ⚡ **Alias Bash (à ajouter dans ~/.zshrc ou ~/.bashrc)**

```bash
# Ajouter ces lignes à votre fichier de profil shell
alias fclean="flutter clean && flutter pub get"
alias fandroid="fclean && flutter run -d android"
alias fios="fclean && cd ios && pod install && cd .. && flutter run -d ios"
alias fweb="fclean && flutter run -d chrome"
alias fmacos="fclean && flutter run -d macos"
alias fanalyze="flutter analyze"
alias fformat="flutter format ."
```

## 🎯 **Workflow Recommandé**

1. **Développement** : `flutter run -d android` (ou autre plateforme)
2. **Modifications** : Le hot reload se fait automatiquement
3. **Problèmes** : `flutter clean && flutter pub get`
4. **Test final** : `flutter analyze` puis build

## 💡 **Astuces**

- **Gardez un terminal ouvert** avec `flutter run` en cours
- **Utilisez les alias** pour aller plus vite
- **Hot reload** = automatique quand vous sauvegardez
- **Hot restart** = nécessaire pour certains changements (imports, etc.)



