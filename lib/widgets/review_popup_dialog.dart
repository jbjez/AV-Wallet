import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog d'avis pour les utilisateurs premium
class ReviewPopupDialog extends StatelessWidget {
  final String username;
  final VoidCallback onContact;
  final VoidCallback onContinue;

  const ReviewPopupDialog({
    super.key,
    required this.username,
    required this.onContact,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: const Color(0xFF0A1128), // Fond foncé
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF455A64), // Bleu-gris foncé
          width: 2,
        ),
      ),
      title: Center(
        child: Text(
          '${loc.review_popup_title}, $username',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.85,
          maxHeight: screenSize.height * 0.4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                loc.review_popup_message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Ouvrir l'email avec le lien contact@avwallet.fr
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'contact@avwallet.fr',
                        query: 'subject=Feedback AV Wallet',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      loc.review_popup_contact,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      loc.review_popup_continue,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
