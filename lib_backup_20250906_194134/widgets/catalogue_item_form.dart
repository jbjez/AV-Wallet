import 'package:flutter/material.dart';
import '../models/catalogue_item.dart';

class CatalogueItemForm extends StatefulWidget {
  final CatalogueItem? item;

  const CatalogueItemForm({super.key, this.item});

  @override
  State<CatalogueItemForm> createState() => _CatalogueItemFormState();
}

class _CatalogueItemFormState extends State<CatalogueItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categorieController;
  late TextEditingController _sousCategorieController;
  late TextEditingController _marqueController;
  late TextEditingController _produitController;
  late TextEditingController _dimensionsController;
  late TextEditingController _poidsController;
  late TextEditingController _consoController;
  late TextEditingController _resolutionDalleController;
  late TextEditingController _angleController;
  late TextEditingController _luxController;
  late TextEditingController _lumensController;
  late TextEditingController _definitionController;
  late TextEditingController _dmxMaxController;
  late TextEditingController _dmxMiniController;
  late TextEditingController _resolutionController;
  late TextEditingController _pitchController;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _categorieController =
        TextEditingController(text: widget.item?.categorie ?? '');
    _sousCategorieController =
        TextEditingController(text: widget.item?.sousCategorie ?? '');
    _marqueController = TextEditingController(text: widget.item?.marque ?? '');
    _produitController =
        TextEditingController(text: widget.item?.produit ?? '');
    _dimensionsController =
        TextEditingController(text: widget.item?.dimensions ?? '');
    _poidsController = TextEditingController(text: widget.item?.poids ?? '');
    _consoController = TextEditingController(text: widget.item?.conso ?? '');
    _resolutionDalleController =
        TextEditingController(text: widget.item?.resolutionDalle ?? '');
    _angleController = TextEditingController(text: widget.item?.angle ?? '');
    _luxController = TextEditingController(text: widget.item?.lux ?? '');
    _lumensController = TextEditingController(text: widget.item?.lumens ?? '');
    _definitionController =
        TextEditingController(text: widget.item?.definition ?? '');
    _dmxMaxController = TextEditingController(text: widget.item?.dmxMax ?? '');
    _dmxMiniController =
        TextEditingController(text: widget.item?.dmxMini ?? '');
    _resolutionController =
        TextEditingController(text: widget.item?.resolution ?? '');
    _pitchController = TextEditingController(text: widget.item?.pitch ?? '');
    _imageUrl = widget.item?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categorieController.dispose();
    _sousCategorieController.dispose();
    _marqueController.dispose();
    _produitController.dispose();
    _dimensionsController.dispose();
    _poidsController.dispose();
    _consoController.dispose();
    _resolutionDalleController.dispose();
    _angleController.dispose();
    _luxController.dispose();
    _lumensController.dispose();
    _definitionController.dispose();
    _dmxMaxController.dispose();
    _dmxMiniController.dispose();
    _resolutionController.dispose();
    _pitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.item == null ? 'Ajouter un élément' : 'Modifier un élément'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _categorieController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une catégorie';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sousCategorieController,
                decoration: const InputDecoration(labelText: 'Sous-catégorie'),
              ),
              TextFormField(
                controller: _marqueController,
                decoration: const InputDecoration(labelText: 'Marque'),
              ),
              TextFormField(
                controller: _produitController,
                decoration: const InputDecoration(labelText: 'Produit'),
              ),
              TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(labelText: 'Dimensions'),
              ),
              TextFormField(
                controller: _poidsController,
                decoration: const InputDecoration(labelText: 'Poids'),
              ),
              TextFormField(
                controller: _consoController,
                decoration: const InputDecoration(labelText: 'Consommation'),
              ),
              TextFormField(
                controller: _resolutionDalleController,
                decoration:
                    const InputDecoration(labelText: 'Résolution dalle'),
              ),
              TextFormField(
                controller: _angleController,
                decoration: const InputDecoration(labelText: 'Angle'),
              ),
              TextFormField(
                controller: _luxController,
                decoration: const InputDecoration(labelText: 'Lux'),
              ),
              TextFormField(
                controller: _lumensController,
                decoration: const InputDecoration(labelText: 'Lumens'),
              ),
              TextFormField(
                controller: _definitionController,
                decoration: const InputDecoration(labelText: 'Définition'),
              ),
              TextFormField(
                controller: _dmxMaxController,
                decoration: const InputDecoration(labelText: 'DMX Max'),
              ),
              TextFormField(
                controller: _dmxMiniController,
                decoration: const InputDecoration(labelText: 'DMX Mini'),
              ),
              TextFormField(
                controller: _resolutionController,
                decoration: const InputDecoration(labelText: 'Résolution'),
              ),
              TextFormField(
                controller: _pitchController,
                decoration: const InputDecoration(labelText: 'Pitch'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final item = CatalogueItem(
                id: widget.item?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                description: _descriptionController.text,
                categorie: _categorieController.text,
                sousCategorie: _sousCategorieController.text,
                marque: _marqueController.text,
                produit: _produitController.text,
                dimensions: _dimensionsController.text,
                poids: _poidsController.text,
                conso: _consoController.text,
                imageUrl: _imageUrl,
                resolutionDalle: _resolutionDalleController.text,
                angle: _angleController.text,
                lux: _luxController.text,
                lumens: _lumensController.text,
                definition: _definitionController.text,
                dmxMax: _dmxMaxController.text,
                dmxMini: _dmxMiniController.text,
                resolution: _resolutionController.text,
                pitch: _pitchController.text,
                optiques: widget.item?.optiques,
              );
              Navigator.of(context).pop(item);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
