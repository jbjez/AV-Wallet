import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([super.locale = 'fr']);

  @override
  String get appTitle => 'AV Wallet';

  @override
  String get welcomeMessage => 'Bienvenue sur AV Wallet';

  @override
  String get catalogAccess => 'Accéder au catalogue';

  @override
  String get lightMenu => 'Lumière';

  @override
  String get structureMenu => 'Structure';

  @override
  String get soundMenu => 'Son';

  @override
  String get videoMenu => 'Vidéo';

  @override
  String get electricityMenu => 'Électricité';

  @override
  String get networkMenu => 'Réseau';

  @override
  String get lightPage_title => 'Lumière';

  @override
  String get structurePage_title => 'Structure';

  @override
  String get selectStructure => 'Sélectionner une structure';

  @override
  String distance_label(Object distance) {
    return '$distance m';
  }

  @override
  String charge_max(Object unit, Object value) {
    return 'Charge max: $value kg$unit';
  }

  @override
  String beam_weight(Object value) {
    return 'Poids de la poutre (hors charges): $value kg';
  }

  @override
  String max_deflection(Object value) {
    return 'Flèche maximale: $value mm';
  }

  @override
  String get deflection_rate => 'Taux de flèche pris en compte: 1/200';

  @override
  String get structurePage_selectCharge => 'Type de charge';

  @override
  String get soundPage_title => 'Son';

  @override
  String get soundPage_amplificationLA => 'Amplification LA';

  @override
  String get soundPage_delay => 'Delay';

  @override
  String get soundPage_decibelMeter => 'Sonomètre';

  @override
  String get soundPage_selectSpeaker => 'Sélectionner un haut-parleur';

  @override
  String get soundPage_selectedSpeakers => 'Haut-parleurs sélectionnés';

  @override
  String get soundPage_quantity => 'Quantité';

  @override
  String get soundPage_calculate => 'Calculer';

  @override
  String get soundPage_reset => 'Réinitialiser';

  @override
  String get soundPage_optimalConfig =>
      'Configuration d\'amplification recommandée';

  @override
  String get soundPage_noConfig =>
      'Aucune configuration optimale trouvée pour cette combinaison de haut-parleurs';

  @override
  String get soundPage_checkCompat => 'Veuillez vérifier les compatibilités';

  @override
  String get soundPage_addPreset => 'Ajouter un preset';

  @override
  String get soundPage_presetName => 'Nom du preset';

  @override
  String get soundPage_enterPresetName => 'Entrer le nom du preset';

  @override
  String get soundPage_save => 'Enregistrer';

  @override
  String get soundPage_cancel => 'Annuler';

  @override
  String get catalogPage_title => 'Catalogue';

  @override
  String get catalogPage_search => 'Rechercher';

  @override
  String get catalogPage_category => 'Catégorie';

  @override
  String get catalogPage_subCategory => 'Sous-catégorie';

  @override
  String get catalogPage_brand => 'Marque';

  @override
  String get catalogPage_product => 'Produit';

  @override
  String get catalogPage_addToCart => 'Ajouter au panier';

  @override
  String get catalogPage_quantity => 'Quantité';

  @override
  String get catalogPage_enterQuantity => 'Entrer la quantité';

  @override
  String get catalogPage_cart => 'Panier';

  @override
  String get catalogPage_emptyCart => 'Votre panier est vide';

  @override
  String get catalogPage_total => 'Total';

  @override
  String get catalogPage_checkout => 'Commander';

  @override
  String get catalogPage_clearCart => 'Vider le panier';

  @override
  String get catalogPage_remove => 'Supprimer';

  @override
  String get catalogPage_confirm => 'Confirmer';

  @override
  String get catalogPage_cancel => 'Annuler';

  @override
  String get catalogPage_weight => 'Poids';

  @override
  String get presetWidget_title => 'Presets';

  @override
  String get presetWidget_add => 'Ajouter un preset';

  @override
  String get presetWidget_edit => 'Modifier';

  @override
  String get presetWidget_delete => 'Supprimer';

  @override
  String get presetWidget_confirmDelete =>
      'Êtes-vous sûr de vouloir supprimer ce preset ?';

  @override
  String get presetWidget_yes => 'Oui';

  @override
  String get presetWidget_no => 'Non';

  @override
  String get projectCalculationPage_title => 'Calcul de projet';

  @override
  String get projectCalculationPage_powerProject => 'Projet puissance';

  @override
  String get projectCalculationPage_weightProject => 'Projet poids';

  @override
  String get projectCalculationPage_noPresetSelected =>
      'Aucun preset sélectionné';

  @override
  String get projectCalculationPage_powerConsumption =>
      'Consommation électrique';

  @override
  String get projectCalculationPage_weight => 'Poids';

  @override
  String get projectCalculationPage_total => 'Total';

  @override
  String get projectCalculationPage_presetTotal => 'Total du preset';

  @override
  String get projectCalculationPage_globalTotal => 'Total global';

  @override
  String get videoPage_title => 'Vidéo';

  @override
  String get videoPage_videoCalculation => 'Calcul vidéo';

  @override
  String get videoPage_videoSimulation => 'Simulation vidéo';

  @override
  String get videoPage_videoControl => 'Contrôle vidéo';

  @override
  String get electricityPage_title => 'Électricité';

  @override
  String get electricityPage_project => 'Projet';

  @override
  String get electricityPage_calculations => 'Calculs';

  @override
  String get electricityPage_noPresetSelected => 'Aucun preset sélectionné';

  @override
  String get electricityPage_selectedPreset => 'Preset sélectionné';

  @override
  String get electricityPage_powerConsumption => 'Consommation électrique';

  @override
  String get electricityPage_presetTotal => 'Total du preset';

  @override
  String get electricityPage_globalTotal => 'Total global';

  @override
  String get electricityPage_consumptionByCategory =>
      'Consommation par catégorie';

  @override
  String get electricityPage_powerCalculation => 'Calcul de puissance';

  @override
  String get electricityPage_voltage => 'Tension';

  @override
  String get electricityPage_phase => 'Phase';

  @override
  String get electricityPage_threePhase => 'Triphasé';

  @override
  String get electricityPage_singlePhase => 'Monophasé';

  @override
  String get electricityPage_current => 'Courant (A)';

  @override
  String get electricityPage_power => 'Puissance (W)';

  @override
  String get electricityPage_powerConversion => 'Conversion de puissance';

  @override
  String get electricityPage_kw => 'Puissance active (kW)';

  @override
  String get electricityPage_kva => 'Puissance apparente (kVA)';

  @override
  String get electricityPage_powerFactor => 'Facteur de puissance';

  @override
  String get networkPage_title => 'Réseau';

  @override
  String get networkPage_bandwidth => 'Bande passante';

  @override
  String get networkPage_networkScan => 'Scan réseau';

  @override
  String get networkPage_detectedNetwork => 'Réseau détecté';

  @override
  String get networkPage_noNetworkDetected => 'Aucun réseau détecté';

  @override
  String get networkPage_testBandwidth => 'Lancer le test';

  @override
  String get networkPage_testResults => 'Résultats du test';

  @override
  String get networkPage_bandwidthTestInProgress =>
      'Test de bande passante en cours...';

  @override
  String get networkPage_download => 'Téléchargement';

  @override
  String get networkPage_upload => 'Téléversement';

  @override
  String get networkPage_downloadError => 'Erreur lors du téléchargement';

  @override
  String get networkPage_scanError => 'Erreur lors du scan réseau';

  @override
  String get networkPage_noNetworksFound => 'Aucun réseau trouvé';

  @override
  String get networkPage_signalStrength => 'Force du signal';

  @override
  String get networkPage_frequency => 'Fréquence';

  @override
  String get soundPage_addToCart => 'Ajouter au panier';

  @override
  String get soundPage_preferredAmplifier => 'Amplificateur préféré';

  @override
  String get lightPage_beamCalculation => 'Calcul de faisceau';

  @override
  String get lightPage_driverCalculation => 'Calcul driver LED';

  @override
  String get lightPage_dmxCalculation => 'Calcul DMX';

  @override
  String get lightPage_angleRange => 'Angle (1° à 70°)';

  @override
  String get lightPage_heightRange => 'Hauteur (1m à 20m)';

  @override
  String get lightPage_distanceRange => 'Distance (1m à 40m)';

  @override
  String get lightPage_measureDistance => 'Mesurer votre distance';

  @override
  String get lightPage_calculate => 'Calculer';

  @override
  String get lightPage_selectedProducts => 'Produits sélectionnés';

  @override
  String get lightPage_reset => 'Réinitialiser';

  @override
  String get lightPage_ledLength => 'Longueur LED (en mètres)';

  @override
  String get lightPage_brand => 'Marque';

  @override
  String get lightPage_product => 'Produit';

  @override
  String get lightPage_searchProduct => 'Rechercher un produit...';

  @override
  String get lightPage_quantity => 'Quantité';

  @override
  String get lightPage_enterQuantity => 'Entrer la quantité';

  @override
  String get lightPage_cancel => 'Annuler';

  @override
  String get lightPage_ok => 'OK';

  @override
  String get lightPage_savePreset => 'Enregistrer le preset';

  @override
  String get lightPage_presetName => 'Nom du preset';

  @override
  String get lightPage_enterPresetName => 'Entrer le nom du preset';

  @override
  String get presetWidget_newPreset => 'Nouveau preset';

  @override
  String get presetWidget_renamePreset => 'Renommer le preset';

  @override
  String get presetWidget_newName => 'Nouveau nom';

  @override
  String get presetWidget_create => 'Créer';

  @override
  String get presetWidget_defaultProject => 'Votre projet';

  @override
  String get presetWidget_rename => 'Renommer';

  @override
  String get presetWidget_cancel => 'Annuler';

  @override
  String get presetWidget_confirm => 'Confirmer';

  @override
  String get presetWidget_addToCart => 'Ajouter au panier';

  @override
  String get presetWidget_preferredAmplifier => 'Amplificateur préféré';

  @override
  String get lightPage_confirm => 'Confirmer';

  @override
  String get lightPage_noFixturesSelected => 'Aucun projecteur sélectionné';

  @override
  String get lightPage_save => 'Enregistrer';

  @override
  String get soundPage_amplificationTab => 'Amplification';

  @override
  String get soundPage_decibelMeterTab => 'Sonomètre';

  @override
  String get soundPage_calculProjectTab => 'Calcul de projet';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get signOut => 'Se déconnecter';
}
