import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/catalogue_recovery_service.dart';
import '../providers/catalogue_provider.dart';

class CatalogueRecoveryPage extends ConsumerStatefulWidget {
  const CatalogueRecoveryPage({super.key});

  @override
  ConsumerState<CatalogueRecoveryPage> createState() => _CatalogueRecoveryPageState();
}

class _CatalogueRecoveryPageState extends ConsumerState<CatalogueRecoveryPage> {
  bool _isRecovering = false;
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await CatalogueRecoveryService.getCatalogueStatus();
    setState(() {
      _status = status;
    });
  }

  Future<void> _forceRecovery() async {
    setState(() {
      _isRecovering = true;
    });

    try {
      // Forcer la récupération
      await CatalogueRecoveryService.forceReloadCatalogue();
      
      // Recharger le provider
      ref.invalidate(catalogueProvider);
      await ref.read(catalogueProvider.notifier).loadCatalogue();
      
      // Vérifier le nouveau statut
      await _checkStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catalogue récupéré avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRecovering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récupération Catalogue'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'État du Catalogue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_status != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total d\'items: ${_status!['totalItems']}'),
                      const SizedBox(height: 8),
                      Text('Catégories: ${_status!['categories'].join(', ')}'),
                      const SizedBox(height: 8),
                      Text('Marques: ${_status!['brands'].length}'),
                      const SizedBox(height: 8),
                      Text('Vide: ${_status!['isEmpty'] ? 'OUI' : 'NON'}'),
                      if (_status!['error'] != null) ...[
                        const SizedBox(height: 8),
                        Text('Erreur: ${_status!['error']}', 
                             style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRecovering ? null : _forceRecovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isRecovering
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('FORCER LA RÉCUPÉRATION'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkStatus,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Vérifier l\'état'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/catalogue');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Aller au Catalogue'),
            ),
          ],
        ),
      ),
    );
  }
}
