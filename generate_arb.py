#!/usr/bin/env python3
import re
import os

# Lire les clés de localisation
keys = set()
with open('/tmp/localization_keys.txt', 'r') as f:
    for line in f:
        # Extraire juste la clé (après le dernier :)
        key = line.strip().split(':')[-1]
        if key:
            keys.add(key)

# Créer le fichier app_fr.arb
with open('lib/l10n/app_fr.arb', 'w', encoding='utf-8') as f:
    f.write('{\n')
    f.write('  "@@locale": "fr",\n')
    f.write('  "@@context": "AV Wallet",\n')
    
    for i, key in enumerate(sorted(keys)):
        # Générer une valeur par défaut lisible
        value = key.replace('_', ' ').replace('Page', ' Page').replace('Widget', ' Widget')
        value = value.replace('dmx', 'DMX').replace('ar', 'AR').replace('nav', 'Navigation')
        value = value.title()
        
        f.write(f'  "{key}": "{value}"')
        if i < len(keys) - 1:
            f.write(',')
        f.write('\n')
    
    f.write('}\n')

# Créer le fichier app_en.arb
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.write('{\n')
    f.write('  "@@locale": "en",\n')
    f.write('  "@@context": "AV Wallet",\n')
    
    for i, key in enumerate(sorted(keys)):
        # Générer une valeur par défaut lisible en anglais
        value = key.replace('_', ' ').replace('Page', ' Page').replace('Widget', ' Widget')
        value = value.replace('dmx', 'DMX').replace('ar', 'AR').replace('nav', 'Navigation')
        value = value.title()
        
        f.write(f'  "{key}": "{value}"')
        if i < len(keys) - 1:
            f.write(',')
        f.write('\n')
    
    f.write('}\n')

print(f"Généré {len(keys)} clés de localisation dans app_fr.arb et app_en.arb")
