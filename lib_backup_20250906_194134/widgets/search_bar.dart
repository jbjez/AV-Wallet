import 'package:flutter/material.dart';

/// Widget réutilisable pour une barre de recherche
class SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchBar({
    super.key,
    this.hint = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
