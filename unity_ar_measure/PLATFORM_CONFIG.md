# 📱 Configuration des Plateformes AR

## 🍎 **iOS - ARKit Configuration**

### **1. Unity Build Settings**
1. **File** → **Build Settings**
2. **Platform** → **iOS**
3. **Switch Platform**
4. **Player Settings** → **XR Plug-in Management**
5. **Cocher** : **ARKit**

### **2. iOS Player Settings**
1. **Player Settings** → **iOS**
2. **Configuration** :
   - **Target minimum iOS Version** : 11.0+
   - **Architecture** : ARM64
   - **Camera Usage Description** : "Cette app utilise la caméra pour la mesure AR"

### **3. Info.plist Configuration**
1. **Player Settings** → **iOS** → **Other Settings**
2. **Camera Usage Description** : "Cette app utilise la caméra pour la mesure AR"
3. **Location Usage Description** : "Cette app utilise la localisation pour la mesure AR"

### **4. ARKit Requirements**
- **iOS 11.0+** (recommandé 14.0+)
- **Appareil compatible ARKit** (iPhone 6s+)
- **Caméra arrière** requise

## 🤖 **Android - ARCore Configuration**

### **1. Unity Build Settings**
1. **File** → **Build Settings**
2. **Platform** → **Android**
3. **Switch Platform**
4. **Player Settings** → **XR Plug-in Management**
5. **Cocher** : **ARCore**

### **2. Android Player Settings**
1. **Player Settings** → **Android**
2. **Configuration** :
   - **Minimum API Level** : 24 (Android 7.0)
   - **Target API Level** : 33+ (Android 13+)
   - **Architecture** : ARM64

### **3. Android Manifest**
1. **Player Settings** → **Android** → **Publishing Settings**
2. **Custom Main Manifest** : Cocher
3. **Modifier** `Assets/Plugins/Android/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.ar" android:required="true" />
```

### **4. ARCore Requirements**
- **Android 7.0+** (API 24+)
- **Appareil compatible ARCore**
- **Caméra arrière** requise
- **Gyroscope** et **Accéléromètre** recommandés

## 🔧 **Configuration Flutter**

### **1. iOS Info.plist**
Ajouter dans `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Cette app utilise la caméra pour la mesure AR</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app utilise la localisation pour la mesure AR</string>
```

### **2. Android Permissions**
Ajouter dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.ar" android:required="true" />
```

## 🚀 **Build et Export**

### **1. Unity Export**
1. **File** → **Build Settings**
2. **Platform** → Choisir iOS ou Android
3. **Build** → Choisir le dossier de destination
4. **Export** pour Flutter

### **2. Flutter Integration**
1. **Ajouter** `flutter_unity_widget` au `pubspec.yaml`
2. **Configurer** les chemins Unity dans Flutter
3. **Build** l'app Flutter

## 🧪 **Tests de compatibilité**

### **iOS Tests**
- **iPhone 6s+** avec iOS 11.0+
- **Test** de la détection de plans
- **Test** de la mesure de distance
- **Test** des permissions caméra

### **Android Tests**
- **Appareil compatible ARCore**
- **Android 7.0+**
- **Test** de la détection de plans
- **Test** de la mesure de distance
- **Test** des permissions caméra

## 🚨 **Dépannage**

### **iOS Problèmes**
1. **"ARKit not available"** → Vérifier la version iOS
2. **"Camera permission denied"** → Vérifier Info.plist
3. **"No AR Session"** → Vérifier la configuration Unity

### **Android Problèmes**
1. **"ARCore not available"** → Vérifier la compatibilité
2. **"Camera permission denied"** → Vérifier AndroidManifest.xml
3. **"No AR Session"** → Vérifier la configuration Unity

### **Flutter Problèmes**
1. **"UnityFramework not found"** → Vérifier l'export Unity
2. **"Build failed"** → Vérifier les chemins Unity
3. **"Runtime error"** → Vérifier la configuration des plateformes

## 📋 **Checklist de validation**

### **iOS Checklist**
- [ ] ARKit activé dans Unity
- [ ] iOS 11.0+ configuré
- [ ] Camera Usage Description ajouté
- [ ] Appareil compatible testé
- [ ] Détection de plans fonctionnelle
- [ ] Mesure de distance fonctionnelle

### **Android Checklist**
- [ ] ARCore activé dans Unity
- [ ] Android 7.0+ configuré
- [ ] Permissions caméra ajoutées
- [ ] Appareil compatible testé
- [ ] Détection de plans fonctionnelle
- [ ] Mesure de distance fonctionnelle

### **Flutter Checklist**
- [ ] flutter_unity_widget ajouté
- [ ] Chemins Unity configurés
- [ ] Build Flutter réussi
- [ ] Test sur appareil réel
- [ ] Communication Unity-Flutter fonctionnelle

---

**Note** : Ces configurations sont essentielles pour le bon fonctionnement de l'AR. Vérifiez chaque étape avant de passer à la suivante.