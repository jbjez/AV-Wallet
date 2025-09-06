import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/translation_service.dart';
import '../services/backup_service.dart';

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

  Future<void> _createBackup(BuildContext context) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await BackupService.createBackup();

      Navigator.of(context).pop(); // Ferme le dialogue de chargement

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Sauvegarde créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Ferme le dialogue de chargement
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Erreur lors de la création de la sauvegarde: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restaurer une sauvegarde'),
          content: const Text(
            'Cette action remplacera toutes les données actuelles. '
            'Voulez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Ferme le dialogue de confirmation

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // TODO: Implémenter la sélection du fichier de sauvegarde
                  const backupPath = 'path/to/backup/file';
                  await BackupService.restoreBackup(backupPath);

                  Navigator.of(context)
                      .pop(); // Ferme le dialogue de chargement

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Restauration effectuée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context)
                      .pop(); // Ferme le dialogue de chargement
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Erreur'),
                      content: Text('Erreur lors de la restauration: $e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Erreur: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(translationServiceProvider);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        color: Theme.of(context).brightness == Brightness.light 
            ? AppColors.darkBackground // Fond sombre en mode jour
            : Colors.transparent, // Transparent en mode sombre
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Partie gauche : Bouton retour et titre
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  if (customIcon != null)
                    customIcon!
                  else if (pageIcon != null)
                    Icon(pageIcon, color: Colors.white, size: 24),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                ],
              ),
            ),
            // Partie centrale : Logo
            Expanded(
              flex: 3,
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(128),
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Partie droite : Login et drapeau
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.person, color: Colors.white),
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
                          // TODO: Naviguer vers la page des presets
                          break;
                        case 'logout':
                          // TODO: Implémenter la déconnexion globale si besoin
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'account',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 20),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.loginMenu_accountSettings),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'presets',
                        child: Row(
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.loginMenu_myProjects),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.loginMenu_logout),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implémenter la logique de changement de langue
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        _getFlagAsset(currentLocale),
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
