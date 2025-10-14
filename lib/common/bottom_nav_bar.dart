import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // TODO: Ajouter la navigation vers les autres pages
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Lumière'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Structure'),
        BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: 'Son'),
        BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Vidéo'),
        BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Électricité'),
        BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Réseau'),
      ],
    );
  }
}
