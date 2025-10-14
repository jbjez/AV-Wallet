import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'ar_measure_unity_page.dart';
import '../utils/permissions.dart';
import '../providers/preset_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/uniform_bottom_nav_bar.dart';

class ArMeasurePage extends ConsumerStatefulWidget {
  const ArMeasurePage({Key? key}) : super(key: key);
  @override
  ConsumerState<ArMeasurePage> createState() => _ArMeasurePageState();
}

class _ArMeasurePageState extends ConsumerState<ArMeasurePage> with TickerProviderStateMixin {
  bool _ready = false;
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    // Debug log pour vérifier les permissions
    final camStatus = await Permission.camera.status;
    debugPrint('CAM status iOS: $camStatus');
    
    final ok = await AppPermissions.ensureCamera();
    if (mounted) {
      setState(() => _ready = ok);
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    
    setState(() => _isCapturing = true);
    
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null) {
        await _savePhotoToProject(photo);
        _showSuccessMessage();
      }
    } catch (e) {
      debugPrint('Erreur capture photo: $e');
      _showErrorMessage('${AppLocalizations.of(context)!.arMeasure_captureError}: $e');
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _savePhotoToProject(XFile photo) async {
    try {
      // Récupérer le preset actif
      final activePreset = ref.read(activePresetProvider);
      final presetName = activePreset?.name ?? AppLocalizations.of(context)!.arMeasure_defaultProject;
      
      // Créer le dossier du projet s'il n'existe pas
      final documentsDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${documentsDir.path}/projets/$presetName/photos_ar');
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }
      
      // Générer un nom de fichier unique avec timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ar_photo_${timestamp}.jpg';
      final filePath = '${projectDir.path}/$fileName';
      
      // Copier la photo dans le dossier du projet
      final File sourceFile = File(photo.path);
      final File destinationFile = File(filePath);
      await sourceFile.copy(destinationFile.path);
      
      debugPrint('Photo sauvegardée: $filePath');
      
      // Optionnel: supprimer la photo temporaire
      await sourceFile.delete();
      
    } catch (e) {
      debugPrint('${AppLocalizations.of(context)!.arMeasure_saveError}: $e');
      throw e;
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.arMeasure_photoSaved),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.camera_alt,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue[300]
                        : const Color(0xFF0A1128),
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue[300]
                        : const Color(0xFF0A1128),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.lightBlue[300]
                                  : const Color(0xFF0A1128),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Photo/AR',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue[300]
                                    : const Color(0xFF0A1128),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Contenu principal
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context)!.arMeasure_takePhotosAndMeasure,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                
                                // Boutons côte à côte
                                Row(
                                  children: [
                                    // Bouton Appareil Photo
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _ready && !_isCapturing ? _capturePhoto : null,
                                        icon: _isCapturing
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.photo_camera, color: Colors.white),
                                        label: Text(
                                          _isCapturing ? AppLocalizations.of(context)!.arMeasure_capturing : AppLocalizations.of(context)!.arMeasure_photo,
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange[700],
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Bouton Unity AR
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _ready ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ArMeasureUnityPage(),
                                            ),
                                          );
                                        } : null,
                                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                                        label: Text(
                                          AppLocalizations.of(context)!.arMeasure_unity,
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey[700],
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Info sur l'enregistrement
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.arMeasure_photosAutoSaved,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(
        currentIndex: 6, // Divers (page catch-all)
      ),
    );
  }
}