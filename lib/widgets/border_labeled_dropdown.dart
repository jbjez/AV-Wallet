import 'package:flutter/material.dart';

class BorderLabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const BorderLabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Couleur de bordure adaptée au thème
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? const Color(0xFF00BFFF) : const Color(0xFF1E3A8A); // bleu ciel en mode nuit, bleu nuit en mode jour
    const fieldColor = Color(0xFF0A1128); // même couleur que le cadre principal
    const textColor = Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Champ avec bordure bleu ciel
        Container(
          decoration: BoxDecoration(
            color: fieldColor.withOpacity(0.3), // Même couleur et opacité que le cadre principal
            border: Border.all(color: borderColor, width: 1.0), // bordure plus fine
            borderRadius: BorderRadius.circular(8), // coins moins arrondis
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5), // padding vertical réduit de 4x (2x de plus)
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              style: const TextStyle(color: textColor, fontSize: 11), // police augmentée de 1pt
              icon: const Icon(Icons.arrow_drop_down, color: textColor, size: 16), // icône plus petite
              dropdownColor: fieldColor.withOpacity(0.3), // Même couleur et opacité que le cadre principal
            ),
          ),
        ),

        // Label posé sur la bordure
        Positioned(
          left: 8,
          top: -10, // Position ajustée (redescendu de 1 pixel)
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            // Suppression du fond du label
            child: Text(
              label,
              style: const TextStyle(
                color: textColor, // ← texte blanc
                fontWeight: FontWeight.normal, // Retire le gras
                fontSize: 9, // police augmentée de 1pt (8 + 1)
              ),
            ),
          ),
        ),
      ],
    );
  }
}
