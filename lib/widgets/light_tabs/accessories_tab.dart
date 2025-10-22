import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';

class LightAccessoriesTab extends StatefulWidget {
  const LightAccessoriesTab({super.key});

  @override
  State<LightAccessoriesTab> createState() => _LightAccessoriesTabState();
}

class _LightAccessoriesTabState extends State<LightAccessoriesTab> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.lightAccessories,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              loc.thisSectionWillBeDeveloped,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            
            _buildAccessoryItem(loc.trussesAndStructures, Icons.build),
            _buildAccessoryItem(loc.dmxCables, Icons.cable),
            _buildAccessoryItem(loc.connectors, Icons.link),
            _buildAccessoryItem(loc.protections, Icons.security),
            _buildAccessoryItem(loc.mountingTools, Icons.build),
            _buildAccessoryItem(loc.safetyAccessories, Icons.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
