import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/catalogue_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/usage_provider.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'settings_page.dart';
import 'sign_in_page.dart';

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
    // Forcer le chargement du catalogue au démarrage de la HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(catalogueProvider.notifier).loadCatalogue();
    });
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SignInPage(isDialog: true);
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
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
              leading: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    currentTheme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey<bool>(currentTheme == ThemeMode.dark),
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
              actions: [
                // Bouton de test pour la restauration du catalogue
                IconButton(
                  onPressed: () async {
                    try {
                      // Afficher un dialogue de chargement
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AlertDialog(
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Restauration du catalogue...'),
                            ],
                          ),
                        ),
                      );

                      // Forcer la restauration
                      await ref.read(catalogueProvider.notifier).loadCatalogue();
                      
                      // Fermer le dialogue
                      if (mounted) Navigator.of(context).pop();
                      
                      // Afficher le résultat
                      final items = ref.read(catalogueProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Catalogue: ${items.length} produits'),
                            backgroundColor: items.isNotEmpty ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.of(context).pop(); // Fermer le dialogue
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  tooltip: 'Recharger le catalogue',
                ),
                // Bouton de debug pour la migration SON
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/debug-son');
                  },
                  icon: const Icon(Icons.bug_report, color: Colors.orange, size: 20),
                  tooltip: 'Debug Migration SON',
                ),
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
                        Navigator.pushNamed(context, '/project-selection');
                        break;
                      case 'logout':
                        final prefs = await SharedPreferences.getInstance();
                        final authService = AuthService(prefs);
                        await authService.signOut();
                        if (mounted) {
                          _showLoginDialog();
                        }
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
                          Text('Utilisation: ${ref.watch(usageProvider).remainingUsage}', 
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
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                          child: Image.asset('assets/Logo2.png', height: 100),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bouton Catalogue
                      GestureDetector(
                        onTap: () => _navigateTo(const CataloguePage()),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            color: darkBlue.withOpacity(0.5),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : darkBlue, 
                              width: 2
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.category, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                loc.catalogAccess,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Grille des 6 icônes
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.5),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : darkBlue, 
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
                                  icon: Icons.wifi,
                                  label: loc.networkMenu,
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
}
