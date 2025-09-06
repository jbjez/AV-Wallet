import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preset.dart';
import '../providers/catalogue_provider.dart';
import '../models/cart_item.dart';

final defaultPresetsProvider = Provider<List<Preset>>((ref) {
  final catalogueItems = ref.watch(catalogueProvider);
  
  return [
    Preset(
      id: 'default',
      name: 'Default',
      description: 'Default preset containing all items',
      items: catalogueItems.where((item) => 
        item.categorie == 'Light' || 
        item.categorie == 'Sound' || 
        item.categorie == 'Video'
      ).map((item) => CartItem(
        item: item,
        quantity: 1,
      )).toList(),
    ),
    // Add more default presets if needed
  ];
}); 