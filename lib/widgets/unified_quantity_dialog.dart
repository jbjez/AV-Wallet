import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnifiedQuantityDialog extends ConsumerStatefulWidget {
  final CatalogueItem item;
  final int initialQuantity;
  final bool showAmplifierDialog; // Pour la page son
  final bool showDmxDialog; // Pour la page lumière
  final Function(CatalogueItem item, int quantity, {String? amplifier, String? dmxMode}) onConfirm;

  const UnifiedQuantityDialog({
    super.key,
    required this.item,
    this.initialQuantity = 1,
    this.showAmplifierDialog = false,
    this.showDmxDialog = false,
    required this.onConfirm,
  });

  @override
  ConsumerState<UnifiedQuantityDialog> createState() => _UnifiedQuantityDialogState();
}

class _UnifiedQuantityDialogState extends ConsumerState<UnifiedQuantityDialog> {
  late int quantity;
  String? selectedAmplifier;
  String? selectedDmxMode;
  
  // Options pour l'amplificateur (page son)
  final List<String> amplifierOptions = [
    'Aucun',
    'Ampli 1',
    'Ampli 2', 
    'Ampli 3',
    'Ampli 4',
  ];
  
  // Options pour le mode DMX (page lumière)
  final List<String> dmxModeOptions = [
    'Mode 1',
    'Mode 2',
    'Mode 3',
    'Mode 4',
  ];

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    selectedAmplifier = amplifierOptions.first;
    selectedDmxMode = dmxModeOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getCategoryIcon(widget.item.categorie),
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.item.produit,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du produit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marque: ${widget.item.marque}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.item.categorie.isNotEmpty)
                    Text(
                      'Catégorie: ${widget.item.categorie}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  if (widget.item.sousCategorie.isNotEmpty)
                    Text(
                      'Sous-catégorie: ${widget.item.sousCategorie}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélection de la quantité
            Text(
              'Quantité:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                // Bouton moins
                IconButton(
                  onPressed: quantity > 1 ? () {
                    setState(() {
                      quantity--;
                    });
                  } : null,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: quantity > 1 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  ),
                ),
                
                // Affichage de la quantité
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Bouton plus
                IconButton(
                  onPressed: quantity < 100 ? () {
                    setState(() {
                      quantity++;
                    });
                  } : null,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: quantity < 100 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  ),
                ),
                
                const Spacer(),
                
                // Slider pour la quantité
                Expanded(
                  child: Slider(
                    value: quantity.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: quantity.toString(),
                    onChanged: (value) {
                      setState(() {
                        quantity = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
            
            // Options spécifiques pour la page son (amplificateur)
            if (widget.showAmplifierDialog) ...[
              const SizedBox(height: 16),
              Text(
                'Amplificateur:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedAmplifier,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: amplifierOptions.map((String amplifier) {
                  return DropdownMenuItem<String>(
                    value: amplifier,
                    child: Text(amplifier),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAmplifier = newValue;
                  });
                },
              ),
            ],
            
            // Options spécifiques pour la page lumière (mode DMX)
            if (widget.showDmxDialog) ...[
              const SizedBox(height: 16),
              Text(
                'Mode DMX:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDmxMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: dmxModeOptions.map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDmxMode = newValue;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(
              widget.item,
              quantity,
              amplifier: selectedAmplifier,
              dmxMode: selectedDmxMode,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'son':
        return Icons.volume_up;
      case 'vidéo':
        return Icons.videocam;
      case 'lumière':
        return Icons.lightbulb;
      case 'structure':
        return Icons.build;
      case 'électricité':
        return Icons.electrical_services;
      default:
        return Icons.inventory;
    }
  }
}
