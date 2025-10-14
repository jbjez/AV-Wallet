import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translation_service.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider.notifier);
    final currentLocale = ref.watch(translationServiceProvider);

    return PopupMenuButton<String>(
      icon: Container(
        width: 32,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white70, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.asset(
            _getFlagAsset(currentLocale.languageCode),
            fit: BoxFit.cover,
          ),
        ),
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF0A1128),
      onSelected: (String languageCode) {
        translationService.setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) => [
        _buildLanguageItem('fr', 'Français', 'assets/flag_fr_48.png'),
        _buildLanguageItem('en', 'English', 'assets/flag_en_48.png'),
        _buildLanguageItem('es', 'Español', 'assets/flag_es_48.png'),
        _buildLanguageItem('it', 'Italiano', 'assets/flag_it_48.png'),
        _buildLanguageItem('de', 'Deutsch', 'assets/flag_de_48.png'),
      ],
    );
  }

  PopupMenuItem<String> _buildLanguageItem(String code, String name, String flagAsset) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white30, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                flagAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getFlagAsset(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'assets/flag_fr_48.png';
      case 'en':
        return 'assets/flag_en_48.png';
      case 'es':
        return 'assets/flag_es_48.png';
      case 'it':
        return 'assets/flag_it_48.png';
      case 'de':
        return 'assets/flag_de_48.png';
      default:
        return 'assets/flag_fr_48.png';
    }
  }
}
