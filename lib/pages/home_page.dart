import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/usage_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/preset_provider.dart';
import '../providers/imported_photos_provider.dart';
import '../services/freemium_access_service.dart';
import '../services/premium_email_service.dart';
import '../theme/colors.dart';

import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'settings_page.dart';
import 'sign_in_page.dart';
import '../widgets/preset_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const darkBlue = Color(0xFF0A1128);

  @override
  void initState() {
    super.initState();
    // Chargement différé pour améliorer les performances
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charger le catalogue de manière asynchrone pour éviter de bloquer l'UI
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ref.read(catalogueProvider.notifier).loadCatalogue();
        }
      });
      
      // Initialiser le ProjectProvider de manière asynchrone
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          ref.read(projectProvider.notifier);
        }
      });
    });
  }

  String _getTranslatedProjectName(String projectName) {
    final loc = AppLocalizations.of(context)!;
    
    switch (projectName) {
      case 'default_project_1':
        return loc.defaultProject1;
      case 'default_project_2':
        return loc.defaultProject2;
      case 'default_project_3':
        return loc.defaultProject3;
      default:
        return projectName;
    }
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Transition fluide avec fade et slide
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        settings: const RouteSettings(name: '/settings'),
      ),
    );
  }

  void _loadProject() async {
    // Vérifier l'accès aux projets (premium uniquement)
    final hasAccess = await FreemiumAccessService.canAccessProjects(context, ref);
    if (!hasAccess) {
      return; // Le dialog d'accès refusé est affiché automatiquement
    }
    
    final projectState = ref.read(projectProvider);
    
    if (projectState.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.no_projects_available),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loadProject),
        content: Container(
          width: double.maxFinite,
          height: 400, // Hauteur fixe pour permettre le scroll
          decoration: BoxDecoration(
            color: const Color(0xFF0A1128).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.loadProject_selectProject,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: projectState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                            ...projectState.projects.asMap().entries.map((entry) {
                        final index = entry.key;
                        final project = entry.value;
                              final isCurrentProject = projectState.selectedProjectIndex == index;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCurrentProject ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentProject ? Colors.blue : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              _getTranslatedProjectName(project.name),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isCurrentProject ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${project.presets.length} presets',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                            ),
                            trailing: isCurrentProject
                              ? Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 24,
                                )
                              : null,
                            onTap: () {
                              // Charger le projet sélectionné
                              ref.read(projectProvider.notifier).selectProject(index);
                              ref.read(presetProvider.notifier).loadPresetsFromProject(project);
                              
                              // Nettoyer les photos du projet précédent
                              ref.read(importedPhotosProvider.notifier).clearProjectPhotos(project.name);
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.project_loaded(_getTranslatedProjectName(project.name))),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showWelcomeDialogIfNeeded() async {
    try {
      print('🎉 HOMEPAGE: Vérification du popup de bienvenue');
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      print('🔍 HOMEPAGE: Auth state: ${authState.isAuthenticated}');
      print('🔍 HOMEPAGE: User: ${user?.email}');
      
      if (user?.email != null) {
        print('👤 HOMEPAGE: Utilisateur trouvé: ${user?.email}');
        final usageState = ref.read(usageProvider);
        
        print('📊 HOMEPAGE: Usage state: ${usageState.remainingUsage}');
        
        // Vérifier si l'utilisateur est premium
        final isPremium = await PremiumEmailService.isPremiumEmail(user!.email!);
        print('💎 HOMEPAGE: Is premium: $isPremium');
        
        if (!mounted) return;
        
        // Afficher le popup de bienvenue approprié
        if (isPremium) {
          _showPremiumWelcomeDialog();
        } else {
          _showStandardWelcomeDialog();
        }
      }
    } catch (e) {
      print('❌ HOMEPAGE: Erreur lors de l\'affichage du popup de bienvenue: $e');
    }
  }

  void _showPremiumWelcomeDialog() {
    final authState = ref.read(authProvider);
    final usageState = ref.read(usageProvider);
    final userName = _getUserDisplayName(authState.user);
    final loc = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1128),
          title: Text(
            loc.premium_welcome_title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName.isNotEmpty 
                  ? 'Bienvenue sur AV Wallet, $userName'
                  : 'Bienvenue sur AV Wallet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Félicitations ! Vous bénéficiez maintenant de l'accès premium à AVWallet avec toutes les fonctionnalités avancées.",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.premium_benefits_title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(loc.premium_benefit_unlimited, Icons.all_inclusive),
                    _buildBenefitItem(loc.premium_benefit_priority, Icons.priority_high),
                    _buildBenefitItem(loc.premium_benefit_support, Icons.support_agent),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                loc.premium_welcome_later,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Action pour explorer premium
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                loc.premium_welcome_continue,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStandardWelcomeDialog() {
    final authState = ref.read(authProvider);
    final usageState = ref.read(usageProvider);
    final userName = _getUserDisplayName(authState.user);
    final loc = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1128),
          title: Text(
            'Bienvenue sur AV Wallet',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName.isNotEmpty 
                  ? 'Bienvenue sur AV Wallet, $userName'
                  : 'Bienvenue sur AV Wallet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                loc.standard_welcome_usage_remaining(usageState.remainingUsage),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                loc.standard_welcome_continue,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getUserDisplayName(dynamic user) {
    if (user == null) return '';
    
    // Utiliser directement le displayName de l'AppUser
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    
    // Fallback sur l'email si pas de nom disponible
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      // Extraire la partie avant @ de l'email et la formater
      final emailName = email.split('@').first;
      // Capitaliser la première lettre
      return emailName.isNotEmpty 
          ? emailName[0].toUpperCase() + emailName.substring(1).toLowerCase()
          : emailName;
    }
    
    return '';
  }



  @override
  Widget build(BuildContext context) {
          final currentLocale = ref.watch(localeProvider);

    return Localizations.override(
      context: context,
      locale: currentLocale,
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              leading: const SizedBox.shrink(),
              actions: [
                // Dropdown de langue avec contrainte de taille
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 60),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Locale>(
                      icon: const Icon(Icons.language, color: Colors.white, size: 16),
                      value: currentLocale,
                      isDense: true,
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          ref.read(localeProvider.notifier).setLocale(newLocale);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: Locale('fr'),
                          child: Image(image: AssetImage('assets/flag_fr_48.png'), height: 20),
                        ),
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Image(image: AssetImage('assets/flag_en_48.png'), height: 20),
                        ),
                        DropdownMenuItem(
                          value: Locale('it'),
                          child: Image(image: AssetImage('assets/flag_it_48.png'), height: 20),
                        ),
                        DropdownMenuItem(
                          value: Locale('es'),
                          child: Image(image: AssetImage('assets/flag_es_48.png'), height: 20),
                        ),
                        DropdownMenuItem(
                          value: Locale('de'),
                          child: Image(image: AssetImage('assets/flag_de_48.png'), height: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.person, color: Colors.white, size: 24),
                  onSelected: (value) async {
                    switch (value) {
                      case 'account':
                        _navigateTo(const SettingsPage());
                        break;
                      case 'presets':
                        _loadProject();
                        break;
                      case 'logout':
                        _navigateTo(const SettingsPage());
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    // Indicateur d'utilisation (étoile 5) dans le menu
                    PopupMenuItem<String>(
                      value: 'usage',
                      enabled: false,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber),
                          SizedBox(width: 6),
                          Text('${loc.loginMenu_usage}: ${ref.watch(usageProvider).remainingUsage}', 
                               style: TextStyle(fontSize: 10, color: Colors.white70)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'account',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings, size: 18),
                          SizedBox(width: 6),
                          Text(loc.loginMenu_accountSettings, 
                               style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'presets',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save, size: 18),
                          SizedBox(width: 6),
                          Text(loc.loginMenu_myProjects, 
                               style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 6),
                          Text(loc.loginMenu_logout, 
                               style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Stack(
              children: [
                Opacity(
                  opacity: 0.1,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.appBarColor.withValues(alpha: 0.5),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : darkBlue, 
                              width: 2
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset('assets/logo2.png', height: 100),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Ligne bleue recourbée (comme dans les autres pages)
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CataloguePage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.lightBlue[300]!
                                      : const Color(0xFF0A1128),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc.catalogAccess,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.lightBlue[300]!
                                        : const Color(0xFF0A1128),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // PresetWidget entre la ligne bleue et le cadre des 6 icônes
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: const PresetWidget(
                          loadOnInit: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Grille des 6 icônes
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.5),
                          border: Border.all(
                            color: Colors.white,
                            width: 2
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Première ligne (3 icônes)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMenuButton(
                                  icon: Icons.lightbulb,
                                  label: loc.lightMenu,
                                  onTap: () => _navigateTo(const LightMenuPage()),
                                ),
                                _buildMenuButton(
                                  icon: Icons.precision_manufacturing,
                                  label: loc.structureMenu,
                                  onTap: () => _navigateTo(const StructureMenuPage()),
                                ),
                                _buildMenuButton(
                                  icon: Icons.volume_up,
                                  label: loc.soundMenu,
                                  onTap: () => _navigateTo(const SoundMenuPage()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Deuxième ligne (3 icônes)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMenuButton(
                                  icon: Icons.videocam,
                                  label: loc.videoMenu,
                                  onTap: () => _navigateTo(const VideoMenuPage()),
                                ),
                                _buildMenuButton(
                                  icon: Icons.bolt,
                                  label: loc.electricityMenu,
                                  onTap: () => _navigateTo(const ElectriciteMenuPage()),
                                ),
                                _buildMenuButton(
                                  icon: Icons.more_horiz,
                                  label: 'Divers',
                                  onTap: () => _navigateTo(const DiversMenuPage()),
                                ),
                              ],
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
          );
        },
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80, // Taille fixe en largeur
          height: 80, // Taille fixe en hauteur
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
