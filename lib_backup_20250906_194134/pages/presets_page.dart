import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../models/preset.dart';
import '../models/cart_data.dart';

class PresetsPage extends ConsumerStatefulWidget {
  const PresetsPage({super.key});

  @override
  ConsumerState<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends ConsumerState<PresetsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les presets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presetProvider.notifier).loadPresets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(presetProvider);
    final filteredPresets = ref.watch(filteredPresetProvider);
    final selectedIndex = ref.watch(selectedPresetIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Presets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un preset...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          
          // Liste des presets
          Expanded(
            child: filteredPresets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPresets.length,
                    itemBuilder: (context, index) {
                      final preset = filteredPresets[index];
                      final isSelected = selectedIndex == presets.indexOf(preset);
                      
                      return _buildPresetCard(preset, isSelected, index);
                    },
                    // Assurer que le scroll fonctionne
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPreset,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun preset trouvé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier preset en appuyant sur le bouton +',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(Preset preset, bool isSelected, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectPreset(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du preset
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                  // Boutons d'action visibles
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton Renommer
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _editPreset(preset),
                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                          label: const Text('Renommer', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(80, 32),
                          ),
                        ),
                      ),
                      // Bouton Supprimer
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _deletePreset(preset),
                          icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                          label: const Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(80, 32),
                          ),
                        ),
                      ),
                      // Menu contextuel pour actions supplémentaires
                      PopupMenuButton<String>(
                        onSelected: (value) => _handlePresetAction(value, preset),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              if (preset.description.isNotEmpty)
                Text(
                  preset.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Informations du preset
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${preset.items.length} article${preset.items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Créé le ${_formatDate(preset.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              
              // Liste des articles (en abrégé et en gras)
              if (preset.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Articles :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: preset.items.take(5).map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              item.item.name, // Nom uniquement, pas la marque
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (preset.items.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${preset.items.length - 5} autre${preset.items.length - 5 > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectPreset(int index) {
    ref.read(selectedPresetIndexProvider.notifier).state = index;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset "${ref.read(presetProvider)[index].name}" sélectionné'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePresetAction(String action, Preset preset) {
    switch (action) {
      case 'edit':
        _editPreset(preset);
        break;
      case 'delete':
        _deletePreset(preset);
        break;
    }
  }

  void _editPreset(Preset preset) {
    final nameController = TextEditingController(text: preset.name);
    final descriptionController = TextEditingController(text: preset.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer le preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nouveau nom du preset',
                border: OutlineInputBorder(),
                hintText: 'Entrez le nouveau nom',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'Description du preset',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != preset.name) {
                final updatedPreset = preset.copyWith(
                  name: newName,
                  description: descriptionController.text.trim(),
                );
                ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preset renommé en "${newName}"'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom du preset ne peut pas être vide'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  void _deletePreset(Preset preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le preset'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le preset "${preset.name}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final index = ref.read(presetProvider).indexOf(preset);
              if (index != -1) {
                ref.read(presetProvider.notifier).removePreset(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preset "${preset.name}" supprimé'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _createNewPreset() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du preset',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newPreset = Preset(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
                ref.read(presetProvider.notifier).addPreset(newPreset);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preset "${newPreset.name}" créé'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
