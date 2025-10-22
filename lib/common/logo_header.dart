import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final String title;
  const LogoHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/home');
          },
          child: Image.asset('assets/logo2.png', height: 51), // Réduit de 15% (60 * 0.85 = 51)
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 24, color: Colors.white)),
      ],
    );
  }
}
