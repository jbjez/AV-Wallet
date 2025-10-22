import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../providers/imported_photos_provider.dart';
import '../providers/project_provider.dart';
import 'dart:io';

/// Widget pour importer des photos dans un projet
class PhotoImportWidget extends ConsumerStatefulWidget {
  const PhotoImportWidget({super.key});

  @override
  ConsumerState<PhotoImportWidget> createState() => _PhotoImportWidgetState();
}

class _PhotoImportWidgetState extends ConsumerState<PhotoImportWidget> {
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Initialiser le provider des photos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(importedPhotosProvider.notifier).loadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider).selectedProject;
    final projectName = project.name ?? 'Projet par défaut'; // Utiliser le nom brut du projet
    final photos = ref.watch(projectPhotosProvider(projectName));
    final hasPhotos = ref.watch(hasProjectPhotosProvider(projectName));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Photos du projet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (hasPhotos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${photos.length} photo${photos.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bouton d'import
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isImporting ? null : _importPhotos,
              icon: _isImporting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: Text(
                _isImporting 
                  ? 'Import en cours...' 
                  : hasPhotos 
                    ? 'Ajouter des photos'
                    : 'Importer des photos',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Liste des photos importées
          if (hasPhotos) ...[
            const SizedBox(height: 16),
            Text(
              'Photos importées:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...photos.map((photoPath) => _buildPhotoItem(photoPath, projectName)),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String photoPath, String projectName) {
    final fileName = photoPath.split('/').last;
    final file = File(photoPath);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                FutureBuilder<bool>(
                  future: file.exists(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data! ? 'Fichier disponible' : 'Fichier introuvable',
                        style: TextStyle(
                          color: snapshot.data! 
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removePhoto(photoPath, projectName),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 20,
            ),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }

  Future<void> _importPhotos() async {
    try {
      setState(() {
        _isImporting = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: false, // Ne pas charger les données en mémoire
      );

      if (result != null && result.files.isNotEmpty) {
        final project = ref.read(projectProvider).selectedProject;
        final projectName = project.name ?? 'Projet par défaut'; // Utiliser le nom brut du projet
        
        int importedCount = 0;
        for (final file in result.files) {
          if (file.path != null) {
            await ref.read(importedPhotosProvider.notifier)
                .addPhotoToProject(projectName, file.path!);
            importedCount++;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$importedCount photo${importedCount > 1 ? 's' : ''} importée${importedCount > 1 ? 's' : ''}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _removePhoto(String photoPath, String projectName) async {
    try {
      await ref.read(importedPhotosProvider.notifier)
          .removePhotoFromProject(projectName, photoPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo supprimée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
