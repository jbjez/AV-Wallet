// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AV Wallet';

  @override
  String get welcomeMessage => 'Welcome to AV Wallet';

  @override
  String get catalogAccess => 'Access Catalog';

  @override
  String get lightMenu => 'Light';

  @override
  String get structureMenu => 'Structure';

  @override
  String get soundMenu => 'Sound';

  @override
  String get videoMenu => 'Video';

  @override
  String get electricityMenu => 'Electricity';

  @override
  String get networkMenu => 'Network';

  @override
  String get lightPage_title => 'Light';

  @override
  String get structurePage_title => 'Structure';

  @override
  String get selectStructure => 'Select structure';

  @override
  String distance_label(Object distance) {
    return '$distance m';
  }

  @override
  String charge_max(Object unit, Object value) {
    return 'Max load: $value kg$unit';
  }

  @override
  String beam_weight(Object value) {
    return 'Beam weight (excluding loads): $value kg';
  }

  @override
  String max_deflection(Object value) {
    return 'Maximum deflection: $value mm';
  }

  @override
  String get deflection_rate => 'Deflection rate taken into account: 1/200';

  @override
  String get structurePage_selectCharge => 'Load type';

  @override
  String get soundPage_title => 'Sound';

  @override
  String get soundPage_amplificationLA => 'LA Amplification';

  @override
  String get soundPage_delay => 'Delay';

  @override
  String get soundPage_decibelMeter => 'Decibel Meter';

  @override
  String get soundPage_selectSpeaker => 'Select a speaker';

  @override
  String get soundPage_selectedSpeakers => 'Selected speakers';

  @override
  String get soundPage_quantity => 'Quantity';

  @override
  String get soundPage_calculate => 'Calculate';

  @override
  String get soundPage_reset => 'Reset';

  @override
  String get soundPage_optimalConfig =>
      'Recommended amplification configuration';

  @override
  String get soundPage_noConfig =>
      'No optimal configuration found for this speaker combination';

  @override
  String get soundPage_checkCompat => 'Please check compatibilities';

  @override
  String get soundPage_addPreset => 'Add preset';

  @override
  String get soundPage_presetName => 'Preset name';

  @override
  String get soundPage_enterPresetName => 'Enter preset name';

  @override
  String get soundPage_save => 'Save';

  @override
  String get soundPage_cancel => 'Cancel';

  @override
  String get catalogPage_title => 'Catalog';

  @override
  String get catalogPage_search => 'Search';

  @override
  String get catalogPage_category => 'Category';

  @override
  String get catalogPage_subCategory => 'Sub-category';

  @override
  String get catalogPage_brand => 'Brand';

  @override
  String get catalogPage_product => 'Product';

  @override
  String get catalogPage_addToCart => 'Add to cart';

  @override
  String get catalogPage_quantity => 'Quantity';

  @override
  String get catalogPage_enterQuantity => 'Enter quantity';

  @override
  String get catalogPage_cart => 'Cart';

  @override
  String get catalogPage_emptyCart => 'Your cart is empty';

  @override
  String get catalogPage_total => 'Total';

  @override
  String get catalogPage_checkout => 'Checkout';

  @override
  String get catalogPage_clearCart => 'Clear cart';

  @override
  String get catalogPage_remove => 'Remove';

  @override
  String get catalogPage_confirm => 'Confirm';

  @override
  String get catalogPage_cancel => 'Cancel';

  @override
  String get catalogPage_weight => 'Weight';

  @override
  String get presetWidget_title => 'Presets';

  @override
  String get presetWidget_add => 'Add preset';

  @override
  String get presetWidget_edit => 'Edit';

  @override
  String get presetWidget_delete => 'Delete';

  @override
  String get presetWidget_confirmDelete =>
      'Are you sure you want to delete this preset?';

  @override
  String get presetWidget_yes => 'Yes';

  @override
  String get presetWidget_no => 'No';

  @override
  String get projectCalculationPage_title => 'Project Calculation';

  @override
  String get projectCalculationPage_powerProject => 'Power Project';

  @override
  String get projectCalculationPage_weightProject => 'Weight Project';

  @override
  String get projectCalculationPage_noPresetSelected => 'No preset selected';

  @override
  String get projectCalculationPage_powerConsumption => 'Power consumption';

  @override
  String get projectCalculationPage_weight => 'Weight';

  @override
  String get projectCalculationPage_total => 'Total';

  @override
  String get projectCalculationPage_presetTotal => 'Preset total';

  @override
  String get projectCalculationPage_globalTotal => 'Global total';

  @override
  String get videoPage_title => 'Video';

  @override
  String get videoPage_videoCalculation => 'Video Calculation';

  @override
  String get videoPage_videoSimulation => 'Video Simulation';

  @override
  String get videoPage_videoControl => 'Video Control';

  @override
  String get electricityPage_title => 'Electricity';

  @override
  String get electricityPage_project => 'Project';

  @override
  String get electricityPage_calculations => 'Calculations';

  @override
  String get electricityPage_noPresetSelected => 'No preset selected';

  @override
  String get electricityPage_selectedPreset => 'Selected preset';

  @override
  String get electricityPage_powerConsumption => 'Power consumption';

  @override
  String get electricityPage_presetTotal => 'Preset total';

  @override
  String get electricityPage_globalTotal => 'Global total';

  @override
  String get electricityPage_consumptionByCategory => 'Consumption by category';

  @override
  String get electricityPage_powerCalculation => 'Power calculation';

  @override
  String get electricityPage_voltage => 'Voltage';

  @override
  String get electricityPage_phase => 'Phase';

  @override
  String get electricityPage_threePhase => 'Three-phase';

  @override
  String get electricityPage_singlePhase => 'Single-phase';

  @override
  String get electricityPage_current => 'Current (A)';

  @override
  String get electricityPage_power => 'Power (W)';

  @override
  String get electricityPage_powerConversion => 'Power conversion';

  @override
  String get electricityPage_kw => 'Active power (kW)';

  @override
  String get electricityPage_kva => 'Apparent power (kVA)';

  @override
  String get electricityPage_powerFactor => 'Power factor';

  @override
  String get networkPage_title => 'Network';

  @override
  String get networkPage_bandwidth => 'Bandwidth';

  @override
  String get networkPage_networkScan => 'Network Scan';

  @override
  String get networkPage_detectedNetwork => 'Detected network';

  @override
  String get networkPage_noNetworkDetected => 'No network detected';

  @override
  String get networkPage_testBandwidth => 'Run test';

  @override
  String get networkPage_testResults => 'Test results';

  @override
  String get networkPage_bandwidthTestInProgress =>
      'Bandwidth test in progress...';

  @override
  String get networkPage_download => 'Download';

  @override
  String get networkPage_upload => 'Upload';

  @override
  String get networkPage_downloadError => 'Error during download';

  @override
  String get networkPage_scanError => 'Error during network scan';

  @override
  String get networkPage_noNetworksFound => 'No networks found';

  @override
  String get networkPage_signalStrength => 'Signal strength';

  @override
  String get networkPage_frequency => 'Frequency';

  @override
  String get soundPage_addToCart => 'Add to cart';

  @override
  String get soundPage_preferredAmplifier => 'Preferred amplifier';

  @override
  String get lightPage_beamCalculation => 'Beam Calculation';

  @override
  String get lightPage_driverCalculation => 'LED Driver Calculation';

  @override
  String get lightPage_dmxCalculation => 'DMX Calculation';

  @override
  String get lightPage_angleRange => 'Angle (1° to 70°)';

  @override
  String get lightPage_heightRange => 'Height (1m to 20m)';

  @override
  String get lightPage_distanceRange => 'Distance (1m to 40m)';

  @override
  String get lightPage_measureDistance => 'Measure your distance';

  @override
  String get lightPage_calculate => 'Calculate';

  @override
  String get lightPage_selectedProducts => 'Selected products';

  @override
  String get lightPage_reset => 'Reset';

  @override
  String get lightPage_ledLength => 'LED Length (in meters)';

  @override
  String get lightPage_brand => 'Brand';

  @override
  String get lightPage_product => 'Product';

  @override
  String get lightPage_searchProduct => 'Search for a product...';

  @override
  String get lightPage_quantity => 'Quantity';

  @override
  String get lightPage_enterQuantity => 'Enter quantity';

  @override
  String get lightPage_cancel => 'Cancel';

  @override
  String get lightPage_ok => 'OK';

  @override
  String get lightPage_savePreset => 'Save preset';

  @override
  String get lightPage_presetName => 'Preset name';

  @override
  String get lightPage_enterPresetName => 'Enter preset name';

  @override
  String get presetWidget_newPreset => 'New preset';

  @override
  String get presetWidget_renamePreset => 'Rename preset';

  @override
  String get presetWidget_newName => 'New name';

  @override
  String get presetWidget_create => 'Create';

  @override
  String get presetWidget_defaultProject => 'Your project';

  @override
  String get presetWidget_rename => 'Rename';

  @override
  String get presetWidget_cancel => 'Cancel';

  @override
  String get presetWidget_confirm => 'Confirm';

  @override
  String get presetWidget_addToCart => 'Add to cart';

  @override
  String get presetWidget_preferredAmplifier => 'Preferred amplifier';

  @override
  String get lightPage_confirm => 'Confirm';

  @override
  String get lightPage_noFixturesSelected => 'No fixtures selected';

  @override
  String get lightPage_save => 'Save';

  @override
  String get soundPage_amplificationTab => 'Amplification';

  @override
  String get soundPage_decibelMeterTab => 'Decibel Meter';

  @override
  String get soundPage_calculProjectTab => 'Project Calculation';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get signOut => 'Sign Out';
}
