import 'package:flutter/material.dart';
import '../pages/catalogue_page.dart';
import '../pages/light_menu_page.dart';
import '../pages/structure_menu_page.dart';
import '../pages/sound_menu_page.dart';
import '../pages/video_menu_page.dart';
import '../pages/electricite_menu_page.dart';
import '../pages/divers_menu_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UniformBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const UniformBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.blueGrey[900],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: onTap ?? (index) {
        final pages = [
          const CataloguePage(),
          const LightMenuPage(),
          const StructureMenuPage(),
          const SoundMenuPage(),
          const VideoMenuPage(),
          const ElectriciteMenuPage(),
          const DiversMenuPage(),
        ];

        Offset beginOffset;
        if (index == 0 || index == 1) {
          beginOffset = const Offset(-1.0, 0.0);
        } else if (index == 5 || index == 6) {
          beginOffset = const Offset(1.0, 0.0);
        } else {
          beginOffset = Offset.zero;
        }

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => pages[index],
            transitionsBuilder: (_, animation, __, child) {
              if (beginOffset == Offset.zero) {
                return FadeTransition(opacity: animation, child: child);
              } else {
                final tween = Tween(begin: beginOffset, end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut));
                return SlideTransition(
                    position: animation.drive(tween), child: child);
              }
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.list, size: 20), label: loc.bottomNav_catalogue),
        BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb, size: 20), label: loc.bottomNav_light),
        BottomNavigationBarItem(
            icon: Image.asset('assets/truss_icon_grey.png',
                width: 20, height: 20),
            label: loc.bottomNav_structure),
        BottomNavigationBarItem(
            icon: const Icon(Icons.volume_up, size: 20), label: loc.bottomNav_sound),
        BottomNavigationBarItem(
            icon: const Icon(Icons.videocam, size: 20), label: loc.bottomNav_video),
        BottomNavigationBarItem(
            icon: const Icon(Icons.bolt, size: 20), label: loc.bottomNav_electricity),
        BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz, size: 20), label: loc.bottomNav_misc),
      ],
    );
  }
}
