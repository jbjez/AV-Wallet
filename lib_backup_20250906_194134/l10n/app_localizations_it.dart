import 'app_localizations.dart';

class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([super.locale = 'it']);

  @override
  String get appTitle => 'AV Wallet';

  @override
  String get welcomeMessage => 'Benvenuto in AV Wallet';

  @override
  String get catalogAccess => 'Accedi al catalogo';

  @override
  String get lightMenu => 'Luce';

  @override
  String get structureMenu => 'Struttura';

  @override
  String get soundMenu => 'Audio';

  @override
  String get videoMenu => 'Video';

  @override
  String get electricityMenu => 'Elettricità';

  @override
  String get networkMenu => 'Rete';

  @override
  String get lightPageTitle => 'Luce';

  @override
  String get structurePageTitle => 'Struttura';

  @override
  String get selectStructure => 'Seleziona struttura';

  @override
  String distance_label(Object distance) {
    return '$distance m';
  }

  @override
  String charge_max(Object unit, Object value) {
    return 'Carico massimo: $value kg$unit';
  }

  @override
  String beam_weight(Object value) {
    return 'Peso della trave (esclusi i carichi): $value kg';
  }

  @override
  String max_deflection(Object value) {
    return 'Flessione massima: $value mm';
  }

  @override
  String get deflectionRate => 'Tasso di flessione considerato: 1/200';

  @override
  String get structurePageSelectCharge => 'Tipo di carico';

  @override
  String get soundPageTitle => 'Audio';

  @override
  String get soundPage_amplificationLA => 'Amplificazione LA';

  @override
  String get soundPage_delay => 'Ritardo';

  @override
  String get soundPage_decibelMeter => 'Misuratore di decibel';

  @override
  String get soundPage_selectSpeaker => 'Seleziona un altoparlante';

  @override
  String get soundPage_selectedSpeakers => 'Altoparlanti selezionati';

  @override
  String get soundPage_quantity => 'Quantità';

  @override
  String get soundPageCalculate => 'Calcola';

  @override
  String get soundPageReset => 'Reimposta';

  @override
  String get soundPageOptimalConfig =>
      'Configurazione amplificazione consigliata';

  @override
  String get soundPageNoConfig =>
      'Nessuna configurazione ottimale trovata per questa combinazione di altoparlanti';

  @override
  String get soundPageCheckCompat => 'Verifica le compatibilità';

  @override
  String get soundPageAddPreset => 'Aggiungi preset';

  @override
  String get soundPagePresetName => 'Nome preset';

  @override
  String get soundPageEnterPresetName => 'Inserisci nome preset';

  @override
  String get soundPageSave => 'Salva';

  @override
  String get soundPageCancel => 'Annulla';

  @override
  String get catalogPageTitle => 'Catalogo';

  @override
  String get catalogPageSearch => 'Cerca';

  @override
  String get catalogPageCategory => 'Categoria';

  @override
  String get catalogPageSubCategory => 'Sottocategoria';

  @override
  String get catalogPageBrand => 'Marca';

  @override
  String get catalogPageProduct => 'Prodotto';

  @override
  String get catalogPageAddToCart => 'Aggiungi al carrello';

  @override
  String get catalogPageQuantity => 'Quantità';

  @override
  String get catalogPageEnterQuantity => 'Inserisci quantità';

  @override
  String get catalogPageCart => 'Carrello';

  @override
  String get catalogPageEmptyCart => 'Il tuo carrello è vuoto';

  @override
  String get catalogPageTotal => 'Totale';

  @override
  String get catalogPageCheckout => 'Procedi all\'acquisto';

  @override
  String get catalogPageClearCart => 'Svuota carrello';

  @override
  String get catalogPageRemove => 'Rimuovi';

  @override
  String get catalogPageConfirm => 'Conferma';

  @override
  String get catalogPageCancel => 'Annulla';

  @override
  String get catalogPageWeight => 'Peso';

  @override
  String get presetWidgetTitle => 'Preset';

  @override
  String get presetWidgetAdd => 'Aggiungi preset';

  @override
  String get presetWidgetEdit => 'Modifica';

  @override
  String get presetWidgetDelete => 'Elimina';

  @override
  String get presetWidgetConfirmDelete =>
      'Sei sicuro di voler eliminare questo preset?';

  @override
  String get presetWidgetYes => 'Sì';

  @override
  String get presetWidgetNo => 'No';

  @override
  String get projectCalculationPageTitle => 'Calcolo progetto';

  @override
  String get projectCalculationPagePowerProject => 'Progetto potenza';

  @override
  String get projectCalculationPageWeightProject => 'Progetto peso';

  @override
  String get projectCalculationPageNoPresetSelected =>
      'Nessun preset selezionato';

  @override
  String get projectCalculationPagePowerConsumption => 'Consumo elettrico';

  @override
  String get projectCalculationPageWeight => 'Peso';

  @override
  String get projectCalculationPageTotal => 'Totale';

  @override
  String get projectCalculationPagePresetTotal => 'Totale preset';

  @override
  String get projectCalculationPageGlobalTotal => 'Totale globale';

  @override
  String get videoPageTitle => 'Video';

  @override
  String get videoPageVideoCalculation => 'Calcolo video';

  @override
  String get videoPageVideoSimulation => 'Simulazione video';

  @override
  String get videoPageVideoControl => 'Controllo video';

  @override
  String get electricityPageTitle => 'Elettricità';

  @override
  String get electricityPageProject => 'Progetto';

  @override
  String get electricityPageCalculations => 'Calcoli';

  @override
  String get electricityPageNoPresetSelected => 'Nessun preset selezionato';

  @override
  String get electricityPageSelectedPreset => 'Preset selezionato';

  @override
  String get electricityPagePowerConsumption => 'Consumo elettrico';

  @override
  String get electricityPagePresetTotal => 'Totale preset';

  @override
  String get electricityPageGlobalTotal => 'Totale globale';

  @override
  String get electricityPageConsumptionByCategory => 'Consumo per categoria';

  @override
  String get electricityPagePowerCalculation => 'Calcolo potenza';

  @override
  String get electricityPageVoltage => 'Tensione';

  @override
  String get electricityPagePhase => 'Fase';

  @override
  String get electricityPageThreePhase => 'Trifase';

  @override
  String get electricityPageSinglePhase => 'Monofase';

  @override
  String get electricityPageCurrent => 'Corrente (A)';

  @override
  String get electricityPagePower => 'Potenza (W)';

  @override
  String get electricityPagePowerConversion => 'Conversione potenza';

  @override
  String get electricityPageKw => 'Potenza attiva (kW)';

  @override
  String get electricityPageKva => 'Potenza apparente (kVA)';

  @override
  String get electricityPagePowerFactor => 'Fattore di potenza';

  @override
  String get networkPageTitle => 'Rete';

  @override
  String get networkPageBandwidth => 'Larghezza di banda';

  @override
  String get networkPageNetworkScan => 'Scansione rete';

  @override
  String get networkPageDetectedNetwork => 'Rete rilevata';

  @override
  String get networkPageNoNetworkDetected => 'Nessuna rete rilevata';

  @override
  String get networkPageTestBandwidth => 'Avvia test';

  @override
  String get networkPageTestResults => 'Risultati test';

  @override
  String get networkPageBandwidthTestInProgress =>
      'Test larghezza di banda in corso...';

  @override
  String get networkPageDownload => 'Download';

  @override
  String get networkPageUpload => 'Upload';

  @override
  String get networkPageDownloadError => 'Errore durante il download';

  @override
  String get networkPageScanError => 'Errore durante la scansione della rete';

  @override
  String get networkPageNoNetworksFound => 'Nessuna rete trovata';

  @override
  String get networkPageSignalStrength => 'Forza del segnale';

  @override
  String get networkPageFrequency => 'Frequenza';

  @override
  String get soundPageAddToCart => 'Aggiungi al carrello';

  @override
  String get soundPagePreferredAmplifier => 'Amplificatore preferito';

  @override
  String get lightPageBeamCalculation => 'Calcolo fascio';

  @override
  String get lightPageDriverCalculation => 'Calcolo driver LED';

  @override
  String get lightPageDmxCalculation => 'Calcolo DMX';

  @override
  String get lightPageAngleRange => 'Angolo (1° a 70°)';

  @override
  String get lightPageHeightRange => 'Altezza (1m a 20m)';

  @override
  String get lightPageDistanceRange => 'Distanza (1m a 40m)';

  @override
  String get lightPageMeasureDistance => 'Misura la tua distanza';

  @override
  String get lightPageCalculate => 'Calcola';

  @override
  String get lightPageSelectedProducts => 'Prodotti selezionati';

  @override
  String get lightPageReset => 'Reimposta';

  @override
  String get lightPageLedLength => 'Lunghezza LED (in metri)';

  @override
  String get lightPageBrand => 'Marca';

  @override
  String get lightPageProduct => 'Prodotto';

  @override
  String get lightPageSearchProduct => 'Cerca prodotto...';

  @override
  String get lightPageQuantity => 'Quantità';

  @override
  String get lightPageEnterQuantity => 'Inserisci quantità';

  @override
  String get lightPageCancel => 'Annulla';

  @override
  String get lightPageOk => 'OK';

  @override
  String get lightPageSavePreset => 'Salva preset';

  @override
  String get lightPagePresetName => 'Nome preset';

  @override
  String get lightPageEnterPresetName => 'Inserisci nome preset';

  @override
  String get presetWidgetNewPreset => 'Nuovo preset';

  @override
  String get presetWidgetRenamePreset => 'Rinomina preset';

  @override
  String get presetWidgetNewName => 'Nuovo nome';

  @override
  String get presetWidgetCreate => 'Crea';

  @override
  String get presetWidgetDefaultProject => 'Il tuo progetto';

  @override
  String get presetWidgetRename => 'Rinomina';

  @override
  String get presetWidgetCancel => 'Annulla';

  @override
  String get presetWidgetConfirm => 'Conferma';

  @override
  String get presetWidgetAddToCart => 'Aggiungi al carrello';

  @override
  String get presetWidgetPreferredAmplifier => 'Amplificatore preferito';

  @override
  String get lightPageConfirm => 'Conferma';

  @override
  String get lightPageNoFixturesSelected => 'Nessun proiettore selezionato';

  @override
  String get lightPageSave => 'Salva';

  @override
  String get soundPageAmplificationTab => 'Amplificazione';

  @override
  String get soundPageDecibelMeterTab => 'Misuratore di decibel';

  @override
  String get soundPageCalculProjectTab => 'Calcolo progetto';

  @override
  String get catalogPage_addToCart => 'Aggiungi al carrello';

  @override
  String get catalogPage_brand => 'Marca';

  @override
  String get catalogPage_cancel => 'Annulla';

  @override
  String get catalogPage_cart => 'Carrello';

  @override
  String get catalogPage_category => 'Categoria';

  @override
  String get catalogPage_clearCart => 'Svuota carrello';

  @override
  String get catalogPage_confirm => 'Conferma';

  @override
  String get catalogPage_emptyCart => 'Il tuo carrello è vuoto';

  @override
  String get catalogPage_enterQuantity => 'Inserisci quantità';

  @override
  String get catalogPage_product => 'Prodotto';

  @override
  String get catalogPage_quantity => 'Quantità';

  @override
  String get catalogPage_remove => 'Rimuovi';

  @override
  String get catalogPage_search => 'Cerca';

  @override
  String get catalogPage_subCategory => 'Sottocategoria';

  @override
  String get catalogPage_title => 'Catalogo';

  @override
  String get catalogPage_total => 'Totale';

  @override
  String get catalogPage_weight => 'Peso';

  @override
  String get electricityPage_calculations => 'Calcoli';

  @override
  String get electricityPage_consumptionByCategory => 'Consumo per categoria';

  @override
  String get electricityPage_current => 'Corrente (A)';

  @override
  String get electricityPage_globalTotal => 'Totale globale';

  @override
  String get electricityPage_kva => 'Potenza apparente (kVA)';

  @override
  String get electricityPage_kw => 'Potenza attiva (kW)';

  @override
  String get electricityPage_noPresetSelected => 'Nessun preset selezionato';

  @override
  String get electricityPage_phase => 'Fase';

  @override
  String get electricityPage_power => 'Potenza (W)';

  @override
  String get electricityPage_powerCalculation => 'Calcolo potenza';

  @override
  String get electricityPage_powerConsumption => 'Consumo elettrico';

  @override
  String get electricityPage_powerConversion => 'Conversione potenza';

  @override
  String get electricityPage_powerFactor => 'Fattore di potenza';

  @override
  String get electricityPage_presetTotal => 'Totale preset';

  @override
  String get electricityPage_project => 'Progetto';

  @override
  String get electricityPage_selectedPreset => 'Preset selezionato';

  @override
  String get electricityPage_singlePhase => 'Monofase';

  @override
  String get electricityPage_threePhase => 'Trifase';

  @override
  String get electricityPage_title => 'Elettricità';

  @override
  String get electricityPage_voltage => 'Tensione';

  @override
  String get lightPage_angleRange => 'Angolo (1° a 70°)';

  @override
  String get lightPage_beamCalculation => 'Calcolo fascio';

  @override
  String get lightPage_brand => 'Marca';

  @override
  String get lightPage_calculate => 'Calcola';

  @override
  String get lightPage_cancel => 'Annulla';

  @override
  String get lightPage_confirm => 'Conferma';

  @override
  String get lightPage_distanceRange => 'Distanza (1m a 40m)';

  @override
  String get lightPage_dmxCalculation => 'Calcolo DMX';

  @override
  String get lightPage_driverCalculation => 'Calcolo driver LED';

  @override
  String get lightPage_enterPresetName => 'Inserisci nome preset';

  @override
  String get lightPage_enterQuantity => 'Inserisci quantità';

  @override
  String get lightPage_heightRange => 'Altezza (1m a 20m)';

  @override
  String get lightPage_ledLength => 'Lunghezza LED (in metri)';

  @override
  String get lightPage_measureDistance => 'Misura la tua distanza';

  @override
  String get lightPage_noFixturesSelected => 'Nessun proiettore selezionato';

  @override
  String get lightPage_ok => 'OK';

  @override
  String get lightPage_presetName => 'Nome preset';

  @override
  String get lightPage_product => 'Prodotto';

  @override
  String get lightPage_quantity => 'Quantità';

  @override
  String get lightPage_reset => 'Reimposta';

  @override
  String get lightPage_save => 'Salva';

  @override
  String get lightPage_savePreset => 'Salva preset';

  @override
  String get lightPage_searchProduct => 'Cerca prodotto...';

  @override
  String get lightPage_selectedProducts => 'Prodotti selezionati';

  @override
  String get networkPage_bandwidth => 'Larghezza di banda';

  @override
  String get networkPage_bandwidthTestInProgress =>
      'Test larghezza di banda in corso...';

  @override
  String get networkPage_detectedNetwork => 'Rete rilevata';

  @override
  String get networkPage_download => 'Download';

  @override
  String get networkPage_downloadError => 'Errore durante il download';

  @override
  String get networkPage_frequency => 'Frequenza';

  @override
  String get networkPage_networkScan => 'Scansione rete';

  @override
  String get networkPage_noNetworkDetected => 'Nessuna rete rilevata';

  @override
  String get networkPage_noNetworksFound => 'Nessuna rete trovata';

  @override
  String get networkPage_scanError => 'Errore durante la scansione della rete';

  @override
  String get networkPage_signalStrength => 'Forza del segnale';

  @override
  String get networkPage_testBandwidth => 'Avvia test';

  @override
  String get networkPage_testResults => 'Risultati test';

  @override
  String get networkPage_title => 'Rete';

  @override
  String get networkPage_upload => 'Upload';

  @override
  String get presetWidget_add => 'Aggiungi preset';

  @override
  String get presetWidget_addToCart => 'Aggiungi al carrello';

  @override
  String get presetWidget_cancel => 'Annulla';

  @override
  String get presetWidget_confirm => 'Conferma';

  @override
  String get presetWidget_confirmDelete =>
      'Sei sicuro di voler eliminare questo preset?';

  @override
  String get presetWidget_create => 'Crea';

  @override
  String get presetWidget_defaultProject => 'Il tuo progetto';

  @override
  String get presetWidget_delete => 'Elimina';

  @override
  String get presetWidget_edit => 'Modifica';

  @override
  String get presetWidget_newName => 'Nuovo nome';

  @override
  String get presetWidget_newPreset => 'Nuovo preset';

  @override
  String get presetWidget_no => 'No';

  @override
  String get presetWidget_preferredAmplifier => 'Amplificatore preferito';

  @override
  String get presetWidget_rename => 'Rinomina';

  @override
  String get presetWidget_renamePreset => 'Rinomina preset';

  @override
  String get presetWidget_title => 'Preset';

  @override
  String get presetWidget_yes => 'Sì';

  @override
  String get projectCalculationPage_globalTotal => 'Totale globale';

  @override
  String get projectCalculationPage_noPresetSelected =>
      'Nessun preset selezionato';

  @override
  String get projectCalculationPage_powerConsumption => 'Consumo elettrico';

  @override
  String get projectCalculationPage_powerProject => 'Progetto potenza';

  @override
  String get projectCalculationPage_presetTotal => 'Totale preset';

  @override
  String get projectCalculationPage_title => 'Calcolo progetto';

  @override
  String get projectCalculationPage_total => 'Totale';

  @override
  String get projectCalculationPage_weight => 'Peso';

  @override
  String get projectCalculationPage_weightProject => 'Progetto peso';

  @override
  String get soundPage_addPreset => 'Aggiungi preset';

  @override
  String get soundPage_addToCart => 'Aggiungi al carrello';

  @override
  String get soundPage_amplificationTab => 'Amplificazione';

  @override
  String get soundPage_calculProjectTab => 'Calcolo progetto';

  @override
  String get soundPage_calculate => 'Calcola';

  @override
  String get soundPage_cancel => 'Annulla';

  @override
  String get soundPage_checkCompat => 'Verifica le compatibilità';

  @override
  String get soundPage_decibelMeterTab => 'Misuratore di decibel';

  @override
  String get soundPage_enterPresetName => 'Inserisci nome preset';

  @override
  String get soundPage_noConfig =>
      'Nessuna configurazione ottimale trovata per questa combinazione di altoparlanti';

  @override
  String get soundPage_optimalConfig =>
      'Configurazione amplificazione consigliata';

  @override
  String get soundPage_presetName => 'Nome preset';

  @override
  String get soundPage_preferredAmplifier => 'Amplificatore preferito';

  @override
  String get soundPage_reset => 'Reimposta';

  @override
  String get soundPage_save => 'Salva';

  @override
  String get videoPage_title => 'Video';

  @override
  String get videoPage_videoCalculation => 'Calcolo video';

  @override
  String get videoPage_videoControl => 'Controllo video';

  @override
  String get videoPage_videoSimulation => 'Simulazione video';

  @override
  String get catalogPage_checkout => 'Procedi all\'acquisto';

  @override
  String get deflection_rate => 'Tasso di flessione considerato: 1/200';

  @override
  String get lightPage_title => 'Luce';

  @override
  String get soundPage_title => 'Audio';

  @override
  String get structurePage_title => 'Struttura';

  @override
  String get structurePage_selectCharge => 'Tipo di carico';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get signOut => 'Disconnetti';
}
