import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../providers/preset_provider.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';

class CalculProjectTab extends ConsumerWidget {
  const CalculProjectTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preset = ref.watch(presetProvider.notifier).activePreset;
    final catalogueItems = ref.watch(catalogueProvider);

    if (preset == null) {
      return Center(
        child: Text(l10n.projectCalculationPage_noPresetSelected),
      );
    }

    // Calculate power consumption total
    final powerTotal = preset.items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0),
    );

    // Calculate weight total
    final weightTotal = preset.items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0),
    );

    // Calculate grand total (if needed - this combines both metrics)
    final grandTotal = powerTotal + weightTotal;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.projectCalculationPage_powerProject,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.projectCalculationPage_powerConsumption}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...preset.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${item.item.name}: ${item.item.conso}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                    const Divider(),
                    Text(
                      '${l10n.projectCalculationPage_total}: ${powerTotal.toStringAsFixed(2)} W',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.projectCalculationPage_weight}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...preset.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${item.item.name}: ${item.item.poids}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                    const Divider(),
                    Text(
                      '${l10n.projectCalculationPage_total}: ${weightTotal.toStringAsFixed(2)} kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.projectCalculationPage_globalTotal}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.projectCalculationPage_powerConsumption}: ${powerTotal.toStringAsFixed(2)} W',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${l10n.projectCalculationPage_weight}: ${weightTotal.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 