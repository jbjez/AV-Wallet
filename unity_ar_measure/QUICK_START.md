# 🚀 Démarrage Rapide Unity AR

## ⚡ **Setup en 15 minutes**

### **1. Créer le projet Unity** (5 min)
1. **Unity Hub** → **New Project**
2. **3D Core** → **ARMeasureUnity**
3. **Location** : `/Users/jbjezequel/Desktop/AV_Wallet_Hive/unity_ar_measure/`

### **2. Installer AR Foundation** (3 min)
1. **Window** → **Package Manager**
2. **Installer** :
   - `AR Foundation`
   - `ARKit XR Plugin` (iOS)
   - `ARCore XR Plugin` (Android)

### **3. Configurer XR** (2 min)
1. **Edit** → **Project Settings**
2. **XR Plug-in Management**
3. **Cocher** : ARKit (iOS) + ARCore (Android)

### **4. Créer la scène AR** (3 min)
1. **File** → **New Scene** → **ARMeasureScene**
2. **GameObject** → **XR** → **AR Session**
3. **GameObject** → **XR** → **AR Session Origin**
4. **Add Component** : `ARRaycastManager` + `ARPlaneManager`

### **5. Ajouter le script** (2 min)
1. **Assets** → **Create** → **Folder** → `Scripts`
2. **Copier** `MeasureController.cs` dans `Assets/Scripts/`
3. **GameObject** → **Create Empty** → **MeasureController**
4. **Add Component** → `MeasureController`

## 🎯 **Configuration rapide**

### **Point Prefab**
1. **GameObject** → **3D Object** → **Sphere**
2. **Scale** : (0.01, 0.01, 0.01)
3. **Material** : Orange
4. **Drag** dans `Assets/Prefabs/`

### **Line Material**
1. **Assets** → **Create** → **Material**
2. **Nom** : `LineMat`
3. **Couleur** : Blanc

### **Configurer MeasureController**
1. **Sélectionner MeasureController**
2. **Inspector** :
   - **Raycast Manager** → Drag `ARRaycastManager`
   - **Plane Manager** → Drag `ARPlaneManager`
   - **Point Prefab** → Drag `PointPrefab`
   - **Line Material** → Drag `LineMat`

## 🧪 **Test rapide**

### **Play Mode**
1. **Play** (▶️)
2. **Vérifier** : AR Session démarre
3. **Tester** : Tap sur l'écran
4. **Vérifier** : Points A & B se placent

### **Build Test**
1. **File** → **Build Settings**
2. **Add Open Scenes**
3. **Build** → Test sur appareil

## 🔧 **Intégration Flutter**

### **1. Ajouter flutter_unity_widget**
```yaml
dependencies:
  flutter_unity_widget: ^2022.2.1
```

### **2. Configurer les chemins**
```dart
UnityWidget(
  onUnityCreated: _onUnityCreated,
  onUnityMessage: _onUnityMessage,
  fullscreen: true,
)
```

### **3. Build Flutter**
```bash
flutter clean
flutter pub get
flutter run
```

## ✅ **Checklist rapide**

- [ ] Projet Unity créé
- [ ] AR Foundation installé
- [ ] XR Plug-ins activés
- [ ] Scène AR créée
- [ ] Script MeasureController ajouté
- [ ] Prefabs configurés
- [ ] Test Play Mode réussi
- [ ] Build Unity réussi
- [ ] Flutter intégré
- [ ] Test sur appareil réussi

## 🚨 **Problèmes courants**

### **"No AR Session"**
- Vérifier que AR Session est dans la scène
- Vérifier que AR Session Origin est configuré

### **"No AR Camera"**
- Vérifier que AR Camera est dans AR Session Origin
- Vérifier que la caméra est active

### **"No ARRaycastManager"**
- Vérifier que le component est ajouté
- Vérifier que les références sont configurées

### **"Build failed"**
- Vérifier les chemins Unity
- Vérifier la configuration des plateformes
- Vérifier les permissions caméra

## 🎯 **Prochaines étapes**

1. **Tester** la scène Unity
2. **Exporter** pour Flutter
3. **Intégrer** avec flutter_unity_widget
4. **Tester** sur appareil réel
5. **Optimiser** les performances

---

**Temps total** : ~15 minutes pour un setup complet fonctionnel ! 🚀