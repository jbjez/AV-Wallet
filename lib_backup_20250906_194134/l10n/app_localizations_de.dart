import 'app_localizations.dart';

class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([super.locale = 'de']);

  @override
  String get appTitle => 'AV Wallet';

  @override
  String get welcomeMessage => 'Willkommen bei AV Wallet';

  @override
  String get catalogAccess => 'Katalog aufrufen';

  @override
  String get lightMenu => 'Licht';

  @override
  String get structureMenu => 'Struktur';

  @override
  String get soundMenu => 'Ton';

  @override
  String get videoMenu => 'Video';

  @override
  String get electricityMenu => 'Elektrizität';

  @override
  String get networkMenu => 'Netzwerk';

  @override
  String get lightPage_title => 'Licht';

  @override
  String get structurePage_title => 'Struktur';

  @override
  String get selectStructure => 'Struktur auswählen';

  @override
  String distance_label(Object distance) {
    return '$distance m';
  }

  @override
  String charge_max(Object unit, Object value) {
    return 'Max. Last: $value kg$unit';
  }

  @override
  String beam_weight(Object value) {
    return 'Balkengewicht (ohne Lasten): $value kg';
  }

  @override
  String max_deflection(Object value) {
    return 'Maximale Durchbiegung: $value mm';
  }

  @override
  String get deflection_rate => 'Berücksichtigte Durchbiegungsrate: 1/200';

  @override
  String get structurePage_selectCharge => 'Lasttyp';

  @override
  String get soundPage_title => 'Ton';

  @override
  String get soundPage_amplificationLA => 'LA-Verstärkung';

  @override
  String get soundPage_delay => 'Verzögerung';

  @override
  String get soundPage_decibelMeter => 'Schallpegelmesser';

  @override
  String get soundPage_selectSpeaker => 'Lautsprecher auswählen';

  @override
  String get soundPage_selectedSpeakers => 'Ausgewählte Lautsprecher';

  @override
  String get soundPage_quantity => 'Menge';

  @override
  String get soundPage_calculate => 'Berechnen';

  @override
  String get soundPage_reset => 'Zurücksetzen';

  @override
  String get soundPage_optimalConfig => 'Empfohlene Verstärkerkonfiguration';

  @override
  String get soundPage_noConfig =>
      'Keine optimale Konfiguration für diese Lautsprecherkombination gefunden';

  @override
  String get soundPage_checkCompat => 'Bitte Kompatibilitäten überprüfen';

  @override
  String get soundPage_addPreset => 'Preset hinzufügen';

  @override
  String get soundPage_presetName => 'Preset-Name';

  @override
  String get soundPage_enterPresetName => 'Preset-Namen eingeben';

  @override
  String get soundPage_save => 'Speichern';

  @override
  String get soundPage_cancel => 'Abbrechen';

  @override
  String get catalogPage_title => 'Katalog';

  @override
  String get catalogPage_search => 'Suchen';

  @override
  String get catalogPage_category => 'Kategorie';

  @override
  String get catalogPage_subCategory => 'Unterkategorie';

  @override
  String get catalogPage_brand => 'Marke';

  @override
  String get catalogPage_product => 'Produkt';

  @override
  String get catalogPage_addToCart => 'In den Warenkorb';

  @override
  String get catalogPage_quantity => 'Menge';

  @override
  String get catalogPage_enterQuantity => 'Menge eingeben';

  @override
  String get catalogPage_cart => 'Warenkorb';

  @override
  String get catalogPage_emptyCart => 'Ihr Warenkorb ist leer';

  @override
  String get catalogPage_total => 'Gesamt';

  @override
  String get catalogPage_checkout => 'Zur Kasse';

  @override
  String get catalogPage_clearCart => 'Warenkorb leeren';

  @override
  String get catalogPage_remove => 'Entfernen';

  @override
  String get catalogPage_confirm => 'Bestätigen';

  @override
  String get catalogPage_cancel => 'Abbrechen';

  @override
  String get catalogPage_weight => 'Gewicht';

  @override
  String get presetWidget_title => 'Presets';

  @override
  String get presetWidget_add => 'Preset hinzufügen';

  @override
  String get presetWidget_edit => 'Bearbeiten';

  @override
  String get presetWidget_delete => 'Löschen';

  @override
  String get presetWidget_confirmDelete =>
      'Sind Sie sicher, dass Sie dieses Preset löschen möchten?';

  @override
  String get presetWidget_yes => 'Ja';

  @override
  String get presetWidget_no => 'Nein';

  @override
  String get projectCalculationPage_title => 'Projektberechnung';

  @override
  String get projectCalculationPage_powerProject => 'Leistungsprojekt';

  @override
  String get projectCalculationPage_weightProject => 'Gewichtsprojekt';

  @override
  String get projectCalculationPage_noPresetSelected =>
      'Kein Preset ausgewählt';

  @override
  String get projectCalculationPage_powerConsumption => 'Stromverbrauch';

  @override
  String get projectCalculationPage_weight => 'Gewicht';

  @override
  String get projectCalculationPage_total => 'Gesamt';

  @override
  String get projectCalculationPage_presetTotal => 'Preset-Gesamt';

  @override
  String get projectCalculationPage_globalTotal => 'Globales Gesamt';

  @override
  String get videoPage_title => 'Video';

  @override
  String get videoPage_videoCalculation => 'Videoberechnung';

  @override
  String get videoPage_videoSimulation => 'Videosimulation';

  @override
  String get videoPage_videoControl => 'Videosteuerung';

  @override
  String get electricityPage_title => 'Elektrizität';

  @override
  String get electricityPage_project => 'Projekt';

  @override
  String get electricityPage_calculations => 'Berechnungen';

  @override
  String get electricityPage_noPresetSelected => 'Kein Preset ausgewählt';

  @override
  String get electricityPage_selectedPreset => 'Ausgewähltes Preset';

  @override
  String get electricityPage_powerConsumption => 'Stromverbrauch';

  @override
  String get electricityPage_presetTotal => 'Preset-Gesamt';

  @override
  String get electricityPage_globalTotal => 'Globales Gesamt';

  @override
  String get electricityPage_consumptionByCategory =>
      'Verbrauch nach Kategorie';

  @override
  String get electricityPage_powerCalculation => 'Leistungsberechnung';

  @override
  String get electricityPage_voltage => 'Spannung';

  @override
  String get electricityPage_phase => 'Phase';

  @override
  String get electricityPage_threePhase => 'Dreiphasig';

  @override
  String get electricityPage_singlePhase => 'Einphasig';

  @override
  String get electricityPage_current => 'Strom (A)';

  @override
  String get electricityPage_power => 'Leistung (W)';

  @override
  String get electricityPage_powerConversion => 'Leistungsumrechnung';

  @override
  String get electricityPage_kw => 'Wirkleistung (kW)';

  @override
  String get electricityPage_kva => 'Scheinleistung (kVA)';

  @override
  String get electricityPage_powerFactor => 'Leistungsfaktor';

  @override
  String get networkPage_title => 'Netzwerk';

  @override
  String get networkPage_bandwidth => 'Bandbreite';

  @override
  String get networkPage_networkScan => 'Netzwerkscan';

  @override
  String get networkPage_detectedNetwork => 'Erkanntes Netzwerk';

  @override
  String get networkPage_noNetworkDetected => 'Kein Netzwerk erkannt';

  @override
  String get networkPage_testBandwidth => 'Test starten';

  @override
  String get networkPage_testResults => 'Testergebnisse';

  @override
  String get networkPage_bandwidthTestInProgress => 'Bandbreitentest läuft...';

  @override
  String get networkPage_download => 'Download';

  @override
  String get networkPage_upload => 'Upload';

  @override
  String get networkPage_downloadError => 'Fehler beim Download';

  @override
  String get networkPage_scanError => 'Fehler beim Netzwerkscan';

  @override
  String get networkPage_noNetworksFound => 'Keine Netzwerke gefunden';

  @override
  String get networkPage_signalStrength => 'Signalstärke';

  @override
  String get networkPage_frequency => 'Frequenz';

  @override
  String get soundPage_addToCart => 'In den Warenkorb';

  @override
  String get soundPage_preferredAmplifier => 'Bevorzugter Verstärker';

  @override
  String get lightPage_beamCalculation => 'Strahlberechnung';

  @override
  String get lightPage_driverCalculation => 'LED-Treiberberechnung';

  @override
  String get lightPage_dmxCalculation => 'DMX-Berechnung';

  @override
  String get lightPage_angleRange => 'Winkel (1° bis 70°)';

  @override
  String get lightPage_heightRange => 'Höhe (1m bis 20m)';

  @override
  String get lightPage_distanceRange => 'Entfernung (1m bis 40m)';

  @override
  String get lightPage_measureDistance => 'Entfernung messen';

  @override
  String get lightPage_calculate => 'Berechnen';

  @override
  String get lightPage_selectedProducts => 'Ausgewählte Produkte';

  @override
  String get lightPage_reset => 'Zurücksetzen';

  @override
  String get lightPage_ledLength => 'LED-Länge (in Metern)';

  @override
  String get lightPage_brand => 'Marke';

  @override
  String get lightPage_product => 'Produkt';

  @override
  String get lightPage_searchProduct => 'Produkt suchen...';

  @override
  String get lightPage_quantity => 'Menge';

  @override
  String get lightPage_enterQuantity => 'Menge eingeben';

  @override
  String get lightPage_cancel => 'Abbrechen';

  @override
  String get lightPage_ok => 'OK';

  @override
  String get lightPage_savePreset => 'Preset speichern';

  @override
  String get lightPage_presetName => 'Preset-Name';

  @override
  String get lightPage_enterPresetName => 'Preset-Namen eingeben';

  @override
  String get presetWidget_newPreset => 'Neues Preset';

  @override
  String get presetWidget_renamePreset => 'Preset umbenennen';

  @override
  String get presetWidget_newName => 'Neuer Name';

  @override
  String get presetWidget_create => 'Erstellen';

  @override
  String get presetWidget_defaultProject => 'Ihr Projekt';

  @override
  String get presetWidget_rename => 'Umbenennen';

  @override
  String get presetWidget_cancel => 'Abbrechen';

  @override
  String get presetWidget_confirm => 'Bestätigen';

  @override
  String get presetWidget_addToCart => 'In den Warenkorb';

  @override
  String get presetWidget_preferredAmplifier => 'Bevorzugter Verstärker';

  @override
  String get lightPage_confirm => 'Bestätigen';

  @override
  String get lightPage_noFixturesSelected => 'Keine Scheinwerfer ausgewählt';

  @override
  String get lightPage_save => 'Speichern';

  @override
  String get soundPage_amplificationTab => 'Verstärkung';

  @override
  String get soundPage_decibelMeterTab => 'Schallpegelmesser';

  @override
  String get soundPage_calculProjectTab => 'Projektberechnung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get signOut => 'Abmelden';
}
