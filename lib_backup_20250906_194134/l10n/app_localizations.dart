import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AV Wallet'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AV Wallet'**
  String get welcomeMessage;

  /// No description provided for @catalogAccess.
  ///
  /// In en, this message translates to:
  /// **'Access Catalog'**
  String get catalogAccess;

  /// No description provided for @lightMenu.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMenu;

  /// No description provided for @structureMenu.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structureMenu;

  /// No description provided for @soundMenu.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundMenu;

  /// No description provided for @videoMenu.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoMenu;

  /// No description provided for @electricityMenu.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricityMenu;

  /// No description provided for @networkMenu.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkMenu;

  /// No description provided for @lightPage_title.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightPage_title;

  /// No description provided for @structurePage_title.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structurePage_title;

  /// No description provided for @selectStructure.
  ///
  /// In en, this message translates to:
  /// **'Select structure'**
  String get selectStructure;

  /// No description provided for @distance_label.
  ///
  /// In en, this message translates to:
  /// **'{distance} m'**
  String distance_label(Object distance);

  /// No description provided for @charge_max.
  ///
  /// In en, this message translates to:
  /// **'Max load: {value} kg{unit}'**
  String charge_max(Object unit, Object value);

  /// No description provided for @beam_weight.
  ///
  /// In en, this message translates to:
  /// **'Beam weight (excluding loads): {value} kg'**
  String beam_weight(Object value);

  /// No description provided for @max_deflection.
  ///
  /// In en, this message translates to:
  /// **'Maximum deflection: {value} mm'**
  String max_deflection(Object value);

  /// No description provided for @deflection_rate.
  ///
  /// In en, this message translates to:
  /// **'Deflection rate taken into account: 1/200'**
  String get deflection_rate;

  /// No description provided for @structurePage_selectCharge.
  ///
  /// In en, this message translates to:
  /// **'Load type'**
  String get structurePage_selectCharge;

  /// No description provided for @soundPage_title.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundPage_title;

  /// No description provided for @soundPage_amplificationLA.
  ///
  /// In en, this message translates to:
  /// **'LA Amplification'**
  String get soundPage_amplificationLA;

  /// No description provided for @soundPage_delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get soundPage_delay;

  /// No description provided for @soundPage_decibelMeter.
  ///
  /// In en, this message translates to:
  /// **'Decibel Meter'**
  String get soundPage_decibelMeter;

  /// No description provided for @soundPage_selectSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Select a speaker'**
  String get soundPage_selectSpeaker;

  /// No description provided for @soundPage_selectedSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Selected speakers'**
  String get soundPage_selectedSpeakers;

  /// No description provided for @soundPage_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get soundPage_quantity;

  /// No description provided for @soundPage_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get soundPage_calculate;

  /// No description provided for @soundPage_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get soundPage_reset;

  /// No description provided for @soundPage_optimalConfig.
  ///
  /// In en, this message translates to:
  /// **'Recommended amplification configuration'**
  String get soundPage_optimalConfig;

  /// No description provided for @soundPage_noConfig.
  ///
  /// In en, this message translates to:
  /// **'No optimal configuration found for this speaker combination'**
  String get soundPage_noConfig;

  /// No description provided for @soundPage_checkCompat.
  ///
  /// In en, this message translates to:
  /// **'Please check compatibilities'**
  String get soundPage_checkCompat;

  /// No description provided for @soundPage_addPreset.
  ///
  /// In en, this message translates to:
  /// **'Add preset'**
  String get soundPage_addPreset;

  /// No description provided for @soundPage_presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get soundPage_presetName;

  /// No description provided for @soundPage_enterPresetName.
  ///
  /// In en, this message translates to:
  /// **'Enter preset name'**
  String get soundPage_enterPresetName;

  /// No description provided for @soundPage_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get soundPage_save;

  /// No description provided for @soundPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get soundPage_cancel;

  /// No description provided for @catalogPage_title.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogPage_title;

  /// No description provided for @catalogPage_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get catalogPage_search;

  /// No description provided for @catalogPage_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogPage_category;

  /// No description provided for @catalogPage_subCategory.
  ///
  /// In en, this message translates to:
  /// **'Sub-category'**
  String get catalogPage_subCategory;

  /// No description provided for @catalogPage_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get catalogPage_brand;

  /// No description provided for @catalogPage_product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catalogPage_product;

  /// No description provided for @catalogPage_addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get catalogPage_addToCart;

  /// No description provided for @catalogPage_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get catalogPage_quantity;

  /// No description provided for @catalogPage_enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get catalogPage_enterQuantity;

  /// No description provided for @catalogPage_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get catalogPage_cart;

  /// No description provided for @catalogPage_emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get catalogPage_emptyCart;

  /// No description provided for @catalogPage_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get catalogPage_total;

  /// No description provided for @catalogPage_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get catalogPage_checkout;

  /// No description provided for @catalogPage_clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get catalogPage_clearCart;

  /// No description provided for @catalogPage_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get catalogPage_remove;

  /// No description provided for @catalogPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get catalogPage_confirm;

  /// No description provided for @catalogPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogPage_cancel;

  /// No description provided for @catalogPage_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get catalogPage_weight;

  /// No description provided for @presetWidget_title.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetWidget_title;

  /// No description provided for @presetWidget_add.
  ///
  /// In en, this message translates to:
  /// **'Add preset'**
  String get presetWidget_add;

  /// No description provided for @presetWidget_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get presetWidget_edit;

  /// No description provided for @presetWidget_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get presetWidget_delete;

  /// No description provided for @presetWidget_confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this preset?'**
  String get presetWidget_confirmDelete;

  /// No description provided for @presetWidget_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get presetWidget_yes;

  /// No description provided for @presetWidget_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get presetWidget_no;

  /// No description provided for @projectCalculationPage_title.
  ///
  /// In en, this message translates to:
  /// **'Project Calculation'**
  String get projectCalculationPage_title;

  /// No description provided for @projectCalculationPage_powerProject.
  ///
  /// In en, this message translates to:
  /// **'Power Project'**
  String get projectCalculationPage_powerProject;

  /// No description provided for @projectCalculationPage_weightProject.
  ///
  /// In en, this message translates to:
  /// **'Weight Project'**
  String get projectCalculationPage_weightProject;

  /// No description provided for @projectCalculationPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get projectCalculationPage_noPresetSelected;

  /// No description provided for @projectCalculationPage_powerConsumption.
  ///
  /// In en, this message translates to:
  /// **'Power consumption'**
  String get projectCalculationPage_powerConsumption;

  /// No description provided for @projectCalculationPage_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get projectCalculationPage_weight;

  /// No description provided for @projectCalculationPage_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get projectCalculationPage_total;

  /// No description provided for @projectCalculationPage_presetTotal.
  ///
  /// In en, this message translates to:
  /// **'Preset total'**
  String get projectCalculationPage_presetTotal;

  /// No description provided for @projectCalculationPage_globalTotal.
  ///
  /// In en, this message translates to:
  /// **'Global total'**
  String get projectCalculationPage_globalTotal;

  /// No description provided for @videoPage_title.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoPage_title;

  /// No description provided for @videoPage_videoCalculation.
  ///
  /// In en, this message translates to:
  /// **'Video Calculation'**
  String get videoPage_videoCalculation;

  /// No description provided for @videoPage_videoSimulation.
  ///
  /// In en, this message translates to:
  /// **'Video Simulation'**
  String get videoPage_videoSimulation;

  /// No description provided for @videoPage_videoControl.
  ///
  /// In en, this message translates to:
  /// **'Video Control'**
  String get videoPage_videoControl;

  /// No description provided for @electricityPage_title.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricityPage_title;

  /// No description provided for @electricityPage_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get electricityPage_project;

  /// No description provided for @electricityPage_calculations.
  ///
  /// In en, this message translates to:
  /// **'Calculations'**
  String get electricityPage_calculations;

  /// No description provided for @electricityPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get electricityPage_noPresetSelected;

  /// No description provided for @electricityPage_selectedPreset.
  ///
  /// In en, this message translates to:
  /// **'Selected preset'**
  String get electricityPage_selectedPreset;

  /// No description provided for @electricityPage_powerConsumption.
  ///
  /// In en, this message translates to:
  /// **'Power consumption'**
  String get electricityPage_powerConsumption;

  /// No description provided for @electricityPage_presetTotal.
  ///
  /// In en, this message translates to:
  /// **'Preset total'**
  String get electricityPage_presetTotal;

  /// No description provided for @electricityPage_globalTotal.
  ///
  /// In en, this message translates to:
  /// **'Global total'**
  String get electricityPage_globalTotal;

  /// No description provided for @electricityPage_consumptionByCategory.
  ///
  /// In en, this message translates to:
  /// **'Consumption by category'**
  String get electricityPage_consumptionByCategory;

  /// No description provided for @electricityPage_powerCalculation.
  ///
  /// In en, this message translates to:
  /// **'Power calculation'**
  String get electricityPage_powerCalculation;

  /// No description provided for @electricityPage_voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get electricityPage_voltage;

  /// No description provided for @electricityPage_phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get electricityPage_phase;

  /// No description provided for @electricityPage_threePhase.
  ///
  /// In en, this message translates to:
  /// **'Three-phase'**
  String get electricityPage_threePhase;

  /// No description provided for @electricityPage_singlePhase.
  ///
  /// In en, this message translates to:
  /// **'Single-phase'**
  String get electricityPage_singlePhase;

  /// No description provided for @electricityPage_current.
  ///
  /// In en, this message translates to:
  /// **'Current (A)'**
  String get electricityPage_current;

  /// No description provided for @electricityPage_power.
  ///
  /// In en, this message translates to:
  /// **'Power (W)'**
  String get electricityPage_power;

  /// No description provided for @electricityPage_powerConversion.
  ///
  /// In en, this message translates to:
  /// **'Power conversion'**
  String get electricityPage_powerConversion;

  /// No description provided for @electricityPage_kw.
  ///
  /// In en, this message translates to:
  /// **'Active power (kW)'**
  String get electricityPage_kw;

  /// No description provided for @electricityPage_kva.
  ///
  /// In en, this message translates to:
  /// **'Apparent power (kVA)'**
  String get electricityPage_kva;

  /// No description provided for @electricityPage_powerFactor.
  ///
  /// In en, this message translates to:
  /// **'Power factor'**
  String get electricityPage_powerFactor;

  /// No description provided for @networkPage_title.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkPage_title;

  /// No description provided for @networkPage_bandwidth.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth'**
  String get networkPage_bandwidth;

  /// No description provided for @networkPage_networkScan.
  ///
  /// In en, this message translates to:
  /// **'Network Scan'**
  String get networkPage_networkScan;

  /// No description provided for @networkPage_detectedNetwork.
  ///
  /// In en, this message translates to:
  /// **'Detected network'**
  String get networkPage_detectedNetwork;

  /// No description provided for @networkPage_noNetworkDetected.
  ///
  /// In en, this message translates to:
  /// **'No network detected'**
  String get networkPage_noNetworkDetected;

  /// No description provided for @networkPage_testBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Run test'**
  String get networkPage_testBandwidth;

  /// No description provided for @networkPage_testResults.
  ///
  /// In en, this message translates to:
  /// **'Test results'**
  String get networkPage_testResults;

  /// No description provided for @networkPage_bandwidthTestInProgress.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth test in progress...'**
  String get networkPage_bandwidthTestInProgress;

  /// No description provided for @networkPage_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get networkPage_download;

  /// No description provided for @networkPage_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get networkPage_upload;

  /// No description provided for @networkPage_downloadError.
  ///
  /// In en, this message translates to:
  /// **'Error during download'**
  String get networkPage_downloadError;

  /// No description provided for @networkPage_scanError.
  ///
  /// In en, this message translates to:
  /// **'Error during network scan'**
  String get networkPage_scanError;

  /// No description provided for @networkPage_noNetworksFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found'**
  String get networkPage_noNetworksFound;

  /// No description provided for @networkPage_signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal strength'**
  String get networkPage_signalStrength;

  /// No description provided for @networkPage_frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get networkPage_frequency;

  /// No description provided for @soundPage_addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get soundPage_addToCart;

  /// No description provided for @soundPage_preferredAmplifier.
  ///
  /// In en, this message translates to:
  /// **'Preferred amplifier'**
  String get soundPage_preferredAmplifier;

  /// No description provided for @lightPage_beamCalculation.
  ///
  /// In en, this message translates to:
  /// **'Beam Calculation'**
  String get lightPage_beamCalculation;

  /// No description provided for @lightPage_driverCalculation.
  ///
  /// In en, this message translates to:
  /// **'LED Driver Calculation'**
  String get lightPage_driverCalculation;

  /// No description provided for @lightPage_dmxCalculation.
  ///
  /// In en, this message translates to:
  /// **'DMX Calculation'**
  String get lightPage_dmxCalculation;

  /// No description provided for @lightPage_angleRange.
  ///
  /// In en, this message translates to:
  /// **'Angle (1° to 70°)'**
  String get lightPage_angleRange;

  /// No description provided for @lightPage_heightRange.
  ///
  /// In en, this message translates to:
  /// **'Height (1m to 20m)'**
  String get lightPage_heightRange;

  /// No description provided for @lightPage_distanceRange.
  ///
  /// In en, this message translates to:
  /// **'Distance (1m to 40m)'**
  String get lightPage_distanceRange;

  /// No description provided for @lightPage_measureDistance.
  ///
  /// In en, this message translates to:
  /// **'Measure your distance'**
  String get lightPage_measureDistance;

  /// No description provided for @lightPage_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get lightPage_calculate;

  /// No description provided for @lightPage_selectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Selected products'**
  String get lightPage_selectedProducts;

  /// No description provided for @lightPage_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get lightPage_reset;

  /// No description provided for @lightPage_ledLength.
  ///
  /// In en, this message translates to:
  /// **'LED Length (in meters)'**
  String get lightPage_ledLength;

  /// No description provided for @lightPage_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get lightPage_brand;

  /// No description provided for @lightPage_product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get lightPage_product;

  /// No description provided for @lightPage_searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search for a product...'**
  String get lightPage_searchProduct;

  /// No description provided for @lightPage_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get lightPage_quantity;

  /// No description provided for @lightPage_enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get lightPage_enterQuantity;

  /// No description provided for @lightPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get lightPage_cancel;

  /// No description provided for @lightPage_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get lightPage_ok;

  /// No description provided for @lightPage_savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save preset'**
  String get lightPage_savePreset;

  /// No description provided for @lightPage_presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get lightPage_presetName;

  /// No description provided for @lightPage_enterPresetName.
  ///
  /// In en, this message translates to:
  /// **'Enter preset name'**
  String get lightPage_enterPresetName;

  /// No description provided for @presetWidget_newPreset.
  ///
  /// In en, this message translates to:
  /// **'New preset'**
  String get presetWidget_newPreset;

  /// No description provided for @presetWidget_renamePreset.
  ///
  /// In en, this message translates to:
  /// **'Rename preset'**
  String get presetWidget_renamePreset;

  /// No description provided for @presetWidget_newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get presetWidget_newName;

  /// No description provided for @presetWidget_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get presetWidget_create;

  /// No description provided for @presetWidget_defaultProject.
  ///
  /// In en, this message translates to:
  /// **'Your project'**
  String get presetWidget_defaultProject;

  /// No description provided for @presetWidget_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get presetWidget_rename;

  /// No description provided for @presetWidget_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get presetWidget_cancel;

  /// No description provided for @presetWidget_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get presetWidget_confirm;

  /// No description provided for @presetWidget_addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get presetWidget_addToCart;

  /// No description provided for @presetWidget_preferredAmplifier.
  ///
  /// In en, this message translates to:
  /// **'Preferred amplifier'**
  String get presetWidget_preferredAmplifier;

  /// No description provided for @lightPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get lightPage_confirm;

  /// No description provided for @lightPage_noFixturesSelected.
  ///
  /// In en, this message translates to:
  /// **'No fixtures selected'**
  String get lightPage_noFixturesSelected;

  /// No description provided for @lightPage_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get lightPage_save;

  /// No description provided for @soundPage_amplificationTab.
  ///
  /// In en, this message translates to:
  /// **'Amplification'**
  String get soundPage_amplificationTab;

  /// No description provided for @soundPage_decibelMeterTab.
  ///
  /// In en, this message translates to:
  /// **'Decibel Meter'**
  String get soundPage_decibelMeterTab;

  /// No description provided for @soundPage_calculProjectTab.
  ///
  /// In en, this message translates to:
  /// **'Project Calculation'**
  String get soundPage_calculProjectTab;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }
  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale"');
}
