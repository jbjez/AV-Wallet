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

  /// No description provided for @amplifier.
  ///
  /// In en, this message translates to:
  /// **'Amplifier'**
  String get amplifier;

  /// No description provided for @arMeasure_captureError.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Captureerror'**
  String get arMeasure_captureError;

  /// No description provided for @arMeasure_capturing.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Capturing'**
  String get arMeasure_capturing;

  /// No description provided for @arMeasure_defaultProject.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Defaultproject'**
  String get arMeasure_defaultProject;

  /// No description provided for @arMeasure_photo.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Photo'**
  String get arMeasure_photo;

  /// No description provided for @arMeasure_photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Photosaved'**
  String get arMeasure_photoSaved;

  /// No description provided for @arMeasure_photosAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Photosautosaved'**
  String get arMeasure_photosAutoSaved;

  /// No description provided for @arMeasure_saveError.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Saveerror'**
  String get arMeasure_saveError;

  /// No description provided for @arMeasure_takePhotosAndMeasure.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Takephotosandmeasure'**
  String get arMeasure_takePhotosAndMeasure;

  /// No description provided for @arMeasure_unity.
  ///
  /// In en, this message translates to:
  /// **'Armeasure Unity'**
  String get arMeasure_unity;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @catalogPage_search.
  ///
  /// In en, this message translates to:
  /// **'Catalog Page Search'**
  String get catalogPage_search;

  /// No description provided for @catalogPage_subCategory.
  ///
  /// In en, this message translates to:
  /// **'Catalog Page Subcategory'**
  String get catalogPage_subCategory;

  /// No description provided for @catalogue_angle.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Angle'**
  String get catalogue_angle;

  /// No description provided for @catalogue_brand.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Brand'**
  String get catalogue_brand;

  /// No description provided for @catalogue_consumption.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Consumption'**
  String get catalogue_consumption;

  /// No description provided for @catalogue_definition.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Definition'**
  String get catalogue_definition;

  /// No description provided for @catalogue_description.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Description'**
  String get catalogue_description;

  /// No description provided for @catalogue_dimensions.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Dimensions'**
  String get catalogue_dimensions;

  /// No description provided for @catalogue_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Dmxmax'**
  String get catalogue_dmxMax;

  /// No description provided for @catalogue_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Dmxmini'**
  String get catalogue_dmxMini;

  /// No description provided for @catalogue_impedance.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Impedance'**
  String get catalogue_impedance;

  /// No description provided for @catalogue_impedanceNominal.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Impedancenominal'**
  String get catalogue_impedanceNominal;

  /// No description provided for @catalogue_lumens.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Lumens'**
  String get catalogue_lumens;

  /// No description provided for @catalogue_lux.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Lux'**
  String get catalogue_lux;

  /// No description provided for @catalogue_maxVoltage.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Maxvoltage'**
  String get catalogue_maxVoltage;

  /// No description provided for @catalogue_pitch.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Pitch'**
  String get catalogue_pitch;

  /// No description provided for @catalogue_powerAdmissible.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Poweradmissible'**
  String get catalogue_powerAdmissible;

  /// No description provided for @catalogue_powerPeak.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Powerpeak'**
  String get catalogue_powerPeak;

  /// No description provided for @catalogue_powerProgram.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Powerprogram'**
  String get catalogue_powerProgram;

  /// No description provided for @catalogue_powerRms.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Powerrms'**
  String get catalogue_powerRms;

  /// No description provided for @catalogue_resolution.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Resolution'**
  String get catalogue_resolution;

  /// No description provided for @catalogue_weight.
  ///
  /// In en, this message translates to:
  /// **'Catalogue Weight'**
  String get catalogue_weight;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @defaultProjectName.
  ///
  /// In en, this message translates to:
  /// **'Defaultprojectname'**
  String get defaultProjectName;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_preset.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get delete_preset;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @dmxPage_allCategories.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Allcategories'**
  String get dmxPage_allCategories;

  /// No description provided for @dmxPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Cancel'**
  String get dmxPage_cancel;

  /// No description provided for @dmxPage_channelsTotal.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Channelstotal'**
  String get dmxPage_channelsTotal;

  /// No description provided for @dmxPage_channelsUsed.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Channelsused'**
  String get dmxPage_channelsUsed;

  /// No description provided for @dmxPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Confirm'**
  String get dmxPage_confirm;

  /// No description provided for @dmxPage_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Dmxmax'**
  String get dmxPage_dmxMax;

  /// No description provided for @dmxPage_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Dmxmini'**
  String get dmxPage_dmxMini;

  /// No description provided for @dmxPage_dmxType.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Dmxtype'**
  String get dmxPage_dmxType;

  /// No description provided for @dmxPage_importPreset.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Importpreset'**
  String get dmxPage_importPreset;

  /// No description provided for @dmxPage_importedFromPreset.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Importedfrompreset'**
  String get dmxPage_importedFromPreset;

  /// No description provided for @dmxPage_ledBar.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Ledbar'**
  String get dmxPage_ledBar;

  /// No description provided for @dmxPage_lightDevices.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Lightdevices'**
  String get dmxPage_lightDevices;

  /// No description provided for @dmxPage_mapDmx.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Mapdmx'**
  String get dmxPage_mapDmx;

  /// No description provided for @dmxPage_movingHead.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Movinghead'**
  String get dmxPage_movingHead;

  /// No description provided for @dmxPage_noPresetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Nopresetavailable'**
  String get dmxPage_noPresetAvailable;

  /// No description provided for @dmxPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Nopresetselected'**
  String get dmxPage_noPresetSelected;

  /// No description provided for @dmxPage_noProductsSelected.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Noproductsselected'**
  String get dmxPage_noProductsSelected;

  /// No description provided for @dmxPage_ok.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Ok'**
  String get dmxPage_ok;

  /// No description provided for @dmxPage_productsAddedToPreset.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Productsaddedtopreset'**
  String get dmxPage_productsAddedToPreset;

  /// No description provided for @dmxPage_quantityEnter.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Quantityenter'**
  String get dmxPage_quantityEnter;

  /// No description provided for @dmxPage_scanner.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Scanner'**
  String get dmxPage_scanner;

  /// No description provided for @dmxPage_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Searchhint'**
  String get dmxPage_searchHint;

  /// No description provided for @dmxPage_selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Selectpreset'**
  String get dmxPage_selectPreset;

  /// No description provided for @dmxPage_selectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Selectedproducts'**
  String get dmxPage_selectedProducts;

  /// No description provided for @dmxPage_strobe.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Strobe'**
  String get dmxPage_strobe;

  /// No description provided for @dmxPage_universe.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Universe'**
  String get dmxPage_universe;

  /// No description provided for @dmxPage_universesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Universesneeded'**
  String get dmxPage_universesNeeded;

  /// No description provided for @dmxPage_wash.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Wash'**
  String get dmxPage_wash;

  /// No description provided for @dmxPage_wired.
  ///
  /// In en, this message translates to:
  /// **'Dmx Page Wired'**
  String get dmxPage_wired;

  /// No description provided for @driverTab_customDriverChannels.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Customdriverchannels'**
  String get driverTab_customDriverChannels;

  /// No description provided for @driverTab_customDriverIntensity.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Customdriverintensity'**
  String get driverTab_customDriverIntensity;

  /// No description provided for @driverTab_customDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Customdrivertitle'**
  String get driverTab_customDriverTitle;

  /// No description provided for @driverTab_driverChoice.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Driverchoice'**
  String get driverTab_driverChoice;

  /// No description provided for @driverTab_ledLength.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Ledlength'**
  String get driverTab_ledLength;

  /// No description provided for @driverTab_ledPower.
  ///
  /// In en, this message translates to:
  /// **'Drivertab Ledpower'**
  String get driverTab_ledPower;

  /// No description provided for @enterProjectName.
  ///
  /// In en, this message translates to:
  /// **'Enterprojectname'**
  String get enterProjectName;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportCount.
  ///
  /// In en, this message translates to:
  /// **'Exportcount'**
  String get exportCount;

  /// No description provided for @exportProject.
  ///
  /// In en, this message translates to:
  /// **'Exportproject'**
  String get exportProject;

  /// No description provided for @lightPage_beamDiameter.
  ///
  /// In en, this message translates to:
  /// **'Light Page Beamdiameter'**
  String get lightPage_beamDiameter;

  /// No description provided for @loadProject.
  ///
  /// In en, this message translates to:
  /// **'Loadproject'**
  String get loadProject;

  /// No description provided for @loginMenu_accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Loginmenu Accountsettings'**
  String get loginMenu_accountSettings;

  /// No description provided for @loginMenu_logout.
  ///
  /// In en, this message translates to:
  /// **'Loginmenu Logout'**
  String get loginMenu_logout;

  /// No description provided for @loginMenu_myProjects.
  ///
  /// In en, this message translates to:
  /// **'Loginmenu Myprojects'**
  String get loginMenu_myProjects;

  /// No description provided for @noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'Nopresetselected'**
  String get noPresetSelected;

  /// No description provided for @patch_cancel.
  ///
  /// In en, this message translates to:
  /// **'Patch Cancel'**
  String get patch_cancel;

  /// No description provided for @patch_delete.
  ///
  /// In en, this message translates to:
  /// **'Patch Delete'**
  String get patch_delete;

  /// No description provided for @patch_instrument.
  ///
  /// In en, this message translates to:
  /// **'Patch Instrument'**
  String get patch_instrument;

  /// No description provided for @patch_no_entries.
  ///
  /// In en, this message translates to:
  /// **'Patch No Entries'**
  String get patch_no_entries;

  /// No description provided for @patch_quantity.
  ///
  /// In en, this message translates to:
  /// **'Patch Quantity'**
  String get patch_quantity;

  /// No description provided for @patch_rename.
  ///
  /// In en, this message translates to:
  /// **'Patch Rename'**
  String get patch_rename;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @premiumExpiredDialog_message.
  ///
  /// In en, this message translates to:
  /// **'Premiumexpireddialog Message'**
  String get premiumExpiredDialog_message;

  /// No description provided for @premiumExpiredDialog_ok.
  ///
  /// In en, this message translates to:
  /// **'Premiumexpireddialog Ok'**
  String get premiumExpiredDialog_ok;

  /// No description provided for @premiumExpiredDialog_premium.
  ///
  /// In en, this message translates to:
  /// **'Premiumexpireddialog Premium'**
  String get premiumExpiredDialog_premium;

  /// No description provided for @premiumExpiredDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Premiumexpireddialog Title'**
  String get premiumExpiredDialog_title;

  /// No description provided for @presetCount.
  ///
  /// In en, this message translates to:
  /// **'Presetcount'**
  String get presetCount;

  /// No description provided for @presetDelete.
  ///
  /// In en, this message translates to:
  /// **'Presetdelete'**
  String get presetDelete;

  /// No description provided for @presetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Presetdeleted'**
  String get presetDeleted;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Presetname'**
  String get presetName;

  /// No description provided for @presetRename.
  ///
  /// In en, this message translates to:
  /// **'Presetrename'**
  String get presetRename;

  /// No description provided for @presetRenamed.
  ///
  /// In en, this message translates to:
  /// **'Presetrenamed'**
  String get presetRenamed;

  /// No description provided for @presetWidget_confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Preset Widget Confirmdelete'**
  String get presetWidget_confirmDelete;

  /// No description provided for @presetWidget_create.
  ///
  /// In en, this message translates to:
  /// **'Preset Widget Create'**
  String get presetWidget_create;

  /// No description provided for @presetWidget_newPreset.
  ///
  /// In en, this message translates to:
  /// **'Preset Widget Newpreset'**
  String get presetWidget_newPreset;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @projectArchiveInfo.
  ///
  /// In en, this message translates to:
  /// **'Projectarchiveinfo'**
  String get projectArchiveInfo;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Projectnamehint'**
  String get projectNameHint;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Projectnamelabel'**
  String get projectNameLabel;

  /// No description provided for @projectPage_addToPreset.
  ///
  /// In en, this message translates to:
  /// **'Project Page Addtopreset'**
  String get projectPage_addToPreset;

  /// No description provided for @projectPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Project Page Cancel'**
  String get projectPage_cancel;

  /// No description provided for @projectRenamed.
  ///
  /// In en, this message translates to:
  /// **'Projectrenamed'**
  String get projectRenamed;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @renameProject.
  ///
  /// In en, this message translates to:
  /// **'Renameproject'**
  String get renameProject;

  /// No description provided for @rename_preset.
  ///
  /// In en, this message translates to:
  /// **'Rename Preset'**
  String get rename_preset;

  /// No description provided for @rider_technical_title.
  ///
  /// In en, this message translates to:
  /// **'Rider Technical Title'**
  String get rider_technical_title;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveProject.
  ///
  /// In en, this message translates to:
  /// **'Saveproject'**
  String get saveProject;

  /// No description provided for @searchArticlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Searcharticleplaceholder'**
  String get searchArticlePlaceholder;

  /// No description provided for @search_speaker.
  ///
  /// In en, this message translates to:
  /// **'Search Speaker'**
  String get search_speaker;

  /// No description provided for @settingsPage_account.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Account'**
  String get settingsPage_account;

  /// No description provided for @settingsPage_biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Biometricauth'**
  String get settingsPage_biometricAuth;

  /// No description provided for @settingsPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Cancel'**
  String get settingsPage_cancel;

  /// No description provided for @settingsPage_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Changepassword'**
  String get settingsPage_changePassword;

  /// No description provided for @settingsPage_confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Confirmsignout'**
  String get settingsPage_confirmSignOut;

  /// No description provided for @settingsPage_confirmUnsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Confirmunsubscribe'**
  String get settingsPage_confirmUnsubscribe;

  /// No description provided for @settingsPage_email.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Email'**
  String get settingsPage_email;

  /// No description provided for @settingsPage_error.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Error'**
  String get settingsPage_error;

  /// No description provided for @settingsPage_featureNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Featurenotimplemented'**
  String get settingsPage_featureNotImplemented;

  /// No description provided for @settingsPage_freemiumTest.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Freemiumtest'**
  String get settingsPage_freemiumTest;

  /// No description provided for @settingsPage_name.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Name'**
  String get settingsPage_name;

  /// No description provided for @settingsPage_notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Notavailable'**
  String get settingsPage_notAvailable;

  /// No description provided for @settingsPage_notDefined.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Notdefined'**
  String get settingsPage_notDefined;

  /// No description provided for @settingsPage_ok.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Ok'**
  String get settingsPage_ok;

  /// No description provided for @settingsPage_premium.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Premium'**
  String get settingsPage_premium;

  /// No description provided for @settingsPage_premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Premiumactivated'**
  String get settingsPage_premiumActivated;

  /// No description provided for @settingsPage_premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Premiumsubscription'**
  String get settingsPage_premiumSubscription;

  /// No description provided for @settingsPage_security.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Security'**
  String get settingsPage_security;

  /// No description provided for @settingsPage_signOut.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Signout'**
  String get settingsPage_signOut;

  /// No description provided for @settingsPage_signOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Signoutdialogcontent'**
  String get settingsPage_signOutDialogContent;

  /// No description provided for @settingsPage_signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Signoutdialogtitle'**
  String get settingsPage_signOutDialogTitle;

  /// No description provided for @settingsPage_standard.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Standard'**
  String get settingsPage_standard;

  /// No description provided for @settingsPage_status.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Status'**
  String get settingsPage_status;

  /// No description provided for @settingsPage_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscribe'**
  String get settingsPage_subscribe;

  /// No description provided for @settingsPage_subscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscribedialogcontent'**
  String get settingsPage_subscribeDialogContent;

  /// No description provided for @settingsPage_subscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscribedialogtitle'**
  String get settingsPage_subscribeDialogTitle;

  /// No description provided for @settingsPage_subscribeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscribetopremium'**
  String get settingsPage_subscribeToPremium;

  /// No description provided for @settingsPage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscription'**
  String get settingsPage_subscription;

  /// No description provided for @settingsPage_subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Subscriptionerror'**
  String get settingsPage_subscriptionError;

  /// No description provided for @settingsPage_success.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Success'**
  String get settingsPage_success;

  /// No description provided for @settingsPage_title.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Title'**
  String get settingsPage_title;

  /// No description provided for @settingsPage_unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Unsubscribe'**
  String get settingsPage_unsubscribe;

  /// No description provided for @settingsPage_unsubscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Unsubscribedialogcontent'**
  String get settingsPage_unsubscribeDialogContent;

  /// No description provided for @settingsPage_unsubscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Unsubscribedialogtitle'**
  String get settingsPage_unsubscribeDialogTitle;

  /// No description provided for @settingsPage_userInfo.
  ///
  /// In en, this message translates to:
  /// **'Settings Page Userinfo'**
  String get settingsPage_userInfo;

  /// No description provided for @soundPage_ampConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Ampconfigtitle'**
  String get soundPage_ampConfigTitle;

  /// No description provided for @soundPage_amplificationTabShort.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Amplificationtabshort'**
  String get soundPage_amplificationTabShort;

  /// No description provided for @soundPage_amplifier.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Amplifier'**
  String get soundPage_amplifier;

  /// No description provided for @soundPage_amplifiersRequired.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Amplifiersrequired'**
  String get soundPage_amplifiersRequired;

  /// No description provided for @soundPage_capacity.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Capacity'**
  String get soundPage_capacity;

  /// No description provided for @soundPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Nopresetselected'**
  String get soundPage_noPresetSelected;

  /// No description provided for @soundPage_noSpeakersSelected.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Nospeakersselected'**
  String get soundPage_noSpeakersSelected;

  /// No description provided for @soundPage_power.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Power'**
  String get soundPage_power;

  /// No description provided for @soundPage_speakersPerAmp.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Speakersperamp'**
  String get soundPage_speakersPerAmp;

  /// No description provided for @soundPage_speakersPerChannel.
  ///
  /// In en, this message translates to:
  /// **'Sound Page Speakersperchannel'**
  String get soundPage_speakersPerChannel;

  /// No description provided for @soundPage_with.
  ///
  /// In en, this message translates to:
  /// **'Sound Page With'**
  String get soundPage_with;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @stand.
  ///
  /// In en, this message translates to:
  /// **'Stand'**
  String get stand;

  /// No description provided for @totalArticlesCount.
  ///
  /// In en, this message translates to:
  /// **'Totalarticlescount'**
  String get totalArticlesCount;

  /// No description provided for @totalPreset.
  ///
  /// In en, this message translates to:
  /// **'Totalpreset'**
  String get totalPreset;

  /// No description provided for @totalProject.
  ///
  /// In en, this message translates to:
  /// **'Totalproject'**
  String get totalProject;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'Unitkilogram'**
  String get unitKilogram;

  /// No description provided for @unitKilowatt.
  ///
  /// In en, this message translates to:
  /// **'Unitkilowatt'**
  String get unitKilowatt;

  /// No description provided for @unitWatt.
  ///
  /// In en, this message translates to:
  /// **'Unitwatt'**
  String get unitWatt;

  /// No description provided for @view_preset.
  ///
  /// In en, this message translates to:
  /// **'View Preset'**
  String get view_preset;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'ampere Per Channel'**
  String get amperePerChannel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'amperes'**
  String get amperes;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'beam Calculation'**
  String get beamCalculation;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav catalogue'**
  String get bottomNav_catalogue;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav electricity'**
  String get bottomNav_electricity;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav light'**
  String get bottomNav_light;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav misc'**
  String get bottomNav_misc;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav sound'**
  String get bottomNav_sound;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav structure'**
  String get bottomNav_structure;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'bottom Nav video'**
  String get bottomNav_video;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'button reset'**
  String get button_reset;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'calculate Driver Config'**
  String get calculateDriverConfig;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'calculation Result'**
  String get calculationResult;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'catalog Access'**
  String get catalogAccess;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'catalog Page cancel'**
  String get catalogPage_cancel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'catalog Page confirm'**
  String get catalogPage_confirm;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'catalogue lenses Available'**
  String get catalogue_lensesAvailable;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'catalogue projection Ratio'**
  String get catalogue_projectionRatio;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'channel'**
  String get channel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get channels;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'channels Plural'**
  String get channelsPlural;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'connectors'**
  String get connectors;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'consumption'**
  String get consumption;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'distance label'**
  String get distance_label;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'dmx Cables'**
  String get dmxCables;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'driver Configuration'**
  String get driverConfiguration;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'driver Tab result'**
  String get driverTab_result;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'driver Type'**
  String get driverType;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'electricity Menu'**
  String get electricityMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page calculate'**
  String get ledWallSchemaPage_calculate;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page dimensions'**
  String get ledWallSchemaPage_dimensions;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page height'**
  String get ledWallSchemaPage_height;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page panel Selection'**
  String get ledWallSchemaPage_panelSelection;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page select Panel'**
  String get ledWallSchemaPage_selectPanel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page title'**
  String get ledWallSchemaPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'led Wall Schema Page width'**
  String get ledWallSchemaPage_width;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'length'**
  String get length;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Accessories'**
  String get lightAccessories;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Menu'**
  String get lightMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page angle Range'**
  String get lightPage_angleRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page calculate'**
  String get lightPage_calculate;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page channel'**
  String get lightPage_channel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page channels'**
  String get lightPage_channels;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page distance Range'**
  String get lightPage_distanceRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page height Range'**
  String get lightPage_heightRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page led Length'**
  String get lightPage_ledLength;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page meters'**
  String get lightPage_meters;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page title'**
  String get lightPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'light Page total'**
  String get lightPage_total;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'mounting Tools'**
  String get mountingTools;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'network Menu'**
  String get networkMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'patch input'**
  String get patch_input;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'patch output'**
  String get patch_output;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'payment Page monthly Plan'**
  String get paymentPage_monthlyPlan;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'payment Page yearly Plan'**
  String get paymentPage_yearlyPlan;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page global Total'**
  String get projectCalculationPage_globalTotal;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page no Preset Selected'**
  String get projectCalculationPage_noPresetSelected;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page power Consumption'**
  String get projectCalculationPage_powerConsumption;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page power Project'**
  String get projectCalculationPage_powerProject;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page total'**
  String get projectCalculationPage_total;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'project Calculation Page weight'**
  String get projectCalculationPage_weight;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'protections'**
  String get protections;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'recommended Configuration'**
  String get recommendedConfiguration;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'safety Accessories'**
  String get safetyAccessories;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'select Structure'**
  String get selectStructure;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'sound Menu'**
  String get soundMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'sound Page quantity'**
  String get soundPage_quantity;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'sound Page title'**
  String get soundPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest completed'**
  String get speedtest_completed;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest download'**
  String get speedtest_download;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest downloading'**
  String get speedtest_downloading;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest mbps'**
  String get speedtest_mbps;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest ready'**
  String get speedtest_ready;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest running'**
  String get speedtest_running;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest start'**
  String get speedtest_start;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest upload'**
  String get speedtest_upload;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'speedtest uploading'**
  String get speedtest_uploading;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'strip Led Configuration'**
  String get stripLedConfiguration;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'strip Led Type'**
  String get stripLedType;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Menu'**
  String get structureMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page 3 points Accroche'**
  String get structurePage_3pointsAccroche;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page 4 points Accroche'**
  String get structurePage_4pointsAccroche;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page charge Repartie'**
  String get structurePage_chargeRepartie;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page charge Type'**
  String get structurePage_chargeType;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page charges Tab'**
  String get structurePage_chargesTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page deflection Ratio Title'**
  String get structurePage_deflectionRatioTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page distance'**
  String structurePage_distance(Object distance);

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page length'**
  String get structurePage_length;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page max Deflection Title'**
  String get structurePage_maxDeflectionTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page max Load Title'**
  String get structurePage_maxLoadTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page modifier'**
  String get structurePage_modifier;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page point Accroche Centre'**
  String get structurePage_pointAccrocheCentre;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page points Accroche Extremites'**
  String get structurePage_pointsAccrocheExtremites;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page project Weight Tab'**
  String get structurePage_projectWeightTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page select Charge'**
  String get structurePage_selectCharge;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page structure'**
  String get structurePage_structure;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page structure Weight Title'**
  String get structurePage_structureWeightTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'structure Page title'**
  String get structurePage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription choose plan'**
  String get subscription_choose_plan;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription description'**
  String get subscription_description;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription free trial'**
  String get subscription_free_trial;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription popular'**
  String get subscription_popular;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription premium'**
  String get subscription_premium;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription security'**
  String get subscription_security;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription security description'**
  String get subscription_security_description;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'subscription subscribe'**
  String get subscription_subscribe;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'this Section Will Be Developed'**
  String get thisSectionWillBeDeveloped;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'trusses And Structures'**
  String get trussesAndStructures;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Led Result consommation Totale'**
  String get videoLedResult_consommationTotale;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Led Result dalles'**
  String get videoLedResult_dalles;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Led Result espace Pixellaire'**
  String get videoLedResult_espacePixellaire;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Led Result poids Total'**
  String get videoLedResult_poidsTotal;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Menu'**
  String get videoMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page brand'**
  String get videoPage_brand;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page format'**
  String get videoPage_format;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page image Width'**
  String get videoPage_imageWidth;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page model'**
  String get videoPage_model;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page overlap'**
  String get videoPage_overlap;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page projector Count'**
  String get videoPage_projectorCount;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page projector Distance'**
  String get videoPage_projectorDistance;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page schema'**
  String get videoPage_schema;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page select Led Wall'**
  String get videoPage_selectLedWall;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page select Product'**
  String get videoPage_selectProduct;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'video Page title'**
  String get videoPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'voltage'**
  String get voltage;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'volts'**
  String get volts;

  /// auto-added
  ///
  /// In en, this message translates to:
  /// **'Default Project 1'**
  String get defaultProject1;

  /// auto-added
  ///
  /// In en, this message translates to:
  /// **'Default Project 2'**
  String get defaultProject2;

  /// auto-added
  ///
  /// In en, this message translates to:
  /// **'Default Project 3'**
  String get defaultProject3;
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
