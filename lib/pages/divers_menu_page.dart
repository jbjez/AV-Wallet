// lib/pages/divers_menu_page.dart
import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/speedtest_webview.dart';
import '../widgets/uniform_bottom_nav_bar.dart';

class DiversMenuPage extends StatefulWidget {
  const DiversMenuPage({super.key});

  @override
  State<DiversMenuPage> createState() => _DiversMenuPageState();
}

class _DiversMenuPageState extends State<DiversMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Deux onglets mais sans swipe
  }







  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.more_horiz,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.15,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue[300]!
                                    : const Color(0xFF0A1128),
                                width: 2,
                              ),
                            ),
                          ),
                          child: TabBar(
                            dividerColor: Colors.transparent, // Supprime la ligne de séparation
                            labelColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
                                : const Color(0xFF0A1128),  // Bleu nuit en mode jour
                            unselectedLabelColor: Colors.white70, // Blanc transparent pour les onglets non sélectionnés
                            labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            indicatorColor: Colors.transparent, // Supprime l'indicateur de sélection
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.network_check, size: 14),
                                    SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        AppLocalizations.of(context)!.bandwidth_test_title,
                                        style: TextStyle(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(icon: Icon(Icons.calculate)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(), // Désactive le swipe
                            children: [
                              _buildBandePassante(),
                              _buildCalculatrice(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: UniformBottomNavBar(currentIndex: 6),
    );
  }

  Widget _buildBandePassante() {
    return const SpeedtestWebView();
  }

  Widget _buildCalculatrice() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Calculatrice',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

