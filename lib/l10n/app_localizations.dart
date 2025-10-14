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
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
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
  /// **'Catalog'**
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
  /// **'Elec.'**
  String get electricityMenu;

  /// No description provided for @networkMenu.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkMenu;

  /// No description provided for @advancedMenu.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedMenu;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @amplifier.
  ///
  /// In en, this message translates to:
  /// **'Amplifier'**
  String get amplifier;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @stand.
  ///
  /// In en, this message translates to:
  /// **'Stand'**
  String get stand;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @lens.
  ///
  /// In en, this message translates to:
  /// **'Lens'**
  String get lens;

  /// No description provided for @projector.
  ///
  /// In en, this message translates to:
  /// **'Projector'**
  String get projector;

  /// No description provided for @screen.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screen;

  /// No description provided for @cable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get cable;

  /// No description provided for @connector.
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get connector;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @impedance.
  ///
  /// In en, this message translates to:
  /// **'Impedance'**
  String get impedance;

  /// No description provided for @sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get sensitivity;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @dmxTab.
  ///
  /// In en, this message translates to:
  /// **'DMX'**
  String get dmxTab;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search for a product...'**
  String get searchProduct;

  /// No description provided for @search_speaker.
  ///
  /// In en, this message translates to:
  /// **'Search for a speaker...'**
  String get search_speaker;

  /// No description provided for @view_preset.
  ///
  /// In en, this message translates to:
  /// **'View preset'**
  String get view_preset;

  /// No description provided for @rename_preset.
  ///
  /// In en, this message translates to:
  /// **'Rename preset'**
  String get rename_preset;

  /// No description provided for @delete_preset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get delete_preset;

  /// No description provided for @selectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Selected products:'**
  String get selectedProducts;

  /// No description provided for @dmxChannels.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get dmxChannels;

  /// No description provided for @calculateDmxUniverse.
  ///
  /// In en, this message translates to:
  /// **'Calculate DMX Universe'**
  String get calculateDmxUniverse;

  /// No description provided for @dmxConfiguration.
  ///
  /// In en, this message translates to:
  /// **'DMX Configuration:'**
  String get dmxConfiguration;

  /// No description provided for @universe.
  ///
  /// In en, this message translates to:
  /// **'Universe'**
  String get universe;

  /// No description provided for @exportConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Export Configuration'**
  String get exportConfiguration;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @driverTab.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverTab;

  /// No description provided for @driverConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Driver Configuration:'**
  String get driverConfiguration;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'channel'**
  String get channel;

  /// No description provided for @channelsPlural.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get channelsPlural;

  /// No description provided for @amperePerChannel.
  ///
  /// In en, this message translates to:
  /// **'Amperes/Channel'**
  String get amperePerChannel;

  /// No description provided for @driverType.
  ///
  /// In en, this message translates to:
  /// **'Driver Type'**
  String get driverType;

  /// No description provided for @stripLedConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Strip LED Configuration:'**
  String get stripLedConfiguration;

  /// No description provided for @stripLedType.
  ///
  /// In en, this message translates to:
  /// **'Strip LED Type'**
  String get stripLedType;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @calculateDriverConfig.
  ///
  /// In en, this message translates to:
  /// **'Calculate Driver Configuration'**
  String get calculateDriverConfig;

  /// No description provided for @recommendedConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Recommended Configuration:'**
  String get recommendedConfiguration;

  /// No description provided for @totalPower.
  ///
  /// In en, this message translates to:
  /// **'Total Power'**
  String get totalPower;

  /// No description provided for @totalCurrent.
  ///
  /// In en, this message translates to:
  /// **'Total current'**
  String get totalCurrent;

  /// No description provided for @availableCurrent.
  ///
  /// In en, this message translates to:
  /// **'Available current'**
  String get availableCurrent;

  /// No description provided for @safetyMargin.
  ///
  /// In en, this message translates to:
  /// **'Safety margin'**
  String get safetyMargin;

  /// No description provided for @beamTab.
  ///
  /// In en, this message translates to:
  /// **'Beam'**
  String get beamTab;

  /// No description provided for @beamCalculation.
  ///
  /// In en, this message translates to:
  /// **'Beam Calculation:'**
  String get beamCalculation;

  /// No description provided for @angleRange.
  ///
  /// In en, this message translates to:
  /// **'Beam angle'**
  String get angleRange;

  /// No description provided for @heightRange.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightRange;

  /// No description provided for @distanceRange.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceRange;

  /// No description provided for @beamDiameter.
  ///
  /// In en, this message translates to:
  /// **'Beam diameter'**
  String get beamDiameter;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @calculationResult.
  ///
  /// In en, this message translates to:
  /// **'Calculation Result:'**
  String get calculationResult;

  /// No description provided for @accessoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessoriesTab;

  /// No description provided for @lightAccessories.
  ///
  /// In en, this message translates to:
  /// **'Light Accessories:'**
  String get lightAccessories;

  /// No description provided for @thisSectionWillBeDeveloped.
  ///
  /// In en, this message translates to:
  /// **'This section will be developed to include:'**
  String get thisSectionWillBeDeveloped;

  /// No description provided for @trussesAndStructures.
  ///
  /// In en, this message translates to:
  /// **'Trusses and Structures'**
  String get trussesAndStructures;

  /// No description provided for @dmxCables.
  ///
  /// In en, this message translates to:
  /// **'DMX Cables'**
  String get dmxCables;

  /// No description provided for @connectors.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get connectors;

  /// No description provided for @protections.
  ///
  /// In en, this message translates to:
  /// **'Protections'**
  String get protections;

  /// No description provided for @mountingTools.
  ///
  /// In en, this message translates to:
  /// **'Mounting Tools'**
  String get mountingTools;

  /// No description provided for @safetyAccessories.
  ///
  /// In en, this message translates to:
  /// **'Safety Accessories'**
  String get safetyAccessories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @rgb.
  ///
  /// In en, this message translates to:
  /// **'RGB'**
  String get rgb;

  /// No description provided for @rgbw.
  ///
  /// In en, this message translates to:
  /// **'RGBW'**
  String get rgbw;

  /// No description provided for @rgbww.
  ///
  /// In en, this message translates to:
  /// **'RGBWW'**
  String get rgbww;

  /// No description provided for @ww.
  ///
  /// In en, this message translates to:
  /// **'WW'**
  String get ww;

  /// No description provided for @cw.
  ///
  /// In en, this message translates to:
  /// **'CW'**
  String get cw;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @volts.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get volts;

  /// No description provided for @amperes.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get amperes;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @lightPage_title.
  ///
  /// In en, this message translates to:
  /// **'Light Equipment'**
  String get lightPage_title;

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
  /// **'Selected Products'**
  String get lightPage_selectedProducts;

  /// No description provided for @lightPage_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get lightPage_reset;

  /// No description provided for @button_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get button_add;

  /// No description provided for @button_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get button_reset;

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

  /// No description provided for @lightPage_beamDiameter.
  ///
  /// In en, this message translates to:
  /// **'Beam diameter'**
  String get lightPage_beamDiameter;

  /// No description provided for @lightPage_meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get lightPage_meters;

  /// No description provided for @lightPage_recommendedConfig.
  ///
  /// In en, this message translates to:
  /// **'Recommended configuration'**
  String get lightPage_recommendedConfig;

  /// No description provided for @lightPage_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get lightPage_total;

  /// No description provided for @lightPage_dmxUniverses.
  ///
  /// In en, this message translates to:
  /// **'DMX UNIVERSES'**
  String get lightPage_dmxUniverses;

  /// No description provided for @arMeasurePage_title.
  ///
  /// In en, this message translates to:
  /// **'Photo/AR'**
  String get arMeasurePage_title;

  /// No description provided for @arMeasurePage_tapFirstPoint.
  ///
  /// In en, this message translates to:
  /// **'Tap the 1st point, then the 2nd'**
  String get arMeasurePage_tapFirstPoint;

  /// No description provided for @arMeasurePage_tapSecondPoint.
  ///
  /// In en, this message translates to:
  /// **'Tap the 2nd point to measure distance'**
  String get arMeasurePage_tapSecondPoint;

  /// No description provided for @arMeasurePage_tapObject.
  ///
  /// In en, this message translates to:
  /// **'Tap on an object to measure distance'**
  String get arMeasurePage_tapObject;

  /// No description provided for @arMeasurePage_tapDistance.
  ///
  /// In en, this message translates to:
  /// **'Tap/Distance'**
  String get arMeasurePage_tapDistance;

  /// No description provided for @arMeasurePage_modeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple mode'**
  String get arMeasurePage_modeSimple;

  /// No description provided for @arMeasurePage_modeTwoPoints.
  ///
  /// In en, this message translates to:
  /// **'2-point mode'**
  String get arMeasurePage_modeTwoPoints;

  /// No description provided for @arMeasurePage_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get arMeasurePage_reset;

  /// No description provided for @arMeasurePage_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get arMeasurePage_home;

  /// No description provided for @lightPage_universe.
  ///
  /// In en, this message translates to:
  /// **'UNIVERSE'**
  String get lightPage_universe;

  /// No description provided for @lightPage_fixture.
  ///
  /// In en, this message translates to:
  /// **'FIXTURE'**
  String get lightPage_fixture;

  /// No description provided for @lightPage_dmxChannelsUsed.
  ///
  /// In en, this message translates to:
  /// **'DMX channels used'**
  String get lightPage_dmxChannelsUsed;

  /// No description provided for @lightPage_channel.
  ///
  /// In en, this message translates to:
  /// **'channel'**
  String get lightPage_channel;

  /// No description provided for @lightPage_channels.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get lightPage_channels;

  /// No description provided for @soundPage_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Equipment'**
  String get soundPage_title;

  /// No description provided for @soundPage_amplificationTab.
  ///
  /// In en, this message translates to:
  /// **'Amplification'**
  String get soundPage_amplificationTab;

  /// No description provided for @soundPage_amplificationTabShort.
  ///
  /// In en, this message translates to:
  /// **'Amp'**
  String get soundPage_amplificationTabShort;

  /// No description provided for @soundPage_decibelMeterTab.
  ///
  /// In en, this message translates to:
  /// **'Decibel Meter'**
  String get soundPage_decibelMeterTab;

  /// No description provided for @soundPage_decibelMeterShort.
  ///
  /// In en, this message translates to:
  /// **'Decibel'**
  String get soundPage_decibelMeterShort;

  /// No description provided for @soundPage_patchSceneShort.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get soundPage_patchSceneShort;

  /// No description provided for @soundPage_calculProjectTab.
  ///
  /// In en, this message translates to:
  /// **'Project Calculation'**
  String get soundPage_calculProjectTab;

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

  /// No description provided for @soundPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get soundPage_confirm;

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

  /// No description provided for @soundPage_noSpeakersSelected.
  ///
  /// In en, this message translates to:
  /// **'No speakers selected'**
  String get soundPage_noSpeakersSelected;

  /// No description provided for @soundPage_power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get soundPage_power;

  /// No description provided for @soundPage_amplifier.
  ///
  /// In en, this message translates to:
  /// **'Amplifier'**
  String get soundPage_amplifier;

  /// No description provided for @soundPage_capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get soundPage_capacity;

  /// No description provided for @soundPage_speakersPerChannel.
  ///
  /// In en, this message translates to:
  /// **'speakers/channel'**
  String get soundPage_speakersPerChannel;

  /// No description provided for @soundPage_speakersPerAmp.
  ///
  /// In en, this message translates to:
  /// **'speakers/amp'**
  String get soundPage_speakersPerAmp;

  /// No description provided for @soundPage_amplifiersRequired.
  ///
  /// In en, this message translates to:
  /// **'Amplifiers required'**
  String get soundPage_amplifiersRequired;

  /// No description provided for @soundPage_with.
  ///
  /// In en, this message translates to:
  /// **'with'**
  String get soundPage_with;

  /// No description provided for @soundPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get soundPage_noPresetSelected;

  /// No description provided for @rider_technical_title.
  ///
  /// In en, this message translates to:
  /// **'Technical Rider'**
  String get rider_technical_title;

  /// No description provided for @videoPage_title.
  ///
  /// In en, this message translates to:
  /// **'Video Equipment'**
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

  /// No description provided for @videoPage_searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get videoPage_searchProduct;

  /// No description provided for @videoPage_selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select brand'**
  String get videoPage_selectBrand;

  /// No description provided for @videoPage_selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get videoPage_selectProduct;

  /// No description provided for @videoPage_format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get videoPage_format;

  /// No description provided for @videoPage_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get videoPage_model;

  /// No description provided for @videoPage_selectLedWall.
  ///
  /// In en, this message translates to:
  /// **'Select LED Panel'**
  String get videoPage_selectLedWall;

  /// No description provided for @videoPage_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get videoPage_brand;

  /// No description provided for @videoPage_projectionCalculation.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get videoPage_projectionCalculation;

  /// No description provided for @videoPage_ledWallCalculation.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get videoPage_ledWallCalculation;

  /// No description provided for @videoPage_ar.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get videoPage_ar;

  /// No description provided for @videoPage_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get videoPage_calculate;

  /// No description provided for @soundPage_ampConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended amp config:'**
  String get soundPage_ampConfigTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @videoPage_projectorCount.
  ///
  /// In en, this message translates to:
  /// **'Projector Count'**
  String get videoPage_projectorCount;

  /// No description provided for @videoPage_overlap.
  ///
  /// In en, this message translates to:
  /// **'Overlap'**
  String get videoPage_overlap;

  /// No description provided for @videoPage_imageWidth.
  ///
  /// In en, this message translates to:
  /// **'Image width'**
  String get videoPage_imageWidth;

  /// No description provided for @videoPage_projectorDistance.
  ///
  /// In en, this message translates to:
  /// **'Projector distance'**
  String get videoPage_projectorDistance;

  /// No description provided for @videoPage_ratio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get videoPage_ratio;

  /// No description provided for @videoPage_recommendedRatio.
  ///
  /// In en, this message translates to:
  /// **'Recommended ratio'**
  String get videoPage_recommendedRatio;

  /// No description provided for @videoPage_noOpticsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No optics available for this ratio'**
  String get videoPage_noOpticsAvailable;

  /// No description provided for @videoPage_schema.
  ///
  /// In en, this message translates to:
  /// **'Schema'**
  String get videoPage_schema;

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
  String distance_label(String distance);

  /// No description provided for @charge_max.
  ///
  /// In en, this message translates to:
  /// **'Max load: {value} kg{unit}'**
  String charge_max(String value, String unit);

  /// No description provided for @beam_weight.
  ///
  /// In en, this message translates to:
  /// **'Beam weight (excluding loads): {value} kg'**
  String beam_weight(String value);

  /// No description provided for @max_deflection.
  ///
  /// In en, this message translates to:
  /// **'Maximum deflection: {value} mm'**
  String max_deflection(String value);

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

  /// No description provided for @catalogPage_selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get catalogPage_selectCategory;

  /// No description provided for @catalogPage_selectSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Sub-Category'**
  String get catalogPage_selectSubCategory;

  /// No description provided for @catalogPage_noItems.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get catalogPage_noItems;

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

  /// No description provided for @projectCalculationPage_powerTab.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get projectCalculationPage_powerTab;

  /// No description provided for @projectCalculationPage_weightTab.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get projectCalculationPage_weightTab;

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

  /// No description provided for @ledWallSchemaPage_title.
  ///
  /// In en, this message translates to:
  /// **'LED Wall Schema'**
  String get ledWallSchemaPage_title;

  /// No description provided for @ledWallSchemaPage_dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get ledWallSchemaPage_dimensions;

  /// No description provided for @ledWallSchemaPage_width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get ledWallSchemaPage_width;

  /// No description provided for @ledWallSchemaPage_height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get ledWallSchemaPage_height;

  /// No description provided for @ledWallSchemaPage_panelSelection.
  ///
  /// In en, this message translates to:
  /// **'Panel Selection'**
  String get ledWallSchemaPage_panelSelection;

  /// No description provided for @ledWallSchemaPage_selectPanel.
  ///
  /// In en, this message translates to:
  /// **'Select Panel'**
  String get ledWallSchemaPage_selectPanel;

  /// No description provided for @ledWallSchemaPage_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get ledWallSchemaPage_calculate;

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

  /// No description provided for @speedtest_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get speedtest_ready;

  /// No description provided for @speedtest_downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get speedtest_downloading;

  /// No description provided for @speedtest_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get speedtest_uploading;

  /// No description provided for @speedtest_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get speedtest_completed;

  /// No description provided for @speedtest_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get speedtest_download;

  /// No description provided for @speedtest_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get speedtest_upload;

  /// No description provided for @speedtest_running.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get speedtest_running;

  /// No description provided for @speedtest_start.
  ///
  /// In en, this message translates to:
  /// **'Start (8s)'**
  String get speedtest_start;

  /// No description provided for @speedtest_mbps.
  ///
  /// In en, this message translates to:
  /// **'Mbps'**
  String get speedtest_mbps;

  /// No description provided for @speedtest_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedtest_speed;

  /// No description provided for @arMeasure_photoAr.
  ///
  /// In en, this message translates to:
  /// **'Photo/AR'**
  String get arMeasure_photoAr;

  /// No description provided for @arMeasure_takePhotosAndMeasure.
  ///
  /// In en, this message translates to:
  /// **'Take reference photos and launch AR measurements'**
  String get arMeasure_takePhotosAndMeasure;

  /// No description provided for @arMeasure_capturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing...'**
  String get arMeasure_capturing;

  /// No description provided for @arMeasure_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get arMeasure_photo;

  /// No description provided for @arMeasure_unity.
  ///
  /// In en, this message translates to:
  /// **'Unity'**
  String get arMeasure_unity;

  /// No description provided for @arMeasure_photosAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photos are automatically saved in the active project folder'**
  String get arMeasure_photosAutoSaved;

  /// No description provided for @arMeasure_photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved in project!'**
  String get arMeasure_photoSaved;

  /// No description provided for @arMeasure_captureError.
  ///
  /// In en, this message translates to:
  /// **'Error during capture'**
  String get arMeasure_captureError;

  /// No description provided for @arMeasure_saveError.
  ///
  /// In en, this message translates to:
  /// **'Error during save'**
  String get arMeasure_saveError;

  /// No description provided for @arMeasure_defaultProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get arMeasure_defaultProject;

  /// No description provided for @arMeasure_photoFileName.
  ///
  /// In en, this message translates to:
  /// **'Photo_AR_{projectName}_{timestamp}.jpg'**
  String arMeasure_photoFileName(Object projectName, Object timestamp);

  /// No description provided for @bottomNav_catalogue.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get bottomNav_catalogue;

  /// No description provided for @bottomNav_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get bottomNav_light;

  /// No description provided for @bottomNav_structure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get bottomNav_structure;

  /// No description provided for @bottomNav_sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get bottomNav_sound;

  /// No description provided for @bottomNav_video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get bottomNav_video;

  /// No description provided for @bottomNav_electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get bottomNav_electricity;

  /// No description provided for @bottomNav_misc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get bottomNav_misc;

  /// No description provided for @bottomNav_arMeasure.
  ///
  /// In en, this message translates to:
  /// **'AR Measure'**
  String get bottomNav_arMeasure;

  /// No description provided for @subscription_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscription_premium;

  /// No description provided for @subscription_description.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get subscription_description;

  /// No description provided for @subscription_choose_plan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get subscription_choose_plan;

  /// No description provided for @subscription_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get subscription_popular;

  /// No description provided for @subscription_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscription_subscribe;

  /// No description provided for @subscription_free_trial.
  ///
  /// In en, this message translates to:
  /// **'Enjoy 30 days free'**
  String get subscription_free_trial;

  /// No description provided for @subscription_free_trial_started.
  ///
  /// In en, this message translates to:
  /// **'Free trial started!'**
  String get subscription_free_trial_started;

  /// No description provided for @subscription_free_trial_error.
  ///
  /// In en, this message translates to:
  /// **'Error starting free trial'**
  String get subscription_free_trial_error;

  /// No description provided for @subscription_security.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get subscription_security;

  /// No description provided for @subscription_security_description.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected by bank-level encryption'**
  String get subscription_security_description;

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
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset Application'**
  String get resetApp;

  /// No description provided for @resetAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Removes all local data and simulates first visit'**
  String get resetAppDescription;

  /// No description provided for @resetUserData.
  ///
  /// In en, this message translates to:
  /// **'Reset User Data'**
  String get resetUserData;

  /// No description provided for @resetUserDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Removes only user data (projects, cart, etc.)'**
  String get resetUserDataDescription;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the application? This action is irreversible.'**
  String get resetConfirmMessage;

  /// No description provided for @resetUserDataConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your user data? This action is irreversible.'**
  String get resetUserDataConfirmMessage;

  /// No description provided for @resetComplete.
  ///
  /// In en, this message translates to:
  /// **'Reset completed'**
  String get resetComplete;

  /// No description provided for @resetError.
  ///
  /// In en, this message translates to:
  /// **'Error during reset'**
  String get resetError;

  /// No description provided for @patchScenePage_title.
  ///
  /// In en, this message translates to:
  /// **'Patch Scene'**
  String get patchScenePage_title;

  /// No description provided for @patchScenePage_createPatch.
  ///
  /// In en, this message translates to:
  /// **'Create your patch!'**
  String get patchScenePage_createPatch;

  /// No description provided for @patchScenePage_input.
  ///
  /// In en, this message translates to:
  /// **'INPUT'**
  String get patchScenePage_input;

  /// No description provided for @patchScenePage_output.
  ///
  /// In en, this message translates to:
  /// **'OUTPUT'**
  String get patchScenePage_output;

  /// No description provided for @patchScenePage_track.
  ///
  /// In en, this message translates to:
  /// **'TRACK'**
  String get patchScenePage_track;

  /// No description provided for @patchScenePage_track1.
  ///
  /// In en, this message translates to:
  /// **'TRACK 1'**
  String get patchScenePage_track1;

  /// No description provided for @patchScenePage_instrument_dj.
  ///
  /// In en, this message translates to:
  /// **'DJ'**
  String get patchScenePage_instrument_dj;

  /// No description provided for @patchScenePage_instrument_voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get patchScenePage_instrument_voice;

  /// No description provided for @patchScenePage_instrument_piano.
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get patchScenePage_instrument_piano;

  /// No description provided for @patchScenePage_instrument_drums.
  ///
  /// In en, this message translates to:
  /// **'Drums'**
  String get patchScenePage_instrument_drums;

  /// No description provided for @patchScenePage_instrument_bass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get patchScenePage_instrument_bass;

  /// No description provided for @patchScenePage_instrument_guitar.
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get patchScenePage_instrument_guitar;

  /// No description provided for @patchScenePage_instrument_brass.
  ///
  /// In en, this message translates to:
  /// **'Brass'**
  String get patchScenePage_instrument_brass;

  /// No description provided for @patchScenePage_instrument_violin.
  ///
  /// In en, this message translates to:
  /// **'Violin'**
  String get patchScenePage_instrument_violin;

  /// No description provided for @patchScenePage_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get patchScenePage_quantity;

  /// No description provided for @patchScenePage_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get patchScenePage_rename;

  /// No description provided for @patchScenePage_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get patchScenePage_delete;

  /// No description provided for @patchScenePage_newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get patchScenePage_newName;

  /// No description provided for @patchScenePage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get patchScenePage_confirm;

  /// No description provided for @patchScenePage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get patchScenePage_cancel;

  /// No description provided for @patch_title.
  ///
  /// In en, this message translates to:
  /// **'Stage Patch'**
  String get patch_title;

  /// No description provided for @patch_input.
  ///
  /// In en, this message translates to:
  /// **'INPUT'**
  String get patch_input;

  /// No description provided for @patch_output.
  ///
  /// In en, this message translates to:
  /// **'OUTPUT'**
  String get patch_output;

  /// No description provided for @patch_add_track.
  ///
  /// In en, this message translates to:
  /// **'Add track'**
  String get patch_add_track;

  /// No description provided for @patch_ajout.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get patch_ajout;

  /// No description provided for @structurePage_distance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} m'**
  String structurePage_distance(Object distance);

  /// No description provided for @structurePage_chargeRepartie.
  ///
  /// In en, this message translates to:
  /// **'Uniformly distributed load'**
  String get structurePage_chargeRepartie;

  /// No description provided for @structurePage_pointAccrocheCentre.
  ///
  /// In en, this message translates to:
  /// **'1 attachment point at center'**
  String get structurePage_pointAccrocheCentre;

  /// No description provided for @structurePage_pointsAccrocheExtremites.
  ///
  /// In en, this message translates to:
  /// **'2 attachment points at ends'**
  String get structurePage_pointsAccrocheExtremites;

  /// No description provided for @structurePage_3pointsAccroche.
  ///
  /// In en, this message translates to:
  /// **'3 attachment points'**
  String get structurePage_3pointsAccroche;

  /// No description provided for @structurePage_4pointsAccroche.
  ///
  /// In en, this message translates to:
  /// **'4 attachment points'**
  String get structurePage_4pointsAccroche;

  /// No description provided for @structurePage_chargeMaximale.
  ///
  /// In en, this message translates to:
  /// **'Maximum load'**
  String get structurePage_chargeMaximale;

  /// No description provided for @structurePage_poidsStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure weight'**
  String get structurePage_poidsStructure;

  /// No description provided for @structurePage_flecheMaximale.
  ///
  /// In en, this message translates to:
  /// **'Maximum deflection'**
  String get structurePage_flecheMaximale;

  /// No description provided for @structurePage_ratioFleche.
  ///
  /// In en, this message translates to:
  /// **'Deflection ratio'**
  String get structurePage_ratioFleche;

  /// No description provided for @structurePage_annuler.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get structurePage_annuler;

  /// No description provided for @structurePage_quantite.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get structurePage_quantite;

  /// No description provided for @structurePage_modifier.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get structurePage_modifier;

  /// No description provided for @projectPage_title.
  ///
  /// In en, this message translates to:
  /// **'View Project'**
  String get projectPage_title;

  /// No description provided for @projectPage_powerTab.
  ///
  /// In en, this message translates to:
  /// **'Project Power'**
  String get projectPage_powerTab;

  /// No description provided for @projectPage_weightTab.
  ///
  /// In en, this message translates to:
  /// **'Project Weight'**
  String get projectPage_weightTab;

  /// No description provided for @projectPage_totalArticles.
  ///
  /// In en, this message translates to:
  /// **'Total articles'**
  String get projectPage_totalArticles;

  /// No description provided for @projectPage_totalPower.
  ///
  /// In en, this message translates to:
  /// **'Total Power'**
  String get projectPage_totalPower;

  /// No description provided for @projectPage_totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get projectPage_totalWeight;

  /// No description provided for @projectPage_preset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get projectPage_preset;

  /// No description provided for @projectPage_articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get projectPage_articles;

  /// No description provided for @projectPage_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get projectPage_quantity;

  /// No description provided for @projectPage_power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get projectPage_power;

  /// No description provided for @projectPage_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get projectPage_weight;

  /// No description provided for @projectPage_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get projectPage_category;

  /// No description provided for @projectPage_exportCount.
  ///
  /// In en, this message translates to:
  /// **'Export count'**
  String get projectPage_exportCount;

  /// No description provided for @projectPage_searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for an article...'**
  String get projectPage_searchPlaceholder;

  /// No description provided for @projectPage_searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get projectPage_searchResults;

  /// No description provided for @projectPage_modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get projectPage_modify;

  /// No description provided for @projectPage_addToPreset.
  ///
  /// In en, this message translates to:
  /// **'Add to preset'**
  String get projectPage_addToPreset;

  /// No description provided for @projectPage_enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get projectPage_enterQuantity;

  /// No description provided for @projectPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get projectPage_confirm;

  /// No description provided for @projectPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get projectPage_cancel;

  /// No description provided for @projectPage_powerTabShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get projectPage_powerTabShort;

  /// No description provided for @projectPage_weightTabShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get projectPage_weightTabShort;

  /// No description provided for @defaultProjectName.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get defaultProjectName;

  /// No description provided for @defaultPresetName.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get defaultPresetName;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @saveProject.
  ///
  /// In en, this message translates to:
  /// **'Save Project'**
  String get saveProject;

  /// No description provided for @loadProject.
  ///
  /// In en, this message translates to:
  /// **'Load Project'**
  String get loadProject;

  /// No description provided for @exportProject.
  ///
  /// In en, this message translates to:
  /// **'Export Project'**
  String get exportProject;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New project name'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Rock Festival, Theater...'**
  String get projectNameHint;

  /// No description provided for @projectArchiveInfo.
  ///
  /// In en, this message translates to:
  /// **'The old project will be automatically archived.'**
  String get projectArchiveInfo;

  /// No description provided for @projectSaved.
  ///
  /// In en, this message translates to:
  /// **'Project saved!'**
  String get projectSaved;

  /// No description provided for @noProjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No projects available to load'**
  String get noProjectsAvailable;

  /// No description provided for @selectProjectToLoad.
  ///
  /// In en, this message translates to:
  /// **'Select a project to load:'**
  String get selectProjectToLoad;

  /// No description provided for @projectExportTitle.
  ///
  /// In en, this message translates to:
  /// **'PROJECT: {name}'**
  String projectExportTitle(Object name);

  /// No description provided for @exportDate.
  ///
  /// In en, this message translates to:
  /// **'Export date: {date}'**
  String exportDate(Object date);

  /// No description provided for @presetsToExport.
  ///
  /// In en, this message translates to:
  /// **'{count} preset{count, plural, =1 {} other {s}} to export'**
  String presetsToExport(num count);

  /// No description provided for @defaultProject1.
  ///
  /// In en, this message translates to:
  /// **'Project 1'**
  String get defaultProject1;

  /// No description provided for @defaultProject2.
  ///
  /// In en, this message translates to:
  /// **'Project 2'**
  String get defaultProject2;

  /// No description provided for @defaultProject3.
  ///
  /// In en, this message translates to:
  /// **'Project 3'**
  String get defaultProject3;

  /// No description provided for @presetView.
  ///
  /// In en, this message translates to:
  /// **'View Preset'**
  String get presetView;

  /// No description provided for @presetRename.
  ///
  /// In en, this message translates to:
  /// **'Rename Preset'**
  String get presetRename;

  /// No description provided for @presetDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get presetDelete;

  /// No description provided for @presetDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Preset'**
  String get presetDuplicate;

  /// No description provided for @presetNew.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get presetNew;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset Name'**
  String get presetName;

  /// No description provided for @presetEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter preset name'**
  String get presetEnterName;

  /// No description provided for @presetRenameTo.
  ///
  /// In en, this message translates to:
  /// **'Rename to'**
  String get presetRenameTo;

  /// No description provided for @presetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted'**
  String get presetDeleted;

  /// No description provided for @presetRenamed.
  ///
  /// In en, this message translates to:
  /// **'Preset renamed'**
  String get presetRenamed;

  /// No description provided for @presetCreated.
  ///
  /// In en, this message translates to:
  /// **'Preset created'**
  String get presetCreated;

  /// No description provided for @presetLoad.
  ///
  /// In en, this message translates to:
  /// **'Load Preset'**
  String get presetLoad;

  /// No description provided for @presetSave.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get presetSave;

  /// No description provided for @presetExport.
  ///
  /// In en, this message translates to:
  /// **'Export Preset'**
  String get presetExport;

  /// No description provided for @presetImport.
  ///
  /// In en, this message translates to:
  /// **'Import Preset'**
  String get presetImport;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @renameProject.
  ///
  /// In en, this message translates to:
  /// **'Rename Project'**
  String get renameProject;

  /// No description provided for @enterProjectName.
  ///
  /// In en, this message translates to:
  /// **'New project name'**
  String get enterProjectName;

  /// No description provided for @projectRenamed.
  ///
  /// In en, this message translates to:
  /// **'Project renamed to'**
  String get projectRenamed;

  /// No description provided for @noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get noPresetSelected;

  /// No description provided for @searchArticlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for an article...'**
  String get searchArticlePlaceholder;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @presetCount.
  ///
  /// In en, this message translates to:
  /// **'Preset count'**
  String get presetCount;

  /// No description provided for @totalArticlesCount.
  ///
  /// In en, this message translates to:
  /// **'Total articles count'**
  String get totalArticlesCount;

  /// No description provided for @exportCount.
  ///
  /// In en, this message translates to:
  /// **'Export count'**
  String get exportCount;

  /// No description provided for @presetCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get presetCategory;

  /// No description provided for @articleName.
  ///
  /// In en, this message translates to:
  /// **'Article name'**
  String get articleName;

  /// No description provided for @totalPreset.
  ///
  /// In en, this message translates to:
  /// **'Total Preset'**
  String get totalPreset;

  /// No description provided for @totalProject.
  ///
  /// In en, this message translates to:
  /// **'Total Project'**
  String get totalProject;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get totalWeight;

  /// No description provided for @unitWatt.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get unitWatt;

  /// No description provided for @unitKilowatt.
  ///
  /// In en, this message translates to:
  /// **'kW'**
  String get unitKilowatt;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// No description provided for @addToPreset.
  ///
  /// In en, this message translates to:
  /// **'Add to preset'**
  String get addToPreset;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @patch_instrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get patch_instrument;

  /// No description provided for @patch_destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get patch_destination;

  /// No description provided for @patch_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get patch_type;

  /// No description provided for @patch_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get patch_quantity;

  /// No description provided for @patch_track_name.
  ///
  /// In en, this message translates to:
  /// **'Track name'**
  String get patch_track_name;

  /// No description provided for @patch_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get patch_rename;

  /// No description provided for @patch_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get patch_delete;

  /// No description provided for @patch_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get patch_cancel;

  /// No description provided for @patch_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get patch_confirm;

  /// No description provided for @patch_export_png.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get patch_export_png;

  /// No description provided for @patch_export_csv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get patch_export_csv;

  /// No description provided for @patch_saved_to.
  ///
  /// In en, this message translates to:
  /// **'Saved to: {path}'**
  String patch_saved_to(Object path);

  /// No description provided for @patch_export_failed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get patch_export_failed;

  /// No description provided for @patch_no_entries.
  ///
  /// In en, this message translates to:
  /// **'No tracks'**
  String get patch_no_entries;

  /// No description provided for @patch_number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get patch_number;

  /// No description provided for @patch_source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get patch_source;

  /// No description provided for @patch_microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get patch_microphone;

  /// No description provided for @patch_output_dest.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get patch_output_dest;

  /// No description provided for @patch_output_kind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get patch_output_kind;

  /// No description provided for @loginMenu_accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get loginMenu_accountSettings;

  /// No description provided for @loginMenu_myProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get loginMenu_myProjects;

  /// No description provided for @loginMenu_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get loginMenu_logout;

  /// No description provided for @dmxPage_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a product...'**
  String get dmxPage_searchHint;

  /// No description provided for @dmxPage_dmxType.
  ///
  /// In en, this message translates to:
  /// **'DMX Type'**
  String get dmxPage_dmxType;

  /// No description provided for @dmxPage_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'DMX Mini'**
  String get dmxPage_dmxMini;

  /// No description provided for @dmxPage_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'DMX Max'**
  String get dmxPage_dmxMax;

  /// No description provided for @dmxPage_quantityEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get dmxPage_quantityEnter;

  /// No description provided for @dmxPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dmxPage_cancel;

  /// No description provided for @dmxPage_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dmxPage_ok;

  /// No description provided for @dmxPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dmxPage_confirm;

  /// No description provided for @dmxPage_selectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Selected products:'**
  String get dmxPage_selectedProducts;

  /// No description provided for @dmxPage_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get dmxPage_calculate;

  /// No description provided for @dmxPage_add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get dmxPage_add;

  /// No description provided for @dmxPage_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dmxPage_reset;

  /// No description provided for @dmxPage_importPreset.
  ///
  /// In en, this message translates to:
  /// **'Import Preset'**
  String get dmxPage_importPreset;

  /// No description provided for @dmxPage_noProductsSelected.
  ///
  /// In en, this message translates to:
  /// **'No products selected'**
  String get dmxPage_noProductsSelected;

  /// No description provided for @dmxPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get dmxPage_noPresetSelected;

  /// No description provided for @dmxPage_noPresetAvailable.
  ///
  /// In en, this message translates to:
  /// **'No presets available to import'**
  String get dmxPage_noPresetAvailable;

  /// No description provided for @dmxPage_productsAddedToPreset.
  ///
  /// In en, this message translates to:
  /// **'product(s) added to preset'**
  String get dmxPage_productsAddedToPreset;

  /// No description provided for @dmxPage_selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select a preset'**
  String get dmxPage_selectPreset;

  /// No description provided for @dmxPage_lightDevices.
  ///
  /// In en, this message translates to:
  /// **'light device(s)'**
  String get dmxPage_lightDevices;

  /// No description provided for @dmxPage_importedFromPreset.
  ///
  /// In en, this message translates to:
  /// **'device(s) imported from'**
  String get dmxPage_importedFromPreset;

  /// No description provided for @dmxPage_universesNeeded.
  ///
  /// In en, this message translates to:
  /// **'universes required'**
  String get dmxPage_universesNeeded;

  /// No description provided for @dmxPage_universe.
  ///
  /// In en, this message translates to:
  /// **'Universe'**
  String get dmxPage_universe;

  /// No description provided for @dmxPage_channelsUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get dmxPage_channelsUsed;

  /// No description provided for @dmxPage_channelsTotal.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get dmxPage_channelsTotal;

  /// No description provided for @dmxPage_mapDmx.
  ///
  /// In en, this message translates to:
  /// **'DMX Map'**
  String get dmxPage_mapDmx;

  /// No description provided for @dmxPage_lightCategory.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get dmxPage_lightCategory;

  /// No description provided for @dmxPage_allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dmxPage_allCategories;

  /// No description provided for @dmxPage_movingHead.
  ///
  /// In en, this message translates to:
  /// **'Moving Head'**
  String get dmxPage_movingHead;

  /// No description provided for @dmxPage_ledBar.
  ///
  /// In en, this message translates to:
  /// **'LED Bar'**
  String get dmxPage_ledBar;

  /// No description provided for @dmxPage_strobe.
  ///
  /// In en, this message translates to:
  /// **'Strobe'**
  String get dmxPage_strobe;

  /// No description provided for @dmxPage_scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get dmxPage_scanner;

  /// No description provided for @dmxPage_wash.
  ///
  /// In en, this message translates to:
  /// **'Wash'**
  String get dmxPage_wash;

  /// No description provided for @dmxPage_wired.
  ///
  /// In en, this message translates to:
  /// **'Wired'**
  String get dmxPage_wired;

  /// No description provided for @driverTab_title.
  ///
  /// In en, this message translates to:
  /// **'LED Driver Configuration'**
  String get driverTab_title;

  /// No description provided for @driverTab_ledLength.
  ///
  /// In en, this message translates to:
  /// **'LED strip length'**
  String get driverTab_ledLength;

  /// No description provided for @driverTab_ledType.
  ///
  /// In en, this message translates to:
  /// **'LED strip type'**
  String get driverTab_ledType;

  /// No description provided for @driverTab_ledPower.
  ///
  /// In en, this message translates to:
  /// **'LED strip power'**
  String get driverTab_ledPower;

  /// No description provided for @driverTab_driverChoice.
  ///
  /// In en, this message translates to:
  /// **'Driver choice'**
  String get driverTab_driverChoice;

  /// No description provided for @driverTab_ledType_white.
  ///
  /// In en, this message translates to:
  /// **'White (W)'**
  String get driverTab_ledType_white;

  /// No description provided for @driverTab_ledType_biWhite.
  ///
  /// In en, this message translates to:
  /// **'Bi-White (WW)'**
  String get driverTab_ledType_biWhite;

  /// No description provided for @driverTab_ledType_rgb.
  ///
  /// In en, this message translates to:
  /// **'RGB'**
  String get driverTab_ledType_rgb;

  /// No description provided for @driverTab_ledType_rgbw.
  ///
  /// In en, this message translates to:
  /// **'RGBW'**
  String get driverTab_ledType_rgbw;

  /// No description provided for @driverTab_ledType_rgbww.
  ///
  /// In en, this message translates to:
  /// **'RGBWW'**
  String get driverTab_ledType_rgbww;

  /// No description provided for @driverTab_customDriver.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get driverTab_customDriver;

  /// No description provided for @driverTab_customDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Driver Configuration'**
  String get driverTab_customDriverTitle;

  /// No description provided for @driverTab_customDriverChannels.
  ///
  /// In en, this message translates to:
  /// **'Number of channels'**
  String get driverTab_customDriverChannels;

  /// No description provided for @driverTab_customDriverIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity per channel (A)'**
  String get driverTab_customDriverIntensity;

  /// No description provided for @driverTab_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get driverTab_calculate;

  /// No description provided for @driverTab_result.
  ///
  /// In en, this message translates to:
  /// **'Calculation result'**
  String get driverTab_result;

  /// No description provided for @structurePage_chargesTab.
  ///
  /// In en, this message translates to:
  /// **'Charges'**
  String get structurePage_chargesTab;

  /// No description provided for @structurePage_projectWeightTab.
  ///
  /// In en, this message translates to:
  /// **'Weight Project'**
  String get structurePage_projectWeightTab;

  /// No description provided for @structurePage_maxLoad.
  ///
  /// In en, this message translates to:
  /// **'Maximum load: {value} kg{unit}'**
  String structurePage_maxLoad(Object unit, Object value);

  /// No description provided for @structurePage_structureWeight.
  ///
  /// In en, this message translates to:
  /// **'Structure weight: {value} kg/m'**
  String structurePage_structureWeight(Object value);

  /// No description provided for @structurePage_maxDeflection.
  ///
  /// In en, this message translates to:
  /// **'Maximum deflection: {value} mm'**
  String structurePage_maxDeflection(Object value);

  /// No description provided for @structurePage_deflectionRatio.
  ///
  /// In en, this message translates to:
  /// **'Deflection ratio: 1/{ratio}'**
  String structurePage_deflectionRatio(Object ratio);

  /// No description provided for @structurePage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get structurePage_noPresetSelected;

  /// No description provided for @structurePage_structure.
  ///
  /// In en, this message translates to:
  /// **'Structure:'**
  String get structurePage_structure;

  /// No description provided for @structurePage_length.
  ///
  /// In en, this message translates to:
  /// **'Length:'**
  String get structurePage_length;

  /// No description provided for @structurePage_chargeType.
  ///
  /// In en, this message translates to:
  /// **'Load type:'**
  String get structurePage_chargeType;

  /// No description provided for @structurePage_maxLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum load'**
  String get structurePage_maxLoadTitle;

  /// No description provided for @structurePage_structureWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Structure weight'**
  String get structurePage_structureWeightTitle;

  /// No description provided for @structurePage_maxDeflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum deflection'**
  String get structurePage_maxDeflectionTitle;

  /// No description provided for @structurePage_deflectionRatioTitle.
  ///
  /// In en, this message translates to:
  /// **'Deflection ratio'**
  String get structurePage_deflectionRatioTitle;

  /// No description provided for @catalogue_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get catalogue_brand;

  /// No description provided for @catalogue_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get catalogue_description;

  /// No description provided for @catalogue_dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get catalogue_dimensions;

  /// No description provided for @catalogue_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get catalogue_weight;

  /// No description provided for @catalogue_consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get catalogue_consumption;

  /// No description provided for @catalogue_angle.
  ///
  /// In en, this message translates to:
  /// **'Projection angle'**
  String get catalogue_angle;

  /// No description provided for @catalogue_lux.
  ///
  /// In en, this message translates to:
  /// **'Lux'**
  String get catalogue_lux;

  /// No description provided for @catalogue_lumens.
  ///
  /// In en, this message translates to:
  /// **'Lumens'**
  String get catalogue_lumens;

  /// No description provided for @catalogue_definition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get catalogue_definition;

  /// No description provided for @catalogue_resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get catalogue_resolution;

  /// No description provided for @catalogue_pitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get catalogue_pitch;

  /// No description provided for @catalogue_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'DMX Max'**
  String get catalogue_dmxMax;

  /// No description provided for @catalogue_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'DMX Mini'**
  String get catalogue_dmxMini;

  /// No description provided for @catalogue_powerAdmissible.
  ///
  /// In en, this message translates to:
  /// **'Admissible power'**
  String get catalogue_powerAdmissible;

  /// No description provided for @catalogue_impedanceNominal.
  ///
  /// In en, this message translates to:
  /// **'Nominal impedance'**
  String get catalogue_impedanceNominal;

  /// No description provided for @catalogue_impedance.
  ///
  /// In en, this message translates to:
  /// **'Impedance'**
  String get catalogue_impedance;

  /// No description provided for @catalogue_powerRms.
  ///
  /// In en, this message translates to:
  /// **'RMS Power'**
  String get catalogue_powerRms;

  /// No description provided for @catalogue_powerProgram.
  ///
  /// In en, this message translates to:
  /// **'Program Power'**
  String get catalogue_powerProgram;

  /// No description provided for @catalogue_powerPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Power'**
  String get catalogue_powerPeak;

  /// No description provided for @catalogue_maxVoltage.
  ///
  /// In en, this message translates to:
  /// **'Max voltage'**
  String get catalogue_maxVoltage;

  /// No description provided for @catalogue_lensesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available projection lenses'**
  String get catalogue_lensesAvailable;

  /// No description provided for @catalogue_projectionRatio.
  ///
  /// In en, this message translates to:
  /// **'Projection ratio'**
  String get catalogue_projectionRatio;

  /// No description provided for @videoLedResult_dalles.
  ///
  /// In en, this message translates to:
  /// **'panels'**
  String get videoLedResult_dalles;

  /// No description provided for @videoLedResult_espacePixellaire.
  ///
  /// In en, this message translates to:
  /// **'Pixel space'**
  String get videoLedResult_espacePixellaire;

  /// No description provided for @videoLedResult_poidsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get videoLedResult_poidsTotal;

  /// No description provided for @videoLedResult_consommationTotale.
  ///
  /// In en, this message translates to:
  /// **'Total consumption'**
  String get videoLedResult_consommationTotale;

  /// No description provided for @arMeasurePage_description.
  ///
  /// In en, this message translates to:
  /// **'Take reference photos and launch AR measurements'**
  String get arMeasurePage_description;

  /// No description provided for @arMeasurePage_photoButton.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get arMeasurePage_photoButton;

  /// No description provided for @arMeasurePage_unityButton.
  ///
  /// In en, this message translates to:
  /// **'Unity'**
  String get arMeasurePage_unityButton;

  /// No description provided for @arMeasurePage_captureInProgress.
  ///
  /// In en, this message translates to:
  /// **'Capturing...'**
  String get arMeasurePage_captureInProgress;

  /// No description provided for @arMeasurePage_cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permissions required'**
  String get arMeasurePage_cameraPermissionRequired;

  /// No description provided for @arMeasurePage_photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved in project!'**
  String get arMeasurePage_photoSaved;

  /// No description provided for @arMeasurePage_errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get arMeasurePage_errorMessage;

  /// No description provided for @arMeasurePage_photosAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photos are automatically saved in the active project folder'**
  String get arMeasurePage_photosAutoSaved;

  /// No description provided for @arMeasurePage_takeReferencePhotos.
  ///
  /// In en, this message translates to:
  /// **'Take reference photos and launch AR measurements'**
  String get arMeasurePage_takeReferencePhotos;

  /// No description provided for @arMeasurePage_photosAutoSavedInfo.
  ///
  /// In en, this message translates to:
  /// **'Photos are automatically saved in the active project folder'**
  String get arMeasurePage_photosAutoSavedInfo;

  /// No description provided for @settingsPage_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPage_title;

  /// No description provided for @settingsPage_userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get settingsPage_userInfo;

  /// No description provided for @settingsPage_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsPage_email;

  /// No description provided for @settingsPage_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsPage_name;

  /// No description provided for @settingsPage_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get settingsPage_status;

  /// No description provided for @settingsPage_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPage_premium;

  /// No description provided for @settingsPage_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsPage_standard;

  /// No description provided for @settingsPage_notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get settingsPage_notAvailable;

  /// No description provided for @settingsPage_notDefined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get settingsPage_notDefined;

  /// No description provided for @settingsPage_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsPage_security;

  /// No description provided for @settingsPage_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsPage_changePassword;

  /// No description provided for @settingsPage_biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get settingsPage_biometricAuth;

  /// No description provided for @settingsPage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsPage_subscription;

  /// No description provided for @settingsPage_premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get settingsPage_premiumSubscription;

  /// No description provided for @settingsPage_freemiumTest.
  ///
  /// In en, this message translates to:
  /// **'Freemium Test'**
  String get settingsPage_freemiumTest;

  /// No description provided for @settingsPage_subscribeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium'**
  String get settingsPage_subscribeToPremium;

  /// No description provided for @settingsPage_unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get settingsPage_unsubscribe;

  /// No description provided for @settingsPage_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsPage_account;

  /// No description provided for @settingsPage_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsPage_signOut;

  /// No description provided for @settingsPage_subscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium'**
  String get settingsPage_subscribeDialogTitle;

  /// No description provided for @settingsPage_subscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to subscribe to Premium?'**
  String get settingsPage_subscribeDialogContent;

  /// No description provided for @settingsPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsPage_cancel;

  /// No description provided for @settingsPage_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get settingsPage_subscribe;

  /// No description provided for @settingsPage_premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription activated!'**
  String get settingsPage_premiumActivated;

  /// No description provided for @settingsPage_subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Subscription error'**
  String get settingsPage_subscriptionError;

  /// No description provided for @settingsPage_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settingsPage_error;

  /// No description provided for @settingsPage_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get settingsPage_success;

  /// No description provided for @settingsPage_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsPage_ok;

  /// No description provided for @settingsPage_unsubscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get settingsPage_unsubscribeDialogTitle;

  /// No description provided for @settingsPage_unsubscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to unsubscribe? You will lose access to Premium features.'**
  String get settingsPage_unsubscribeDialogContent;

  /// No description provided for @settingsPage_confirmUnsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Confirm unsubscribe'**
  String get settingsPage_confirmUnsubscribe;

  /// No description provided for @settingsPage_signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsPage_signOutDialogTitle;

  /// No description provided for @settingsPage_signOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to sign out?'**
  String get settingsPage_signOutDialogContent;

  /// No description provided for @settingsPage_confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsPage_confirmSignOut;

  /// No description provided for @settingsPage_featureNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Feature not implemented'**
  String get settingsPage_featureNotImplemented;

  /// No description provided for @premiumExpiredDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Premium usage ended'**
  String get premiumExpiredDialog_title;

  /// No description provided for @premiumExpiredDialog_message.
  ///
  /// In en, this message translates to:
  /// **'You have used all your free uses. Upgrade to Premium to continue using all AV Wallet features.'**
  String get premiumExpiredDialog_message;

  /// No description provided for @premiumExpiredDialog_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get premiumExpiredDialog_ok;

  /// No description provided for @premiumExpiredDialog_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumExpiredDialog_premium;

  /// No description provided for @paymentPage_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get paymentPage_title;

  /// No description provided for @paymentPage_monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paymentPage_monthlyPlan;

  /// No description provided for @paymentPage_yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paymentPage_yearlyPlan;

  /// No description provided for @paymentPage_monthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€2.49/month'**
  String get paymentPage_monthlyPrice;

  /// No description provided for @paymentPage_yearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€19.99/year'**
  String get paymentPage_yearlyPrice;

  /// No description provided for @paymentPage_securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get paymentPage_securePayment;

  /// No description provided for @paymentPage_visaMastercardAccepted.
  ///
  /// In en, this message translates to:
  /// **'Visa and Mastercard accepted'**
  String get paymentPage_visaMastercardAccepted;

  /// No description provided for @paymentPage_paymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment information'**
  String get paymentPage_paymentInfo;

  /// No description provided for @paymentPage_cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get paymentPage_cardholderName;

  /// No description provided for @paymentPage_cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get paymentPage_cardNumber;

  /// No description provided for @paymentPage_expiryDate.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get paymentPage_expiryDate;

  /// No description provided for @paymentPage_cvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get paymentPage_cvc;

  /// No description provided for @paymentPage_payButton.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentPage_payButton;

  /// No description provided for @paymentPage_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get paymentPage_processing;

  /// No description provided for @paymentPage_paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentPage_paymentSuccess;

  /// No description provided for @paymentPage_subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Your premium subscription has been successfully activated!'**
  String get paymentPage_subscriptionActivated;

  /// No description provided for @paymentPage_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get paymentPage_plan;

  /// No description provided for @paymentPage_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get paymentPage_price;

  /// No description provided for @paymentPage_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paymentPage_continue;

  /// No description provided for @paymentPage_premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'You can now enjoy all premium features!'**
  String get paymentPage_premiumFeatures;

  /// No description provided for @paymentPage_paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error'**
  String get paymentPage_paymentError;

  /// No description provided for @paymentPage_selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get paymentPage_selectPaymentMethod;

  /// No description provided for @paymentPage_fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all card fields'**
  String get paymentPage_fillAllFields;

  /// No description provided for @paymentPage_paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentPage_paymentFailed;

  /// No description provided for @paymentPage_legalText.
  ///
  /// In en, this message translates to:
  /// **'By proceeding with payment, you accept our terms of use and privacy policy. Payment will be processed securely by Stripe.'**
  String get paymentPage_legalText;

  /// No description provided for @freemiumTestPage_title.
  ///
  /// In en, this message translates to:
  /// **'Freemium Test'**
  String get freemiumTestPage_title;

  /// No description provided for @freemiumTestPage_remainingUsage.
  ///
  /// In en, this message translates to:
  /// **'Remaining uses'**
  String get freemiumTestPage_remainingUsage;

  /// No description provided for @freemiumTestPage_maxUsage.
  ///
  /// In en, this message translates to:
  /// **'Maximum uses'**
  String get freemiumTestPage_maxUsage;

  /// No description provided for @freemiumTestPage_resetUsage.
  ///
  /// In en, this message translates to:
  /// **'Reset uses'**
  String get freemiumTestPage_resetUsage;

  /// No description provided for @freemiumTestPage_resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to reset uses?'**
  String get freemiumTestPage_resetConfirm;

  /// No description provided for @freemiumTestPage_resetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Uses reset successfully!'**
  String get freemiumTestPage_resetSuccess;

  /// No description provided for @freemiumTestPage_resetError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting uses'**
  String get freemiumTestPage_resetError;

  /// No description provided for @biometricSettingsPage_title.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricSettingsPage_title;

  /// No description provided for @biometricSettingsPage_enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric authentication'**
  String get biometricSettingsPage_enableBiometric;

  /// No description provided for @biometricSettingsPage_biometricDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face recognition to secure app access'**
  String get biometricSettingsPage_biometricDescription;

  /// No description provided for @biometricSettingsPage_biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get biometricSettingsPage_biometricNotAvailable;

  /// No description provided for @biometricSettingsPage_biometricNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No fingerprints or facial data enrolled'**
  String get biometricSettingsPage_biometricNotEnrolled;

  /// No description provided for @biometricSettingsPage_biometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not supported'**
  String get biometricSettingsPage_biometricNotSupported;

  /// No description provided for @biometricSettingsPage_biometricSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled successfully!'**
  String get biometricSettingsPage_biometricSuccess;

  /// No description provided for @biometricSettingsPage_biometricError.
  ///
  /// In en, this message translates to:
  /// **'Error enabling biometric authentication'**
  String get biometricSettingsPage_biometricError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
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
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
