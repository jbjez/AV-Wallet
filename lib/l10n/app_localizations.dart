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

  /// No description provided for @arMeasure_photoAr.
  ///
  /// In en, this message translates to:
  /// **'Photo/AR'**
  String get arMeasure_photoAr;

  /// No description provided for @arMeasure_captureError.
  ///
  /// In en, this message translates to:
  /// **'Capture error'**
  String get arMeasure_captureError;

  /// No description provided for @arMeasure_capturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing...'**
  String get arMeasure_capturing;

  /// No description provided for @arMeasure_defaultProject.
  ///
  /// In en, this message translates to:
  /// **'Default project'**
  String get arMeasure_defaultProject;

  /// No description provided for @arMeasure_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get arMeasure_photo;

  /// No description provided for @arMeasure_photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved in project!'**
  String get arMeasure_photoSaved;

  /// No description provided for @arMeasure_photosAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photos are automatically saved in the active project folder'**
  String get arMeasure_photosAutoSaved;

  /// No description provided for @arMeasure_saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get arMeasure_saveError;

  /// No description provided for @arMeasure_takePhotosAndMeasure.
  ///
  /// In en, this message translates to:
  /// **'Take reference photos and start AR measurements'**
  String get arMeasure_takePhotosAndMeasure;

  /// No description provided for @arMeasure_unity.
  ///
  /// In en, this message translates to:
  /// **'Unity'**
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
  /// **'Search'**
  String get catalogPage_search;

  /// No description provided for @catalogPage_subCategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
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
  /// **'Project1'**
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
  /// **'All Categories'**
  String get dmxPage_allCategories;

  /// No description provided for @dmxPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dmxPage_cancel;

  /// No description provided for @dmxPage_channelsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Channels'**
  String get dmxPage_channelsTotal;

  /// No description provided for @dmxPage_channelsUsed.
  ///
  /// In en, this message translates to:
  /// **'Channels Used'**
  String get dmxPage_channelsUsed;

  /// No description provided for @dmxPage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dmxPage_confirm;

  /// No description provided for @dmxPage_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'DMX Max'**
  String get dmxPage_dmxMax;

  /// No description provided for @dmxPage_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'DMX Mini'**
  String get dmxPage_dmxMini;

  /// No description provided for @dmxPage_dmxType.
  ///
  /// In en, this message translates to:
  /// **'DMX Type'**
  String get dmxPage_dmxType;

  /// No description provided for @dmxPage_importPreset.
  ///
  /// In en, this message translates to:
  /// **'Import Preset'**
  String get dmxPage_importPreset;

  /// No description provided for @dmxPage_importedFromPreset.
  ///
  /// In en, this message translates to:
  /// **'Imported from Preset'**
  String get dmxPage_importedFromPreset;

  /// No description provided for @dmxPage_ledBar.
  ///
  /// In en, this message translates to:
  /// **'LED Bar'**
  String get dmxPage_ledBar;

  /// No description provided for @dmxPage_lightDevices.
  ///
  /// In en, this message translates to:
  /// **'Light Devices'**
  String get dmxPage_lightDevices;

  /// No description provided for @dmxPage_mapDmx.
  ///
  /// In en, this message translates to:
  /// **'Map DMX'**
  String get dmxPage_mapDmx;

  /// No description provided for @dmxPage_movingHead.
  ///
  /// In en, this message translates to:
  /// **'Moving Head'**
  String get dmxPage_movingHead;

  /// No description provided for @dmxPage_noPresetAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Preset Available'**
  String get dmxPage_noPresetAvailable;

  /// No description provided for @dmxPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No Preset Selected'**
  String get dmxPage_noPresetSelected;

  /// No description provided for @dmxPage_noProductsSelected.
  ///
  /// In en, this message translates to:
  /// **'No Products Selected'**
  String get dmxPage_noProductsSelected;

  /// No description provided for @dmxPage_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dmxPage_ok;

  /// No description provided for @dmxPage_productsAddedToPreset.
  ///
  /// In en, this message translates to:
  /// **'Products Added to Preset'**
  String get dmxPage_productsAddedToPreset;

  /// No description provided for @dmxPage_quantityEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get dmxPage_quantityEnter;

  /// No description provided for @dmxPage_scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get dmxPage_scanner;

  /// No description provided for @dmxPage_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Hint'**
  String get dmxPage_searchHint;

  /// No description provided for @dmxPage_selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select Preset'**
  String get dmxPage_selectPreset;

  /// No description provided for @dmxPage_selectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Selected Products'**
  String get dmxPage_selectedProducts;

  /// No description provided for @dmxPage_strobe.
  ///
  /// In en, this message translates to:
  /// **'Strobe'**
  String get dmxPage_strobe;

  /// No description provided for @dmxPage_universe.
  ///
  /// In en, this message translates to:
  /// **'Universe'**
  String get dmxPage_universe;

  /// No description provided for @dmxPage_universesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Universes Needed'**
  String get dmxPage_universesNeeded;

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

  /// No description provided for @driverTab_customDriverChannels.
  ///
  /// In en, this message translates to:
  /// **'Custom Driver Channels'**
  String get driverTab_customDriverChannels;

  /// No description provided for @driverTab_customDriverIntensity.
  ///
  /// In en, this message translates to:
  /// **'Custom Driver Intensity'**
  String get driverTab_customDriverIntensity;

  /// No description provided for @driverTab_customDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Driver Title'**
  String get driverTab_customDriverTitle;

  /// No description provided for @driverTab_driverChoice.
  ///
  /// In en, this message translates to:
  /// **'Driver Choice'**
  String get driverTab_driverChoice;

  /// No description provided for @driverTab_ledLength.
  ///
  /// In en, this message translates to:
  /// **'LED Length'**
  String get driverTab_ledLength;

  /// No description provided for @driverTab_ledPower.
  ///
  /// In en, this message translates to:
  /// **'LED Power'**
  String get driverTab_ledPower;

  /// No description provided for @enterProjectName.
  ///
  /// In en, this message translates to:
  /// **'Enter Project Name'**
  String get enterProjectName;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportCount.
  ///
  /// In en, this message translates to:
  /// **'Export Count'**
  String get exportCount;

  /// No description provided for @exportProject.
  ///
  /// In en, this message translates to:
  /// **'Export Project'**
  String get exportProject;

  /// No description provided for @lightPage_beamDiameter.
  ///
  /// In en, this message translates to:
  /// **'Beam Diameter'**
  String get lightPage_beamDiameter;

  /// No description provided for @lightPage_beamTab.
  ///
  /// In en, this message translates to:
  /// **'Beam'**
  String get lightPage_beamTab;

  /// No description provided for @lightPage_ledDriverTab.
  ///
  /// In en, this message translates to:
  /// **'Led driver'**
  String get lightPage_ledDriverTab;

  /// No description provided for @loadProject.
  ///
  /// In en, this message translates to:
  /// **'Load Project'**
  String get loadProject;

  /// No description provided for @loadProject_selectProject.
  ///
  /// In en, this message translates to:
  /// **'Select a project to load:'**
  String get loadProject_selectProject;

  /// No description provided for @standard_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AVWallet'**
  String standard_welcome_title(String username);

  /// No description provided for @premium_benefit_catalogue.
  ///
  /// In en, this message translates to:
  /// **'Catalogue +220 Products'**
  String get premium_benefit_catalogue;

  /// No description provided for @premium_benefit_calculations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Calculations'**
  String get premium_benefit_calculations;

  /// No description provided for @premium_benefit_project_management.
  ///
  /// In en, this message translates to:
  /// **'Project/Preset Management'**
  String get premium_benefit_project_management;

  /// No description provided for @premium_benefit_pdf_export.
  ///
  /// In en, this message translates to:
  /// **'PDF Export'**
  String get premium_benefit_pdf_export;

  /// No description provided for @loginMenu_accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get loginMenu_accountSettings;

  /// No description provided for @loginMenu_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get loginMenu_logout;

  /// No description provided for @loginMenu_myProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get loginMenu_myProjects;

  /// No description provided for @loginMenu_usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get loginMenu_usage;

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
  /// **'Confirm Delete'**
  String get presetWidget_confirmDelete;

  /// No description provided for @presetWidget_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get presetWidget_create;

  /// No description provided for @new_preset.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get new_preset;

  /// No description provided for @view_project.
  ///
  /// In en, this message translates to:
  /// **'View Project'**
  String get view_project;

  /// No description provided for @new_project.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get new_project;

  /// No description provided for @save_project.
  ///
  /// In en, this message translates to:
  /// **'Save Project'**
  String get save_project;

  /// No description provided for @load_project.
  ///
  /// In en, this message translates to:
  /// **'Load Project'**
  String get load_project;

  /// No description provided for @export_project.
  ///
  /// In en, this message translates to:
  /// **'Export Project'**
  String get export_project;

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

  /// No description provided for @project_name.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get project_name;

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

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

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
  /// **'Account'**
  String get settingsPage_account;

  /// No description provided for @settingsPage_biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get settingsPage_biometricAuth;

  /// No description provided for @settingsPage_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsPage_cancel;

  /// No description provided for @settingsPage_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsPage_changePassword;

  /// No description provided for @settingsPage_confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get settingsPage_confirmSignOut;

  /// No description provided for @settingsPage_confirmUnsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Confirm Unsubscribe'**
  String get settingsPage_confirmUnsubscribe;

  /// No description provided for @settingsPage_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsPage_email;

  /// No description provided for @settingsPage_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settingsPage_error;

  /// No description provided for @settingsPage_featureNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Feature Not Implemented'**
  String get settingsPage_featureNotImplemented;

  /// No description provided for @settingsPage_freemiumTest.
  ///
  /// In en, this message translates to:
  /// **'Freemium Test'**
  String get settingsPage_freemiumTest;

  /// No description provided for @settingsPage_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsPage_name;

  /// No description provided for @settingsPage_notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get settingsPage_notAvailable;

  /// No description provided for @settingsPage_notDefined.
  ///
  /// In en, this message translates to:
  /// **'Not Defined'**
  String get settingsPage_notDefined;

  /// No description provided for @settingsPage_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsPage_ok;

  /// No description provided for @settingsPage_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPage_premium;

  /// No description provided for @settingsPage_premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium Activated'**
  String get settingsPage_premiumActivated;

  /// No description provided for @settingsPage_premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get settingsPage_premiumSubscription;

  /// No description provided for @settingsPage_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsPage_security;

  /// No description provided for @settingsPage_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsPage_signOut;

  /// No description provided for @settingsPage_signOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsPage_signOutDialogContent;

  /// No description provided for @settingsPage_signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsPage_signOutDialogTitle;

  /// No description provided for @settingsPage_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsPage_standard;

  /// No description provided for @settingsPage_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get settingsPage_status;

  /// No description provided for @settingsPage_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get settingsPage_subscribe;

  /// No description provided for @settingsPage_subscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to subscribe to the premium plan?'**
  String get settingsPage_subscribeDialogContent;

  /// No description provided for @settingsPage_subscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get settingsPage_subscribeDialogTitle;

  /// No description provided for @settingsPage_subscribeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium'**
  String get settingsPage_subscribeToPremium;

  /// No description provided for @settingsPage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsPage_subscription;

  /// No description provided for @settingsPage_subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Subscription Error'**
  String get settingsPage_subscriptionError;

  /// No description provided for @settingsPage_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get settingsPage_success;

  /// No description provided for @settingsPage_title.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsPage_title;

  /// No description provided for @settingsPage_unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get settingsPage_unsubscribe;

  /// No description provided for @settingsPage_unsubscribeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unsubscribe?'**
  String get settingsPage_unsubscribeDialogContent;

  /// No description provided for @settingsPage_unsubscribeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get settingsPage_unsubscribeDialogTitle;

  /// No description provided for @settingsPage_userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get settingsPage_userInfo;

  /// No description provided for @soundPage_ampConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Amp Config Title'**
  String get soundPage_ampConfigTitle;

  /// No description provided for @soundPage_amplificationTabShort.
  ///
  /// In en, this message translates to:
  /// **'Amp'**
  String get soundPage_amplificationTabShort;

  /// No description provided for @soundPage_amplifier.
  ///
  /// In en, this message translates to:
  /// **'Amplifier'**
  String get soundPage_amplifier;

  /// No description provided for @soundPage_amplifiersRequired.
  ///
  /// In en, this message translates to:
  /// **'Amplifiers Required'**
  String get soundPage_amplifiersRequired;

  /// No description provided for @soundPage_capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get soundPage_capacity;

  /// No description provided for @soundPage_noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No Preset Selected'**
  String get soundPage_noPresetSelected;

  /// No description provided for @soundPage_noSpeakersSelected.
  ///
  /// In en, this message translates to:
  /// **'No Speakers Selected'**
  String get soundPage_noSpeakersSelected;

  /// No description provided for @soundPage_power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get soundPage_power;

  /// No description provided for @soundPage_speakersPerAmp.
  ///
  /// In en, this message translates to:
  /// **'Speakers per Amp'**
  String get soundPage_speakersPerAmp;

  /// No description provided for @soundPage_speakersPerChannel.
  ///
  /// In en, this message translates to:
  /// **'Speakers per Channel'**
  String get soundPage_speakersPerChannel;

  /// No description provided for @soundPage_with.
  ///
  /// In en, this message translates to:
  /// **'with'**
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
  /// **'Kg'**
  String get unitKilogram;

  /// No description provided for @unitKilowatt.
  ///
  /// In en, this message translates to:
  /// **'kW'**
  String get unitKilowatt;

  /// No description provided for @unitWatt.
  ///
  /// In en, this message translates to:
  /// **'W'**
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
  /// **'Catalogue'**
  String get bottomNav_catalogue;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get bottomNav_electricity;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get bottomNav_light;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get bottomNav_misc;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get bottomNav_sound;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get bottomNav_structure;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Video'**
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
  /// **'Catalogue AV'**
  String get catalogAccess;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogPage_cancel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
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
  /// **'Consumption'**
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
  /// **'Electricity'**
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
  /// **'Light'**
  String get lightMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Angle (1° to 70°)'**
  String get lightPage_angleRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get lightPage_calculate;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get lightPage_channel;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get lightPage_channels;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Distance (1m to 40m)'**
  String get lightPage_distanceRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Height (1m to 20m)'**
  String get lightPage_heightRange;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'LED Length (in meters)'**
  String get lightPage_ledLength;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get lightPage_meters;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Lighting Equipment'**
  String get lightPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get lightPage_total;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'mounting Tools'**
  String get mountingTools;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Network'**
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

  /// No description provided for @paymentPage_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get paymentPage_title;

  /// No description provided for @paymentPage_monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get paymentPage_monthlyPlan;

  /// No description provided for @paymentPage_yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
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
  /// **'Payment successful!'**
  String get paymentPage_paymentSuccess;

  /// No description provided for @paymentPage_subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Your premium subscription has been activated successfully!'**
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

  /// No description provided for @paymentPage_featureCompleteCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Complete catalogue'**
  String get paymentPage_featureCompleteCatalogue;

  /// No description provided for @paymentPage_featureProjectsPresets.
  ///
  /// In en, this message translates to:
  /// **'Projects and presets'**
  String get paymentPage_featureProjectsPresets;

  /// No description provided for @paymentPage_featureExportPdfExcel.
  ///
  /// In en, this message translates to:
  /// **'PDF/Excel export'**
  String get paymentPage_featureExportPdfExcel;

  /// No description provided for @paymentPage_featurePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get paymentPage_featurePrioritySupport;

  /// No description provided for @paymentPage_featureAutoUpdates.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates'**
  String get paymentPage_featureAutoUpdates;

  /// No description provided for @paymentPage_featureSavings.
  ///
  /// In en, this message translates to:
  /// **'33% savings'**
  String get paymentPage_featureSavings;

  /// No description provided for @paymentPage_descriptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Full access to all features'**
  String get paymentPage_descriptionMonthly;

  /// No description provided for @paymentPage_descriptionYearly.
  ///
  /// In en, this message translates to:
  /// **'Save 33% with annual subscription'**
  String get paymentPage_descriptionYearly;

  /// No description provided for @paymentPage_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get paymentPage_popular;

  /// No description provided for @paymentPage_bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paymentPage_bestValue;

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
  /// **'Power'**
  String get projectCalculationPage_powerTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get projectCalculationPage_weightTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get electricityPage_powerTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get videoPage_projectionTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'LED Wall'**
  String get videoPage_ledWallTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get videoPage_timerTab;

  /// No description provided for @catalogue_addToPreset.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get catalogue_addToPreset;

  /// No description provided for @catalogue_confirmAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get catalogue_confirmAddTitle;

  /// No description provided for @catalogue_confirmAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Add {count} {product} to {preset}?'**
  String catalogue_confirmAddMessage(
      Object count, Object preset, Object product);

  /// No description provided for @catalogue_mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get catalogue_mode;

  /// No description provided for @catalogue_wired.
  ///
  /// In en, this message translates to:
  /// **'Wired'**
  String get catalogue_wired;

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
  /// **'Sound'**
  String get soundMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get soundPage_quantity;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Audio Equipment'**
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
  /// **'Structure'**
  String get structureMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'3 Points'**
  String get structurePage_3pointsAccroche;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'4 Points'**
  String get structurePage_4pointsAccroche;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Distributed Load'**
  String get structurePage_chargeRepartie;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Charge Type'**
  String get structurePage_chargeType;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Charges'**
  String get structurePage_chargesTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Deflection Ratio'**
  String get structurePage_deflectionRatioTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String structurePage_distance(Object distance);

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get structurePage_length;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Max Deflection'**
  String get structurePage_maxDeflectionTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Max Load'**
  String get structurePage_maxLoadTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Modifier'**
  String get structurePage_modifier;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Center Point'**
  String get structurePage_pointAccrocheCentre;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'End Points'**
  String get structurePage_pointsAccrocheExtremites;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Project Weight'**
  String get structurePage_projectWeightTab;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Select Charge'**
  String get structurePage_selectCharge;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structurePage_structure;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Structure Weight'**
  String get structurePage_structureWeightTitle;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structurePage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get subscription_choose_plan;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get subscription_description;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get subscription_free_trial;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get subscription_popular;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscription_premium;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get subscription_security;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Security Description'**
  String get subscription_security_description;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
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
  /// **'Video'**
  String get videoMenu;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get videoPage_brand;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get videoPage_format;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Image Width'**
  String get videoPage_imageWidth;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get videoPage_model;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Overlap'**
  String get videoPage_overlap;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Projector Count'**
  String get videoPage_projectorCount;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Projector Distance'**
  String get videoPage_projectorDistance;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Schema'**
  String get videoPage_schema;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Select LED Wall'**
  String get videoPage_selectLedWall;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get videoPage_selectProduct;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoPage_title;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// auto-added from code scan
  ///
  /// In en, this message translates to:
  /// **'Volts'**
  String get volts;

  /// Name of the first default project
  ///
  /// In en, this message translates to:
  /// **'Project 1'**
  String get defaultProject1;

  /// Name of the second default project
  ///
  /// In en, this message translates to:
  /// **'Project 2'**
  String get defaultProject2;

  /// Name of the third default project
  ///
  /// In en, this message translates to:
  /// **'Project 3'**
  String get defaultProject3;

  /// No description provided for @dmxPage_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get dmxPage_warning;

  /// No description provided for @dmxPage_productsNotPlaced.
  ///
  /// In en, this message translates to:
  /// **'products not placed'**
  String get dmxPage_productsNotPlaced;

  /// No description provided for @dmxPage_maxIterationsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum iterations reached'**
  String get dmxPage_maxIterationsReached;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_required;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalid_email;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_required;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @auth_service_loading.
  ///
  /// In en, this message translates to:
  /// **'Authentication service loading'**
  String get auth_service_loading;

  /// No description provided for @auth_service_error.
  ///
  /// In en, this message translates to:
  /// **'Authentication service error'**
  String get auth_service_error;

  /// No description provided for @invalid_credentials_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalid_credentials_error;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connection_error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @enter_email_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enter_email_first;

  /// No description provided for @reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'A reset email has been sent. Check your inbox and spam folder.'**
  String get reset_email_sent;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @or_continue_with.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get or_continue_with;

  /// No description provided for @google_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get google_sign_in;

  /// No description provided for @biometric_auth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Auth'**
  String get biometric_auth;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @welcome_to_avwallet.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AVWallet'**
  String get welcome_to_avwallet;

  /// No description provided for @welcome_to_avwallet_with_name.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AVWallet, {name}'**
  String welcome_to_avwallet_with_name(Object name);

  /// No description provided for @premium_usage_remaining.
  ///
  /// In en, this message translates to:
  /// **'You have premium usage.\\nYou have {count} uses remaining'**
  String premium_usage_remaining(Object count);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirm_password_required;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_dont_match;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @verification_code_sent_message.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent'**
  String get verification_code_sent_message;

  /// No description provided for @verification_code.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verification_code;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome_title;

  /// No description provided for @welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome message'**
  String get welcome_message;

  /// No description provided for @beam_short.
  ///
  /// In en, this message translates to:
  /// **'Beam'**
  String get beam_short;

  /// No description provided for @default_project_name.
  ///
  /// In en, this message translates to:
  /// **'Default Project'**
  String get default_project_name;

  /// No description provided for @no_projects_available.
  ///
  /// In en, this message translates to:
  /// **'No projects available to load'**
  String get no_projects_available;

  /// No description provided for @project_loaded.
  ///
  /// In en, this message translates to:
  /// **'Project \"{name}\" loaded!'**
  String project_loaded(Object name);

  /// No description provided for @export_project_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to export project \"{name}\"?'**
  String export_project_confirm(Object name);

  /// No description provided for @generating_pdfs.
  ///
  /// In en, this message translates to:
  /// **'Generating PDFs...'**
  String get generating_pdfs;

  /// No description provided for @files_exported_success.
  ///
  /// In en, this message translates to:
  /// **'{count} files exported successfully!'**
  String files_exported_success(Object count);

  /// No description provided for @no_files_to_export.
  ///
  /// In en, this message translates to:
  /// **'No files to export for this project'**
  String get no_files_to_export;

  /// No description provided for @export_error.
  ///
  /// In en, this message translates to:
  /// **'Error during export: {error}'**
  String export_error(Object error);

  /// No description provided for @project_saved_locally.
  ///
  /// In en, this message translates to:
  /// **'The project will be saved locally.'**
  String get project_saved_locally;

  /// No description provided for @project_saved.
  ///
  /// In en, this message translates to:
  /// **'Project saved!'**
  String get project_saved;

  /// No description provided for @export_to_project.
  ///
  /// In en, this message translates to:
  /// **'To Project'**
  String get export_to_project;

  /// No description provided for @export_sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get export_sms;

  /// No description provided for @export_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get export_whatsapp;

  /// No description provided for @export_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get export_email;

  /// No description provided for @export_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_tooltip;

  /// No description provided for @photos_project_title.
  ///
  /// In en, this message translates to:
  /// **'PROJECT PHOTOS'**
  String get photos_project_title;

  /// No description provided for @photos_ar_captured.
  ///
  /// In en, this message translates to:
  /// **'Photos captured during AR measurements:'**
  String get photos_ar_captured;

  /// No description provided for @photo_label.
  ///
  /// In en, this message translates to:
  /// **'Photo: {filename}'**
  String photo_label(Object filename);

  /// No description provided for @article_label.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article_label;

  /// No description provided for @quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantity_label;

  /// No description provided for @catalogueQuantityDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get catalogueQuantityDialog_title;

  /// No description provided for @catalogueQuantityDialog_enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get catalogueQuantityDialog_enterQuantity;

  /// No description provided for @catalogueQuantityDialog_dmxType.
  ///
  /// In en, this message translates to:
  /// **'DMX Type'**
  String get catalogueQuantityDialog_dmxType;

  /// No description provided for @catalogueQuantityDialog_dmxMini.
  ///
  /// In en, this message translates to:
  /// **'DMX mini'**
  String get catalogueQuantityDialog_dmxMini;

  /// No description provided for @catalogueQuantityDialog_dmxMax.
  ///
  /// In en, this message translates to:
  /// **'DMX max'**
  String get catalogueQuantityDialog_dmxMax;

  /// No description provided for @catalogueQuantityDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogueQuantityDialog_cancel;

  /// No description provided for @catalogueQuantityDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get catalogueQuantityDialog_confirm;

  /// No description provided for @power_label.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power_label;

  /// No description provided for @weight_label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight_label;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @create_button.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create_button;

  /// No description provided for @save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_button;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button;

  /// No description provided for @weight_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight_tab_title;

  /// No description provided for @imports.
  ///
  /// In en, this message translates to:
  /// **'Imports'**
  String get imports;

  /// No description provided for @calculation_dmx.
  ///
  /// In en, this message translates to:
  /// **'DMX Calculation'**
  String get calculation_dmx;

  /// No description provided for @calculation_sound.
  ///
  /// In en, this message translates to:
  /// **'Sound Calculation'**
  String get calculation_sound;

  /// No description provided for @calculation_projection.
  ///
  /// In en, this message translates to:
  /// **'Projection Calculation'**
  String get calculation_projection;

  /// No description provided for @calculation_led_wall.
  ///
  /// In en, this message translates to:
  /// **'LED Wall Calculation'**
  String get calculation_led_wall;

  /// No description provided for @calculation_charges.
  ///
  /// In en, this message translates to:
  /// **'Charges Calculation'**
  String get calculation_charges;

  /// No description provided for @standard_welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AVWallet, {name}'**
  String standard_welcome_message(Object name);

  /// No description provided for @standard_welcome_usage_remaining.
  ///
  /// In en, this message translates to:
  /// **'You have {count} uses remaining'**
  String standard_welcome_usage_remaining(Object count);

  /// No description provided for @standard_welcome_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get standard_welcome_continue;

  /// No description provided for @premium_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Welcome!'**
  String get premium_welcome_title;

  /// No description provided for @premium_welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, Premium activated'**
  String get premium_welcome_message;

  /// No description provided for @premium_benefits_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Benefits'**
  String get premium_benefits_title;

  /// No description provided for @premium_benefit_unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited usage'**
  String get premium_benefit_unlimited;

  /// No description provided for @premium_benefit_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premium_benefit_priority;

  /// No description provided for @premium_benefit_support.
  ///
  /// In en, this message translates to:
  /// **'Dedicated technical assistance'**
  String get premium_benefit_support;

  /// No description provided for @premium_welcome_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get premium_welcome_later;

  /// No description provided for @premium_welcome_continue.
  ///
  /// In en, this message translates to:
  /// **'Explore Premium'**
  String get premium_welcome_continue;

  /// No description provided for @premium_vip_welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you are part of the VIP AV Wallet team'**
  String get premium_vip_welcome_message;

  /// No description provided for @premium_vip_access_activated.
  ///
  /// In en, this message translates to:
  /// **'Unlimited premium access activated'**
  String get premium_vip_access_activated;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @project_parameters.
  ///
  /// In en, this message translates to:
  /// **'Project Parameters'**
  String get project_parameters;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @mounting_date.
  ///
  /// In en, this message translates to:
  /// **'Mounting date (DD/MM/YY)'**
  String get mounting_date;

  /// No description provided for @period_from.
  ///
  /// In en, this message translates to:
  /// **'Date: from DD/MM/YY'**
  String get period_from;

  /// No description provided for @period_to.
  ///
  /// In en, this message translates to:
  /// **'to DD/MM/YY'**
  String get period_to;

  /// No description provided for @save_parameters.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_parameters;

  /// No description provided for @project_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get project_location;

  /// No description provided for @project_mounting_date.
  ///
  /// In en, this message translates to:
  /// **'Mounting date'**
  String get project_mounting_date;

  /// No description provided for @project_period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get project_period;

  /// No description provided for @not_defined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get not_defined;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start: DD/MM/YY'**
  String get start_date;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End: DD/MM/YY'**
  String get end_date;

  /// No description provided for @calculation_sent_to_project.
  ///
  /// In en, this message translates to:
  /// **'{calculationName} sent to \"{projectName}\"'**
  String calculation_sent_to_project(
      Object calculationName, Object projectName);

  /// No description provided for @project_stats_presets.
  ///
  /// In en, this message translates to:
  /// **'Number of Presets'**
  String get project_stats_presets;

  /// No description provided for @project_stats_articles.
  ///
  /// In en, this message translates to:
  /// **'Total Number of Articles'**
  String get project_stats_articles;

  /// No description provided for @project_stats_calculations.
  ///
  /// In en, this message translates to:
  /// **'Number of Calculations'**
  String get project_stats_calculations;

  /// No description provided for @project_stats_photos.
  ///
  /// In en, this message translates to:
  /// **'Number of Photos'**
  String get project_stats_photos;

  /// No description provided for @select_photos.
  ///
  /// In en, this message translates to:
  /// **'Select Photos'**
  String get select_photos;

  /// No description provided for @photos_imported.
  ///
  /// In en, this message translates to:
  /// **'Imported Photos'**
  String get photos_imported;

  /// No description provided for @photo_exported.
  ///
  /// In en, this message translates to:
  /// **'Photo exported'**
  String get photo_exported;

  /// No description provided for @photo_not_found.
  ///
  /// In en, this message translates to:
  /// **'Photo not found'**
  String get photo_not_found;

  /// No description provided for @cabling_percentage.
  ///
  /// In en, this message translates to:
  /// **'Cabling'**
  String get cabling_percentage;

  /// No description provided for @cabling_addition.
  ///
  /// In en, this message translates to:
  /// **'+10% Cabling'**
  String get cabling_addition;

  /// No description provided for @review_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get review_popup_title;

  /// No description provided for @review_popup_message.
  ///
  /// In en, this message translates to:
  /// **'An idea, a recommendation? Your feedback interests us'**
  String get review_popup_message;

  /// No description provided for @review_popup_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get review_popup_contact;

  /// No description provided for @review_popup_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get review_popup_continue;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get coming_soon;

  /// No description provided for @bandwidth_test.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth Test'**
  String get bandwidth_test;

  /// No description provided for @bandwidth_test_title.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth'**
  String get bandwidth_test_title;

  /// No description provided for @bandwidth_test_description.
  ///
  /// In en, this message translates to:
  /// **'Test your connection speed'**
  String get bandwidth_test_description;

  /// No description provided for @bandwidth_test_start.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get bandwidth_test_start;

  /// No description provided for @bandwidth_test_results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get bandwidth_test_results;
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
