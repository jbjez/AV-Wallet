import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/preset.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../services/hive_service.dart';
import '../models/project.dart';

final presetBoxProvider = Provider<Future<Box<Preset>>>((ref) {
  return HiveService.getPresetsBox();
});

final presetProvider =
    StateNotifierProvider<PresetNotifier, List<Preset>>((ref) {
  return PresetNotifier(ref);
});

final selectedPresetIndexProvider = StateProvider<int>((ref) => -1);

final activePresetProvider = Provider<Preset?>((ref) {
  final presets = ref.watch(presetProvider);
  final selectedIndex = ref.watch(selectedPresetIndexProvider);
  if (presets.isEmpty || selectedIndex < 0 || selectedIndex >= presets.length) {
    return null;
  }
  return presets[selectedIndex];
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => '');

final filteredPresetProvider = Provider<List<Preset>>((ref) {
  final presets = ref.watch(presetProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return presets.where((preset) {
    return searchQuery.isEmpty ||
        preset.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        preset.description.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});

final presetItemProvider = Provider.family<Preset?, String>((ref, id) {
  final presets = ref.watch(presetProvider);
  try {
    return presets.firstWhere((preset) => preset.id == id);
  } catch (e) {
    return null;
  }
});

class PresetNotifier extends StateNotifier<List<Preset>> {
  final Ref ref;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isInitializing = false;

  PresetNotifier(this.ref) : super([]) {
    // Réactiver l'initialisation automatique
    _initAsync();
  }

  // Initialisation asynchrone non-bloquante
  Future<void> _initAsync() async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      _isLoading = true;
      final box = await HiveService.getPresetsBox();
      state = box.values.toList();
      _isInitialized = true;
      
      // Si pas de presets, créer un preset par défaut
      if (state.isEmpty) {
        final defaultPreset = Preset(
          id: 'default_preset_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Preset',
          items: [],
        );
        addPreset(defaultPreset);
        selectPreset(0);
      } else {
        // Migrer les presets existants qui s'appellent "Défaut" vers "Preset"
        bool hasChanges = false;
        print('PresetProvider: Checking ${state.length} existing presets for migration');
        for (int i = 0; i < state.length; i++) {
          print('PresetProvider: Preset $i name: "${state[i].name}"');
          if (state[i].name == 'Défaut') {
            print('PresetProvider: Migrating preset from "Défaut" to "Preset"');
            final updatedPreset = state[i].copyWith(name: 'Preset');
            state[i] = updatedPreset;
            await HiveService.updatePreset(updatedPreset);
            hasChanges = true;
          }
        }
        
        // S'assurer qu'un preset est sélectionné même s'il y a des presets existants
        final currentSelectedIndex = ref.read(selectedPresetIndexProvider);
        if (currentSelectedIndex < 0 || currentSelectedIndex >= state.length) {
          selectPreset(0);
        }
        
        // Notifier les changements si nécessaire
        if (hasChanges) {
          state = [...state];
          print('PresetProvider: Migration completed, state updated');
        } else {
          print('PresetProvider: No migration needed');
        }
      }
    } catch (e) {
      state = [];
    } finally {
      _isLoading = false;
      _isInitializing = false;
    }
  }

  void clearPresets() {
    state = [];
  }

  void addPreset(Preset preset) {
    state = [...state, preset];
  }

  Future<void> updatePreset(Preset updatedPreset) async {
    // Mettre à jour seulement le preset modifié
    final newState = state.map((preset) {
      if (preset.id == updatedPreset.id) {
        return updatedPreset;
      }
      return preset;
    }).toList();
    
    state = newState;
    await HiveService.updatePreset(updatedPreset);
  }

  void removePreset(int index) {
    if (index >= 0 && index < state.length) {
      final newState = List<Preset>.from(state);
      newState.removeAt(index);
      state = newState;
      if (ref.read(selectedPresetIndexProvider) == index) {
        ref.read(selectedPresetIndexProvider.notifier).state = -1;
      }
    }
  }

  void selectPreset(int index) {
    if (index >= 0 && index < state.length) {
      ref.read(selectedPresetIndexProvider.notifier).state = index;
    }
  }

  Future<void> loadPresets() async {
    if (_isLoading || _isInitializing) return;
    
    try {
      _isLoading = true;
      final box = await HiveService.getPresetsBox();
      state = box.values.toList();
      _isInitialized = true;
    } catch (e) {
      state = [];
    } finally {
      _isLoading = false;
    }
  }

  void loadPresetsFromProject(Project project) {
    // Charger directement depuis le projet sans passer par Hive
    state = List.from(project.presets);
    _isInitialized = true;
    
    if (state.isNotEmpty) {
      ref.read(selectedPresetIndexProvider.notifier).state = 0;
    } else {
      ref.read(selectedPresetIndexProvider.notifier).state = -1;
    }
  }

  Future<void> addItemToPreset(String presetId, CatalogueItem item) async {
    final presetIndex = state.indexWhere((p) => p.id == presetId);
    if (presetIndex == -1) return;
    
    final preset = state[presetIndex];
    final cartItem = CartItem(
      item: item,
      quantity: 1,
    );
    
    // Mettre à jour seulement le preset modifié
    final updatedPreset = preset.copyWith(
      items: [...preset.items, cartItem],
    );
    
    final newState = List<Preset>.from(state);
    newState[presetIndex] = updatedPreset;
    state = newState;
    
    await HiveService.updatePreset(updatedPreset);
  }

  Future<void> addItemsToPresetWithQuantities(String presetId, Map<CatalogueItem, int> itemsWithQuantities) async {
    final presetIndex = state.indexWhere((p) => p.id == presetId);
    if (presetIndex == -1) return;
    
    final preset = state[presetIndex];
    final newItems = List<CartItem>.from(preset.items);
    
    for (var entry in itemsWithQuantities.entries) {
      final item = entry.key;
      final quantity = entry.value;
      
      // Vérifier si l'item existe déjà dans le preset
      final existingItemIndex = newItems.indexWhere((cartItem) => cartItem.item.id == item.id);
      
      if (existingItemIndex != -1) {
        // Mettre à jour la quantité existante
        newItems[existingItemIndex] = CartItem(
          item: newItems[existingItemIndex].item,
          quantity: newItems[existingItemIndex].quantity + quantity,
        );
      } else {
        // Ajouter un nouvel item avec sa quantité
        final cartItem = CartItem(
          item: item,
          quantity: quantity,
        );
        newItems.add(cartItem);
      }
    }
    
    // Mettre à jour seulement le preset modifié
    final updatedPreset = preset.copyWith(items: newItems);
    final newState = List<Preset>.from(state);
    newState[presetIndex] = updatedPreset;
    state = newState;
    
    await HiveService.updatePreset(updatedPreset);
  }

  Future<void> removeItemFromPreset(String presetId, String itemId) async {
    try {
      final presetIndex = state.indexWhere((p) => p.id == presetId);
      if (presetIndex == -1) return;

      final preset = state[presetIndex];
      final updatedPreset = preset.copyWith(
        items: preset.items.where((item) => item.item.id != itemId).toList(),
      );

      // Mettre à jour seulement le preset modifié
      final newState = List<Preset>.from(state);
      newState[presetIndex] = updatedPreset;
      state = newState;
      
      await HiveService.updatePreset(updatedPreset);
    } catch (e) {
      // Gérer l'erreur si nécessaire
    }
  }

  Future<void> clear() async {
    try {
      await HiveService.clearPresets();
      state = [];
      _isInitialized = false;
    } catch (e) {
      // Gérer l'erreur si nécessaire
    }
  }

  // Méthodes de compatibilité
  Preset? get activePreset {
    final index = ref.read(selectedPresetIndexProvider);
    if (index < 0 || index >= state.length) return null;
    return state[index];
  }

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Méthodes de compatibilité
  int get selectedPresetIndex => ref.read(selectedPresetIndexProvider);

  void setActivePresetIndex(int index) {
    ref.read(selectedPresetIndexProvider.notifier).state = index;
  }

  Future<void> addItemToActivePreset(CatalogueItem item) async {
    final preset = activePreset;
    if (preset != null) {
      await addItemToPreset(preset.id, item);
    }
  }

  Future<void> removeItemFromActivePreset(CatalogueItem item) async {
    final preset = activePreset;
    if (preset != null) {
      await removeItemFromPreset(preset.id, item.id);
    }
  }
}
