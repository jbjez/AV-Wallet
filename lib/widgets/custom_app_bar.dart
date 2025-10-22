import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/usage_provider.dart';
import '../providers/project_provider.dart';
import '../providers/preset_provider.dart';
import '../providers/imported_photos_provider.dart';
import '../providers/auth_provider.dart';

import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../theme/colors.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? pageIcon;
  final Widget? customIcon;
  final bool showBackButton;
  final Function(String)? onSearchChanged;

  const CustomAppBar({
    super.key,
    this.title,
    this.pageIcon,
    this.customIcon,
    this.showBackButton = true,
    this.onSearchChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  String _getFlagAsset(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'assets/flag_fr_48.png';
      case 'en':
        return 'assets/flag_en_48.png';
      case 'it':
        return 'assets/flag_it_48.png';
      case 'de':
        return 'assets/flag_de_48.png';
      case 'es':
        return 'assets/flag_es_48.png';
      default:
        return 'assets/flag_fr_48.png';
    }
  }

  void _loadProject(BuildContext context, WidgetRef ref) async {
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
                            color: isCurrentProject 
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentProject ? Colors.blue : Colors.grey,
                              width: isCurrentProject ? 2 : 1,
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
                            onTap: () async {
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedProjectName(String projectName) {
    switch (projectName) {
      case 'default_project_1':
        return 'Projet 1';
      case 'default_project_2':
        return 'Projet 2';
      case 'default_project_3':
        return 'Projet 3';
      default:
        return projectName;
    }
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          AppLocalizations.of(context)!.settingsPage_signOutDialogTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsPage_signOutDialogContent,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_cancel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => _signOut(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.settingsPage_confirmSignOut, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    
    try {
      await ref.read(authProvider.notifier).signOut();
      
      // Nettoyer les données locales
      // Note: Les providers seront automatiquement réinitialisés lors de la reconnexion
      
      // Rediriger vers la page de connexion
      Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Déconnexion réussie'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Localizations.override(
      context: context,
      locale: currentLocale,
      child: Builder(
        builder: (context) {
          return PreferredSize(
            preferredSize: preferredSize,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.appBarColor, // Couleur originale
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Transform.translate(
                offset: const Offset(0, 20), // Déplace tous les éléments de 20px vers le bas
                child: Row(
                children: [
                  // Partie gauche : Bouton retour et icône de page (espace minimum)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showBackButton)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (showBackButton && (customIcon != null || pageIcon != null))
                        const SizedBox(width: 2),
                      if (customIcon != null)
                        customIcon!
                      else if (pageIcon != null)
                        Icon(pageIcon, color: Colors.white, size: 19),
                    ],
                  ),
                  
                  // Espacement supplémentaire de 20px entre l'icône de page et le logo
                  const SizedBox(width: 20),
                  
                  // Logo au centre (utilise Logo2)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        ),
                        child: Image.asset(
                          'assets/logo2.png', // Utilise Logo2 comme demandé
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  // Partie droite : Login et drapeau (espace minimum)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        // Menu Login avec icône d'utilisation (étoile 5)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.person, color: Colors.white, size: 24),
                          onSelected: (value) async {
                            switch (value) {
                              case 'account':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SettingsPage()),
                                );
                                break;
                              case 'presets':
                                _loadProject(context, ref);
                                break;
                              case 'logout':
                                _showSignOutDialog(context, ref);
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
                                       style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.grey[600] : Colors.black87)),
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
                                  Text(AppLocalizations.of(context)!.loginMenu_accountSettings, 
                                       style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
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
                                  Text(AppLocalizations.of(context)!.loginMenu_myProjects, 
                                       style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
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
                                  Text(AppLocalizations.of(context)!.loginMenu_logout, 
                                       style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 2), // Espace minimum entre login et drapeau
                        
                        // Drapeau de langue
                        PopupMenuButton<Locale>(
                          icon: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Image.asset(
                              _getFlagAsset(currentLocale),
                              width: 13,
                              height: 13,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onSelected: (Locale locale) {
                            ref.read(localeProvider.notifier).setLocale(locale);
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<Locale>(
                              value: const Locale('fr'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/flag_fr_48.png', width: 11, height: 11),
                                  const SizedBox(width: 6),
                                  Text('Français', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('en'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/flag_en_48.png', width: 11, height: 11),
                                  const SizedBox(width: 6),
                                  Text('English', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('de'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/flag_de_48.png', width: 11, height: 11),
                                  const SizedBox(width: 6),
                                  Text('Deutsch', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('es'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/flag_es_48.png', width: 11, height: 11),
                                  const SizedBox(width: 6),
                                  Text('Español', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('it'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/flag_it_48.png', width: 11, height: 11),
                                  const SizedBox(width: 6),
                                  Text('Italiano', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              ),
            ),
          );
        },
      ),
    );
  }
}