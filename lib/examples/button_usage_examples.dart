import 'package:flutter/material.dart';
import '../widgets/action_button.dart';
import '../theme/button_styles.dart';

/// Exemples d'utilisation des styles de boutons et widgets personnalisés
class ButtonUsageExamples extends StatelessWidget {
  const ButtonUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemples de Boutons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exemple 1: Boutons d'action standard
            const Text(
              '1. Boutons d\'action standard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ActionButtonRow(
              buttons: [
                ActionButton.photo(
                  onPressed: () => print('Photo pressed'),
                ),
                ActionButton.calculate(
                  onPressed: () => print('Calculate pressed'),
                ),
                ActionButton.reset(
                  onPressed: () => print('Reset pressed'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exemple 2: Boutons avec texte
            const Text(
              '2. Boutons avec texte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ActionButtonRow(
              buttons: [
                ActionButton.photo(
                  text: 'Photo',
                  onPressed: () => print('Photo pressed'),
                ),
                ActionButton.calculate(
                  text: 'Calculer',
                  onPressed: () => print('Calculate pressed'),
                ),
                ActionButton.reset(
                  text: 'Reset',
                  onPressed: () => print('Reset pressed'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exemple 3: Boutons avec styles personnalisés
            const Text(
              '3. Boutons avec styles personnalisés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ActionButtonRow(
              buttons: [
                ActionButton.photo(
                  text: 'Photo',
                  style: ButtonStyles.secondaryActionButtonStyle,
                  iconSize: 20,
                  onPressed: () => print('Photo pressed'),
                ),
                ActionButton.calculate(
                  text: 'Calculer',
                  style: ButtonStyles.confirmButtonStyle,
                  onPressed: () => print('Calculate pressed'),
                ),
                ActionButton.reset(
                  text: 'Reset',
                  style: ButtonStyles.cancelButtonStyle,
                  onPressed: () => print('Reset pressed'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exemple 4: Boutons individuels
            const Text(
              '4. Boutons individuels',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton.settings(
                  onPressed: () => print('Settings pressed'),
                ),
                ActionButton.save(
                  onPressed: () => print('Save pressed'),
                ),
                ActionButton.export(
                  onPressed: () => print('Export pressed'),
                ),
                ActionButton(
                  icon: Icons.add,
                  text: 'Ajouter',
                  onPressed: () => print('Add pressed'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exemple 5: Boutons désactivés
            const Text(
              '5. Boutons désactivés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ActionButtonRow(
              buttons: [
                ActionButton.photo(
                  text: 'Photo',
                  enabled: false,
                  onPressed: () => print('This won\'t be called'),
                ),
                ActionButton.calculate(
                  text: 'Calculer',
                  enabled: false,
                  onPressed: () => print('This won\'t be called'),
                ),
                ActionButton.reset(
                  text: 'Reset',
                  enabled: false,
                  onPressed: () => print('This won\'t be called'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exemple 6: Utilisation des styles directement
            const Text(
              '6. Utilisation des styles directement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => print('Custom button 1'),
                  style: ButtonStyles.actionButtonStyle,
                  child: const Text('Bouton 1'),
                ),
                ElevatedButton(
                  onPressed: () => print('Custom button 2'),
                  style: ButtonStyles.navigationButtonStyle,
                  child: const Text('Bouton 2'),
                ),
                ElevatedButton(
                  onPressed: () => print('Custom button 3'),
                  style: ButtonStyles.confirmButtonStyle,
                  child: const Text('Bouton 3'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




