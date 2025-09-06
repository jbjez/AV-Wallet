# 🎮 Unity AR Measure - Projet de Mesure AR

## 🎯 **Vue d'ensemble**

Ce projet Unity implémente une solution de mesure AR professionnelle utilisant **AR Foundation** pour la détection de plans et la mesure de distance A↔B. Il s'intègre avec Flutter via `flutter_unity_widget` pour offrir une expérience AR native et performante.

## ✨ **Fonctionnalités**

### **🔍 Détection AR**
- **Détection de plans** en temps réel (ARKit/ARCore)
- **Raycasting** précis sur les surfaces détectées
- **Visualisation** des plans détectés

### **📏 Mesure de distance**
- **Placement de points A & B** par tap sur l'écran
- **Ligne 3D** entre les points avec LineRenderer
- **Calcul de distance** en mètres (3 décimales)
- **Communication Flutter** via JSON messages

### **🎨 Interface utilisateur**
- **Points visuels** : Sphères orange et bleue
- **Ligne de mesure** : LineRenderer avec material personnalisé
- **Reset** : Suppression des points et ligne
- **Focus ring** : Animation Flutter au tap

## 🏗️ **Architecture**

### **Unity Side**
- **AR Session** : Gestionnaire AR principal
- **AR Session Origin** : Point d'origine AR avec caméra
- **ARRaycastManager** : Détection de plans et raycasting
- **ARPlaneManager** : Gestion des plans détectés
- **MeasureController** : Script principal de mesure

### **Flutter Side**
- **ArMeasureUnityPage** : Page Flutter intégrant Unity
- **UnityWidget** : Widget d'intégration Unity
- **Communication** : JSON messages Unity ↔ Flutter

## 📁 **Structure du projet**

```
unity_ar_measure/
├── Assets/
│   ├── Scripts/
│   │   └── MeasureController.cs      # Script principal AR
│   ├── Prefabs/
│   │   └── PointPrefab.prefab        # Prefab pour les points
│   ├── Materials/
│   │   └── LineMat.mat               # Material pour la ligne
│   └── Scenes/
│       └── ARMeasureScene.unity      # Scène AR principale
├── README.md                         # Ce fichier
├── UNITY_SETUP_GUIDE.md             # Guide de configuration Unity
├── PLATFORM_CONFIG.md               # Configuration iOS/Android
└── QUICK_START.md                   # Démarrage rapide
```

## 🚀 **Démarrage rapide**

### **1. Prérequis**
- Unity 2022.3 LTS (ou 2021.3+)
- Unity Hub installé
- iOS/Android Build Support

### **2. Installation**
1. **Créer projet Unity** : `ARMeasureUnity`
2. **Installer AR Foundation** : AR Foundation + ARKit + ARCore
3. **Configurer XR** : Activer ARKit (iOS) et ARCore (Android)
4. **Créer scène AR** : AR Session + AR Session Origin
5. **Ajouter script** : MeasureController.cs

### **3. Configuration**
1. **Créer prefabs** : PointPrefab (sphère) + LineMat (material)
2. **Configurer MeasureController** : Références AR managers
3. **Tester** : Play Mode + Build

### **4. Intégration Flutter**
1. **Ajouter** `flutter_unity_widget` au pubspec.yaml
2. **Configurer** les chemins Unity
3. **Build** et tester sur appareil

## 📖 **Documentation**

### **Guides détaillés**
- **[UNITY_SETUP_GUIDE.md](UNITY_SETUP_GUIDE.md)** : Configuration Unity complète
- **[PLATFORM_CONFIG.md](PLATFORM_CONFIG.md)** : Configuration iOS/Android
- **[QUICK_START.md](QUICK_START.md)** : Démarrage rapide (15 min)

### **Scripts Unity**
- **MeasureController.cs** : Script principal de mesure AR
- **Fonctionnalités** : Détection de plans, placement de points, calcul de distance

## 🔧 **Configuration technique**

### **Unity Requirements**
- **Unity** : 2022.3 LTS (recommandé)
- **AR Foundation** : 4.2.8+
- **ARKit XR Plugin** : iOS
- **ARCore XR Plugin** : Android

### **Platform Requirements**
- **iOS** : 11.0+ (ARKit compatible)
- **Android** : 7.0+ (ARCore compatible)
- **Caméra** : Arrière requise
- **Capteurs** : Gyroscope + Accéléromètre

### **Flutter Integration**
- **flutter_unity_widget** : ^2022.2.1
- **Communication** : JSON messages
- **Platform** : iOS + Android

## 🧪 **Tests et validation**

### **Tests Unity**
- [ ] AR Session démarre correctement
- [ ] Détection de plans fonctionnelle
- [ ] Placement de points A & B
- [ ] Calcul de distance précis
- [ ] Reset fonctionnel

### **Tests Flutter**
- [ ] Intégration Unity réussie
- [ ] Communication JSON fonctionnelle
- [ ] Interface utilisateur responsive
- [ ] Focus ring animé
- [ ] Build iOS/Android réussi

### **Tests sur appareil**
- [ ] Détection de plans en temps réel
- [ ] Mesure de distance précise
- [ ] Performance fluide
- [ ] Pas de crash ou freeze

## 🚨 **Dépannage**

### **Problèmes Unity**
1. **"No AR Session"** → Vérifier AR Session dans la scène
2. **"No AR Camera"** → Vérifier AR Camera dans AR Session Origin
3. **"No ARRaycastManager"** → Vérifier le component ajouté
4. **"Build failed"** → Vérifier la configuration des plateformes

### **Problèmes Flutter**
1. **"UnityFramework not found"** → Vérifier l'export Unity
2. **"Build failed"** → Vérifier les chemins Unity
3. **"Runtime error"** → Vérifier la configuration des plateformes

### **Problèmes AR**
1. **"No plane detection"** → Vérifier ARPlaneManager
2. **"No raycast hit"** → Vérifier ARRaycastManager
3. **"Distance calculation error"** → Vérifier Vector3.Distance

## 🎯 **Prochaines étapes**

### **Améliorations possibles**
1. **Snap au plan** : Alignement automatique sur le plan dominant
2. **Unités** : Support mètres/pieds selon la langue
3. **Labels 3D** : Affichage de la distance au milieu du segment
4. **Sauvegarde** : Persistance des mesures
5. **Export** : Sauvegarde des mesures en fichier

### **Optimisations**
1. **Performance** : Optimisation du raycasting
2. **Battery** : Gestion de la consommation
3. **Memory** : Gestion de la mémoire
4. **Network** : Communication optimisée

## 📞 **Support**

### **Documentation**
- **Unity AR Foundation** : [Documentation officielle](https://docs.unity3d.com/Packages/com.unity.xr.arfoundation@latest/)
- **flutter_unity_widget** : [Documentation GitHub](https://github.com/flutter-unity/flutter_unity_widget)

### **Communauté**
- **Unity Forums** : AR Foundation
- **Flutter Community** : flutter_unity_widget
- **GitHub Issues** : Problèmes et suggestions

---

**Version** : 1.0.0  
**Dernière mise à jour** : Janvier 2025  
**Compatibilité** : Unity 2022.3 LTS + Flutter 3.0+

🚀 **Prêt pour la mesure AR professionnelle !**