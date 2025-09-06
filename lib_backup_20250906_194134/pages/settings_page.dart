import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/reset_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final isDarkMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(languageProvider.notifier).setLanguage(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              isDarkMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            title: Text(loc.theme),
            trailing: Switch(
              value: isDarkMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          
          // Section Reset
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Réinitialisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: Text(loc.resetUserData),
            subtitle: Text(loc.resetUserDataDescription),
            onTap: () => _showResetUserDataDialog(context, ref),
          ),
          
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: Text(loc.resetApp),
            subtitle: Text(loc.resetAppDescription),
            onTap: () => _showResetAppDialog(context, ref),
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.signOut),
            onTap: () async {
              try {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/sign-in');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Affiche le dialogue de confirmation pour le reset des données utilisateur
  void _showResetUserDataDialog(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.resetConfirmTitle),
          content: Text(loc.resetUserDataConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performUserDataReset(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(loc.confirm),
            ),
          ],
        );
      },
    );
  }

  /// Affiche le dialogue de confirmation pour le reset complet de l'app
  void _showResetAppDialog(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.resetConfirmTitle),
          content: Text(loc.resetConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performCompleteReset(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(loc.confirm),
            ),
          ],
        );
      },
    );
  }

  /// Effectue le reset des données utilisateur
  Future<void> _performUserDataReset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Réinitialisation en cours...'),
              ],
            ),
          );
        },
      );

      // Effectuer le reset
      await ResetService.performUserDataReset();
      
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.resetComplete),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.resetError}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Effectue le reset complet de l'application
  Future<void> _performCompleteReset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Réinitialisation complète en cours...'),
              ],
            ),
          );
        },
      );

      // Effectuer le reset complet
      await ResetService.performCompleteReset();
      
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.resetComplete),
            backgroundColor: Colors.green,
          ),
        );
        
        // Rediriger vers la page de connexion
        Navigator.of(context).pushReplacementNamed('/sign-in');
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.resetError}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
