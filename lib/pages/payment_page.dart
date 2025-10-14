import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/secure_usage_service.dart';
import '../services/device_fingerprint_service.dart';
import '../config/supabase_config.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'real_stripe_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _supabase = Supabase.instance.client;
  String? _errorMessage;
  String? _successMessage;
  
  // Plans d'abonnement - seront générés avec les traductions
  List<SubscriptionPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _initializePlans();
  }

  void _initializePlans() {
    // Les plans seront initialisés dans build() avec les traductions
  }

  List<SubscriptionPlan> _getPlans(AppLocalizations loc) {
    return [
      SubscriptionPlan(
        id: 'monthly',
        name: loc.paymentPage_monthlyPlan,
        price: 2.49,
        currency: 'EUR',
        interval: 'mois', // Utiliser directement le texte français
        description: 'Accès complet à toutes les fonctionnalités',
        features: [
          'Catalogue complet',
          'Projets et presets',
          'Export PDF/Excel',
          'Support prioritaire',
          'Mises à jour automatiques'
        ],
        isPopular: false,
      ),
      SubscriptionPlan(
        id: 'yearly',
        name: loc.paymentPage_yearlyPlan,
        price: 19.99,
        currency: 'EUR',
        interval: 'an', // Utiliser directement le texte français
        description: 'Économisez 33% avec l\'abonnement annuel',
        features: [
          'Catalogue complet',
          'Projets et presets',
          'Export PDF/Excel',
          'Support prioritaire',
          'Mises à jour automatiques',
          'Économie de 33%'
        ],
        isPopular: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.payment,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.15,
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
                // Titre Premium avec barre de soulignement
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue[300]!
                            : const Color(0xFF0A1128),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue[300]
                            : const Color(0xFF0A1128),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.subscription_premium,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.lightBlue[300]
                              : const Color(0xFF0A1128),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Center(
                          child: Text(
                            loc.subscription_description,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Plans d'abonnement
                        Text(
                          loc.subscription_choose_plan,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Grille des plans
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _getPlans(loc).length,
                          itemBuilder: (context, index) {
                            final plan = _getPlans(loc)[index];
                            return _buildPlanCard(plan, loc);
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Bouton d'essai gratuit
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startFreeTrial,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.lightBlue[300]
                                  : const Color(0xFF0A1128),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              loc.subscription_free_trial,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Informations de sécurité
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]?.withOpacity(0.3)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc.subscription_security,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.subscription_security_description,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Messages d'erreur/succès
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: const TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                                ),
                              ],
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
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: plan.isPopular 
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.lightBlue[300]?.withOpacity(0.2)
                : const Color(0xFF0A1128).withOpacity(0.1))
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]?.withOpacity(0.3)
                : Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: plan.isPopular 
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.lightBlue[300]!
                  : const Color(0xFF0A1128))
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 200, // Hauteur fixe pour aligner les boutons
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge populaire
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.lightBlue[300]
                        : const Color(0xFF0A1128),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    loc.subscription_popular,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              const SizedBox(height: 3),
              
              // Nom du plan
              Text(
                plan.name,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 2),
              
              // Description
              Text(
                plan.description,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 7,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Prix
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      '${plan.price.toStringAsFixed(2)} ${plan.currency}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    '/${plan.interval}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Fonctionnalités (limitées) - espace flexible
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plan.features.take(2).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 8,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 8), // Espacement entre fonctionnalités et bouton
              
              // Bouton d'abonnement - toujours en bas
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _subscribeToPlan(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.lightBlue[300]
                        : const Color(0xFF0A1128),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    loc.subscription_subscribe,
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startFreeTrial() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Démarrer l'essai gratuit
      final deviceId = await DeviceFingerprintService.instance.getDeviceId();
      final user = _supabase.auth.currentUser;
      
      // Créer un enregistrement d'essai gratuit
      final response = await _supabase.rpc('increment_usage', params: {
        'p_device_id': deviceId,
        'p_user_id': user?.id,
        'p_max_usage': 5, // 5 utilisations gratuites
      });

      if (response != null && response['success'] == true) {
        setState(() {
          _successMessage = 'Essai gratuit démarré !';
        });
        
        // Rediriger vers la page d'accueil après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du démarrage de l\'essai gratuit';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  Future<void> _subscribeToPlan(SubscriptionPlan plan) async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Rediriger vers la page de paiement Stripe
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RealStripePaymentPage(
            planId: plan.id,
            planName: plan.name,
            amount: (plan.price * 100).round(), // Convertir en centimes
            currency: plan.currency,
            interval: plan.interval,
          ),
        ),
      );
      
      // Si le paiement a réussi, afficher un message de succès
      if (result == true) {
        setState(() {
          _successMessage = 'Abonnement ${plan.name} activé avec succès !';
        });
        
        // Rediriger vers la page d'accueil après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'abonnement: $e';
      });
    }
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String interval;
  final String description;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.interval,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}
