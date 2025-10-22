import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/freemium_access_service.dart';

/// Widget pour les calculs basiques gratuits (sans catalogue)
class BasicCalculationWidget extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onCalculate;
  final bool requiresPremium;

  const BasicCalculationWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onCalculate,
    this.requiresPremium = false,
  });

  @override
  ConsumerState<BasicCalculationWidget> createState() => _BasicCalculationWidgetState();
}

class _BasicCalculationWidgetState extends ConsumerState<BasicCalculationWidget> {
  bool _isCalculating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF0A1128).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.requiresPremium ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.requiresPremium ? _showPremiumRequired : _handleCalculation,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.requiresPremium 
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.requiresPremium ? Colors.orange : Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.requiresPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'GRATUIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton d'action
              const SizedBox(width: 16),
              if (_isCalculating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
              else
                Icon(
                  widget.requiresPremium ? Icons.lock : Icons.play_arrow,
                  color: widget.requiresPremium ? Colors.orange : Colors.green,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCalculation() async {
    if (widget.requiresPremium) {
      await _showPremiumRequired();
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      // Vérifier l'accès aux calculs basiques (toujours autorisé)
      final hasAccess = await FreemiumAccessService.canUseBasicCalculations(context, ref);
      
      if (hasAccess) {
        // Exécuter le calcul
        widget.onCalculate();
        
        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.title} calculé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du calcul: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  Future<void> _showPremiumRequired() async {
    await FreemiumAccessService.canAccessProjects(context, ref);
  }
}

/// Widget pour afficher les calculs basiques disponibles
class BasicCalculationsList extends ConsumerWidget {
  const BasicCalculationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Calculs Basiques (Gratuits)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Calculs gratuits
        BasicCalculationWidget(
          title: 'Calcul de Puissance Simple',
          description: 'Calculer la puissance totale d\'un équipement',
          icon: Icons.flash_on,
          onCalculate: () => _showPowerCalculation(context),
        ),
        
        BasicCalculationWidget(
          title: 'Calcul de Poids Simple',
          description: 'Calculer le poids total d\'un équipement',
          icon: Icons.fitness_center,
          onCalculate: () => _showWeightCalculation(context),
        ),
        
        BasicCalculationWidget(
          title: 'Calcul de Distance',
          description: 'Calculer la distance entre deux points',
          icon: Icons.straighten,
          onCalculate: () => _showDistanceCalculation(context),
        ),
        
        const SizedBox(height: 20),
        
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Fonctionnalités Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Calculs premium
        BasicCalculationWidget(
          title: 'Catalogue Complet',
          description: 'Accès à tous les équipements du catalogue',
          icon: Icons.inventory_2,
          requiresPremium: true,
          onCalculate: () {},
        ),
        
        BasicCalculationWidget(
          title: 'Gestion de Projets',
          description: 'Sauvegarder et organiser vos calculs',
          icon: Icons.folder_special,
          requiresPremium: true,
          onCalculate: () {},
        ),
        
        BasicCalculationWidget(
          title: 'Export PDF',
          description: 'Exporter vos calculs en PDF',
          icon: Icons.file_download,
          requiresPremium: true,
          onCalculate: () {},
        ),
      ],
    );
  }

  void _showPowerCalculation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcul de Puissance'),
        content: const Text('Fonctionnalité de calcul de puissance basique (gratuite)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWeightCalculation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcul de Poids'),
        content: const Text('Fonctionnalité de calcul de poids basique (gratuite)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDistanceCalculation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcul de Distance'),
        content: const Text('Fonctionnalité de calcul de distance basique (gratuite)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
