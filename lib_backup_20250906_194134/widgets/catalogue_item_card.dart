import 'package:flutter/material.dart';
import '../models/catalogue_item.dart';

class CatalogueItemCard extends StatelessWidget {
  final CatalogueItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatalogueItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            Text('Catégorie: ${item.categorie}'),
            if (item.sousCategorie.isNotEmpty)
              Text('Sous-catégorie: ${item.sousCategorie}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.network(
                  item.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(item.name),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.imageUrl != null)
                      Center(
                        child: Image.network(
                          item.imageUrl!,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 100);
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text('Description: ${item.description}'),
                    Text('Catégorie: ${item.categorie}'),
                    if (item.sousCategorie.isNotEmpty)
                      Text('Sous-catégorie: ${item.sousCategorie}'),
                    if (item.marque.isNotEmpty) Text('Marque: ${item.marque}'),
                    if (item.produit.isNotEmpty)
                      Text('Produit: ${item.produit}'),
                    if (item.dimensions.isNotEmpty)
                      Text('Dimensions: ${item.dimensions}'),
                    if (item.poids.isNotEmpty) Text('Poids: ${item.poids}'),
                    if (item.conso.isNotEmpty)
                      Text('Consommation: ${item.conso}'),
                    if (item.resolutionDalle != null)
                      Text('Résolution dalle: ${item.resolutionDalle}'),
                    if (item.angle != null) Text('Angle: ${item.angle}'),
                    if (item.lux != null) Text('Lux: ${item.lux}'),
                    if (item.lumens != null) Text('Lumens: ${item.lumens}'),
                    if (item.definition != null)
                      Text('Définition: ${item.definition}'),
                    if (item.dmxMax != null && item.dmxMini != null)
                      Text('DMX: ${item.dmxMax} / ${item.dmxMini}'),
                    if (item.resolution != null)
                      Text('Résolution: ${item.resolution}'),
                    if (item.pitch != null) Text('Pitch: ${item.pitch}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
