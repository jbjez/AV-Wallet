# 🎮 Guide de Configuration Unity AR

## 📋 **Prérequis**
- Unity 2022.3 LTS (ou 2021.3+)
- Unity Hub installé
- iOS/Android Build Support activé

## 🚀 **Étape 1 : Créer le projet Unity**

### **1.1 Nouveau projet**
1. **Unity Hub** → **New Project**
2. **Template** : **3D Core**
3. **Project Name** : `ARMeasureUnity`
4. **Location** : `/Users/jbjezequel/Desktop/AV_Wallet_Hive/unity_ar_measure/`
5. **Create Project**

### **1.2 Vérifier la version Unity**
- **Help** → **About Unity**
- Version recommandée : **2022.3 LTS**

## 📦 **Étape 2 : Installer AR Foundation**

### **2.1 Package Manager**
1. **Window** → **Package Manager**
2. **Unity Registry** (dans le dropdown)
3. **Rechercher et installer** :
   - `AR Foundation` (4.2.8+)
   - `ARKit XR Plugin` (iOS)
   - `ARCore XR Plugin` (Android)

### **2.2 Vérifier l'installation**
- **Window** → **Package Manager**
- **In Project** → Vérifier que les packages sont installés

## ⚙️ **Étape 3 : Configurer XR Plug-in Management**

### **3.1 Project Settings**
1. **Edit** → **Project Settings**
2. **XR Plug-in Management** (dans la sidebar)

### **3.2 Activer les plugins**
- **iOS** : Cocher **ARKit**
- **Android** : Cocher **ARCore**

## 🎬 **Étape 4 : Créer la scène AR**

### **4.1 Nouvelle scène**
1. **File** → **New Scene**
2. **3D** → **Create**
3. **File** → **Save Scene As**
4. **Nom** : `ARMeasureScene.unity`

### **4.2 Ajouter AR Session**
1. **GameObject** → **XR** → **AR Session**
2. **Position** : (0, 0, 0)
3. **Rotation** : (0, 0, 0)
4. **Scale** : (1, 1, 1)

### **4.3 Ajouter AR Session Origin**
1. **GameObject** → **XR** → **AR Session Origin**
2. **Position** : (0, 0, 0)
3. **Rotation** : (0, 0, 0)
4. **Scale** : (1, 1, 1)

### **4.4 Configurer AR Session Origin**
1. **Sélectionner AR Session Origin**
2. **Add Component** :
   - `ARRaycastManager`
   - `ARPlaneManager`

## 🎯 **Étape 5 : Créer les Prefabs**

### **5.1 Point Prefab**
1. **GameObject** → **3D Object** → **Sphere**
2. **Nom** : `PointPrefab`
3. **Scale** : (0.01, 0.01, 0.01)
4. **Material** : Créer un material orange
5. **Drag** dans le dossier `Assets/Prefabs/`

### **5.2 Line Material**
1. **Assets** → **Create** → **Material**
2. **Nom** : `LineMat`
3. **Couleur** : Blanc ou orange
4. **Shader** : Universal Render Pipeline/Lit

## 🔧 **Étape 6 : Configurer MeasureController**

### **6.1 Créer le script**
1. **Assets** → **Create** → **Folder** → `Scripts`
2. **Assets/Scripts** → **Create** → **C# Script**
3. **Nom** : `MeasureController`
4. **Copier** le contenu du fichier `MeasureController.cs`

### **6.2 Ajouter à la scène**
1. **GameObject** → **Create Empty**
2. **Nom** : `MeasureController`
3. **Add Component** → `MeasureController`

### **6.3 Configurer les références**
1. **Sélectionner MeasureController**
2. **Dans l'Inspector** :
   - **Raycast Manager** → Drag `ARRaycastManager`
   - **Plane Manager** → Drag `ARPlaneManager`
   - **Point Prefab** → Drag `PointPrefab`
   - **Line Material** → Drag `LineMat`

## 🏗️ **Étape 7 : Build Settings**

### **7.1 Scenes In Build**
1. **File** → **Build Settings**
2. **Add Open Scenes** (ARMeasureScene)
3. **Vérifier** que la scène est à l'index 0

### **7.2 Platform Settings**
1. **iOS** : Cocher **ARKit** dans XR Plug-in Management
2. **Android** : Cocher **ARCore** dans XR Plug-in Management

## ✅ **Étape 8 : Test de la scène**

### **8.1 Play Mode**
1. **Play** (bouton ▶️)
2. **Vérifier** que la caméra AR s'active
3. **Tester** le tap sur l'écran

### **8.2 Vérifications**
- ✅ AR Session démarre
- ✅ AR Camera active
- ✅ ARRaycastManager fonctionne
- ✅ ARPlaneManager détecte les plans

## 🚨 **Dépannage**

### **Problèmes courants**
1. **"No AR Session"** → Vérifier que AR Session est dans la scène
2. **"No AR Camera"** → Vérifier que AR Camera est dans AR Session Origin
3. **"No ARRaycastManager"** → Vérifier que le component est ajouté
4. **"No ARPlaneManager"** → Vérifier que le component est ajouté

### **Logs de debug**
- **Console** → Vérifier les erreurs
- **AR Session** → Vérifier le statut
- **AR Camera** → Vérifier que la caméra est active

## 🎯 **Prochaines étapes**

1. **Tester** la scène Unity
2. **Exporter** pour Flutter
3. **Intégrer** avec `flutter_unity_widget`
4. **Tester** sur appareil réel

---

**Note** : Ce guide assume que vous avez Unity 2022.3 LTS installé. Les versions antérieures peuvent nécessiter des ajustements mineurs.