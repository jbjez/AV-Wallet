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
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
  /// In fr, this message translates to:
  /// **'AV Wallet'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur AV Wallet'**
  String get welcomeMessage;

  /// No description provided for @catalogAccess.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get catalogAccess;

  /// No description provided for @lightMenu.
  ///
  /// In fr, this message translates to:
  /// **'Lumière'**
  String get lightMenu;

  /// No description provided for @structureMenu.
  ///
  /// In fr, this message translates to:
  /// **'Structure'**
  String get structureMenu;

  /// No description provided for @soundMenu.
  ///
  /// In fr, this message translates to:
  /// **'Son'**
  String get soundMenu;

  /// No description provided for @videoMenu.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get videoMenu;

  /// No description provided for @electricityMenu.
  ///
  /// In fr, this message translates to:
  /// **'Élec.'**
  String get electricityMenu;

  /// No description provided for @networkMenu.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get networkMenu;

  /// No description provided for @advancedMenu.
  ///
  /// In fr, this message translates to:
  /// **'Avancé'**
  String get advancedMenu;

  /// No description provided for @lightPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Équipement Lumière'**
  String get lightPage_title;

  /// No description provided for @lightPage_beamCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Faisceau'**
  String get lightPage_beamCalculation;

  /// No description provided for @lightPage_driverCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Driver LED'**
  String get lightPage_driverCalculation;

  /// No description provided for @lightPage_dmxCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul DMX'**
  String get lightPage_dmxCalculation;

  /// No description provided for @lightPage_angleRange.
  ///
  /// In fr, this message translates to:
  /// **'Angle (1° à 70°)'**
  String get lightPage_angleRange;

  /// No description provided for @lightPage_heightRange.
  ///
  /// In fr, this message translates to:
  /// **'Hauteur (1m à 20m)'**
  String get lightPage_heightRange;

  /// No description provided for @lightPage_distanceRange.
  ///
  /// In fr, this message translates to:
  /// **'Distance (1m à 40m)'**
  String get lightPage_distanceRange;

  /// No description provided for @lightPage_measureDistance.
  ///
  /// In fr, this message translates to:
  /// **'Mesurer votre distance'**
  String get lightPage_measureDistance;

  /// No description provided for @lightPage_calculate.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get lightPage_calculate;

  /// No description provided for @lightPage_selectedProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits sélectionnés'**
  String get lightPage_selectedProducts;

  /// No description provided for @lightPage_reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get lightPage_reset;

  /// No description provided for @button_add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get button_add;

  /// No description provided for @button_reset.
  ///
  /// In fr, this message translates to:
  /// **'Reset'**
  String get button_reset;

  /// No description provided for @lightPage_ledLength.
  ///
  /// In fr, this message translates to:
  /// **'Longueur LED (en mètres)'**
  String get lightPage_ledLength;

  /// No description provided for @lightPage_brand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get lightPage_brand;

  /// No description provided for @lightPage_product.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get lightPage_product;

  /// No description provided for @lightPage_searchProduct.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit...'**
  String get lightPage_searchProduct;

  /// No description provided for @lightPage_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get lightPage_quantity;

  /// No description provided for @lightPage_enterQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Entrer la quantité'**
  String get lightPage_enterQuantity;

  /// No description provided for @lightPage_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get lightPage_cancel;

  /// No description provided for @lightPage_ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get lightPage_ok;

  /// No description provided for @lightPage_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get lightPage_confirm;

  /// No description provided for @lightPage_noFixturesSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projecteur sélectionné'**
  String get lightPage_noFixturesSelected;

  /// No description provided for @lightPage_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get lightPage_save;

  /// No description provided for @lightPage_savePreset.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le préréglage'**
  String get lightPage_savePreset;

  /// No description provided for @lightPage_presetName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du préréglage'**
  String get lightPage_presetName;

  /// No description provided for @lightPage_enterPresetName.
  ///
  /// In fr, this message translates to:
  /// **'Entrer le nom du préréglage'**
  String get lightPage_enterPresetName;

  /// No description provided for @lightPage_beamDiameter.
  ///
  /// In fr, this message translates to:
  /// **'Diamètre du faisceau'**
  String get lightPage_beamDiameter;

  /// No description provided for @lightPage_meters.
  ///
  /// In fr, this message translates to:
  /// **'mètres'**
  String get lightPage_meters;

  /// No description provided for @lightPage_recommendedConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration recommandée'**
  String get lightPage_recommendedConfig;

  /// No description provided for @lightPage_total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get lightPage_total;

  /// No description provided for @lightPage_dmxUniverses.
  ///
  /// In fr, this message translates to:
  /// **'UNIVERS DMX'**
  String get lightPage_dmxUniverses;

  /// No description provided for @arMeasurePage_title.
  ///
  /// In fr, this message translates to:
  /// **'AR Measure'**
  String get arMeasurePage_title;

  /// No description provided for @arMeasurePage_tapFirstPoint.
  ///
  /// In fr, this message translates to:
  /// **'Tapez le 1er point, puis le 2ème'**
  String get arMeasurePage_tapFirstPoint;

  /// No description provided for @arMeasurePage_tapSecondPoint.
  ///
  /// In fr, this message translates to:
  /// **'Tapez le 2ème point pour mesurer la distance'**
  String get arMeasurePage_tapSecondPoint;

  /// No description provided for @arMeasurePage_tapObject.
  ///
  /// In fr, this message translates to:
  /// **'Tapez sur un objet pour mesurer la distance'**
  String get arMeasurePage_tapObject;

  /// No description provided for @arMeasurePage_tapDistance.
  ///
  /// In fr, this message translates to:
  /// **'Tap/Distance'**
  String get arMeasurePage_tapDistance;

  /// No description provided for @arMeasurePage_modeSimple.
  ///
  /// In fr, this message translates to:
  /// **'Mode simple'**
  String get arMeasurePage_modeSimple;

  /// No description provided for @arMeasurePage_modeTwoPoints.
  ///
  /// In fr, this message translates to:
  /// **'Mode 2 points'**
  String get arMeasurePage_modeTwoPoints;

  /// No description provided for @arMeasurePage_reset.
  ///
  /// In fr, this message translates to:
  /// **'Reset'**
  String get arMeasurePage_reset;

  /// No description provided for @arMeasurePage_home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get arMeasurePage_home;

  /// No description provided for @lightPage_universe.
  ///
  /// In fr, this message translates to:
  /// **'UNIVERS'**
  String get lightPage_universe;

  /// No description provided for @lightPage_fixture.
  ///
  /// In fr, this message translates to:
  /// **'APPAREIL'**
  String get lightPage_fixture;

  /// No description provided for @lightPage_dmxChannelsUsed.
  ///
  /// In fr, this message translates to:
  /// **'canaux DMX utilisés'**
  String get lightPage_dmxChannelsUsed;

  /// No description provided for @lightPage_channel.
  ///
  /// In fr, this message translates to:
  /// **'voie'**
  String get lightPage_channel;

  /// No description provided for @lightPage_channels.
  ///
  /// In fr, this message translates to:
  /// **'voies'**
  String get lightPage_channels;

  /// No description provided for @soundPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Équipement Son'**
  String get soundPage_title;

  /// No description provided for @soundPage_amplificationTab.
  ///
  /// In fr, this message translates to:
  /// **'Amplification'**
  String get soundPage_amplificationTab;

  /// No description provided for @soundPage_decibelMeterTab.
  ///
  /// In fr, this message translates to:
  /// **'Sonomètre'**
  String get soundPage_decibelMeterTab;

  /// No description provided for @soundPage_calculProjectTab.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Projet'**
  String get soundPage_calculProjectTab;

  /// No description provided for @soundPage_amplificationLA.
  ///
  /// In fr, this message translates to:
  /// **'Amplification LA'**
  String get soundPage_amplificationLA;

  /// No description provided for @soundPage_delay.
  ///
  /// In fr, this message translates to:
  /// **'Délai'**
  String get soundPage_delay;

  /// No description provided for @soundPage_decibelMeter.
  ///
  /// In fr, this message translates to:
  /// **'Sonomètre'**
  String get soundPage_decibelMeter;

  /// No description provided for @soundPage_selectSpeaker.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une enceinte'**
  String get soundPage_selectSpeaker;

  /// No description provided for @soundPage_selectedSpeakers.
  ///
  /// In fr, this message translates to:
  /// **'Enceintes sélectionnées'**
  String get soundPage_selectedSpeakers;

  /// No description provided for @soundPage_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get soundPage_quantity;

  /// No description provided for @soundPage_calculate.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get soundPage_calculate;

  /// No description provided for @soundPage_reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get soundPage_reset;

  /// No description provided for @soundPage_optimalConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration d\'amplification recommandée'**
  String get soundPage_optimalConfig;

  /// No description provided for @soundPage_noConfig.
  ///
  /// In fr, this message translates to:
  /// **'Aucune configuration optimale trouvée pour cette combinaison d\'enceintes'**
  String get soundPage_noConfig;

  /// No description provided for @soundPage_checkCompat.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier les compatibilités'**
  String get soundPage_checkCompat;

  /// No description provided for @soundPage_addPreset.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un préréglage'**
  String get soundPage_addPreset;

  /// No description provided for @soundPage_presetName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du préréglage'**
  String get soundPage_presetName;

  /// No description provided for @soundPage_enterPresetName.
  ///
  /// In fr, this message translates to:
  /// **'Entrer le nom du préréglage'**
  String get soundPage_enterPresetName;

  /// No description provided for @soundPage_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get soundPage_save;

  /// No description provided for @soundPage_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get soundPage_cancel;

  /// No description provided for @soundPage_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get soundPage_confirm;

  /// No description provided for @soundPage_addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get soundPage_addToCart;

  /// No description provided for @soundPage_preferredAmplifier.
  ///
  /// In fr, this message translates to:
  /// **'Amplificateur préféré'**
  String get soundPage_preferredAmplifier;

  /// No description provided for @videoPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Équipement Vidéo'**
  String get videoPage_title;

  /// No description provided for @videoPage_videoCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul Vidéo'**
  String get videoPage_videoCalculation;

  /// No description provided for @videoPage_videoSimulation.
  ///
  /// In fr, this message translates to:
  /// **'Simulation Vidéo'**
  String get videoPage_videoSimulation;

  /// No description provided for @videoPage_videoControl.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle Vidéo'**
  String get videoPage_videoControl;

  /// No description provided for @videoPage_searchProduct.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get videoPage_searchProduct;

  /// No description provided for @videoPage_selectBrand.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une marque'**
  String get videoPage_selectBrand;

  /// No description provided for @videoPage_selectProduct.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un produit'**
  String get videoPage_selectProduct;

  /// No description provided for @videoPage_format.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get videoPage_format;

  /// No description provided for @videoPage_model.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get videoPage_model;

  /// No description provided for @videoPage_selectLedWall.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un mur LED'**
  String get videoPage_selectLedWall;

  /// No description provided for @videoPage_brand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get videoPage_brand;

  /// No description provided for @videoPage_projectionCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Projection'**
  String get videoPage_projectionCalculation;

  /// No description provided for @videoPage_ledWallCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Mur LED'**
  String get videoPage_ledWallCalculation;

  /// No description provided for @videoPage_projectorCount.
  ///
  /// In fr, this message translates to:
  /// **'Nb VP'**
  String get videoPage_projectorCount;

  /// No description provided for @videoPage_overlap.
  ///
  /// In fr, this message translates to:
  /// **'Chevauch.'**
  String get videoPage_overlap;

  /// No description provided for @videoPage_imageWidth.
  ///
  /// In fr, this message translates to:
  /// **'Largeur image'**
  String get videoPage_imageWidth;

  /// No description provided for @videoPage_projectorDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance projecteur'**
  String get videoPage_projectorDistance;

  /// No description provided for @videoPage_ratio.
  ///
  /// In fr, this message translates to:
  /// **'Ratio'**
  String get videoPage_ratio;

  /// No description provided for @videoPage_recommendedRatio.
  ///
  /// In fr, this message translates to:
  /// **'Ratio recommandé'**
  String get videoPage_recommendedRatio;

  /// No description provided for @videoPage_noOpticsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune optique disponible pour ce ratio'**
  String get videoPage_noOpticsAvailable;

  /// No description provided for @videoPage_schema.
  ///
  /// In fr, this message translates to:
  /// **'Schéma'**
  String get videoPage_schema;

  /// No description provided for @structurePage_title.
  ///
  /// In fr, this message translates to:
  /// **'Structure'**
  String get structurePage_title;

  /// No description provided for @selectStructure.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la structure'**
  String get selectStructure;

  /// No description provided for @distance_label.
  ///
  /// In fr, this message translates to:
  /// **'{distance} m'**
  String distance_label(String distance);

  /// No description provided for @charge_max.
  ///
  /// In fr, this message translates to:
  /// **'Charge max : {value} kg{unit}'**
  String charge_max(String value, String unit);

  /// No description provided for @beam_weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids poutre (hors charges) : {value} kg'**
  String beam_weight(String value);

  /// No description provided for @max_deflection.
  ///
  /// In fr, this message translates to:
  /// **'Flèche maximale : {value} mm'**
  String max_deflection(String value);

  /// No description provided for @deflection_rate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de flèche pris en compte : 1/200'**
  String get deflection_rate;

  /// No description provided for @structurePage_selectCharge.
  ///
  /// In fr, this message translates to:
  /// **'Type de charge'**
  String get structurePage_selectCharge;

  /// No description provided for @catalogPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get catalogPage_title;

  /// No description provided for @catalogPage_search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get catalogPage_search;

  /// No description provided for @catalogPage_category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get catalogPage_category;

  /// No description provided for @catalogPage_subCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégorie'**
  String get catalogPage_subCategory;

  /// No description provided for @catalogPage_brand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get catalogPage_brand;

  /// No description provided for @catalogPage_product.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get catalogPage_product;

  /// No description provided for @catalogPage_addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get catalogPage_addToCart;

  /// No description provided for @catalogPage_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get catalogPage_quantity;

  /// No description provided for @catalogPage_enterQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Entrer la quantité'**
  String get catalogPage_enterQuantity;

  /// No description provided for @catalogPage_cart.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get catalogPage_cart;

  /// No description provided for @catalogPage_emptyCart.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get catalogPage_emptyCart;

  /// No description provided for @catalogPage_total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get catalogPage_total;

  /// No description provided for @catalogPage_checkout.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get catalogPage_checkout;

  /// No description provided for @catalogPage_clearCart.
  ///
  /// In fr, this message translates to:
  /// **'Vider le panier'**
  String get catalogPage_clearCart;

  /// No description provided for @catalogPage_remove.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get catalogPage_remove;

  /// No description provided for @catalogPage_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get catalogPage_confirm;

  /// No description provided for @catalogPage_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get catalogPage_cancel;

  /// No description provided for @catalogPage_weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get catalogPage_weight;

  /// No description provided for @catalogPage_selectCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une catégorie'**
  String get catalogPage_selectCategory;

  /// No description provided for @catalogPage_selectSubCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une sous-catégorie'**
  String get catalogPage_selectSubCategory;

  /// No description provided for @catalogPage_noItems.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élément trouvé'**
  String get catalogPage_noItems;

  /// No description provided for @presetWidget_title.
  ///
  /// In fr, this message translates to:
  /// **'Préréglages'**
  String get presetWidget_title;

  /// No description provided for @presetWidget_add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un préréglage'**
  String get presetWidget_add;

  /// No description provided for @presetWidget_edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get presetWidget_edit;

  /// No description provided for @presetWidget_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get presetWidget_delete;

  /// No description provided for @presetWidget_confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer ce préréglage ?'**
  String get presetWidget_confirmDelete;

  /// No description provided for @presetWidget_yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get presetWidget_yes;

  /// No description provided for @presetWidget_no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get presetWidget_no;

  /// No description provided for @presetWidget_newPreset.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau préréglage'**
  String get presetWidget_newPreset;

  /// No description provided for @presetWidget_renamePreset.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le préréglage'**
  String get presetWidget_renamePreset;

  /// No description provided for @presetWidget_newName.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau nom'**
  String get presetWidget_newName;

  /// No description provided for @presetWidget_create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get presetWidget_create;

  /// No description provided for @presetWidget_defaultProject.
  ///
  /// In fr, this message translates to:
  /// **'Votre projet'**
  String get presetWidget_defaultProject;

  /// No description provided for @presetWidget_rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get presetWidget_rename;

  /// No description provided for @presetWidget_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get presetWidget_cancel;

  /// No description provided for @presetWidget_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get presetWidget_confirm;

  /// No description provided for @presetWidget_addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get presetWidget_addToCart;

  /// No description provided for @presetWidget_preferredAmplifier.
  ///
  /// In fr, this message translates to:
  /// **'Amplificateur préféré'**
  String get presetWidget_preferredAmplifier;

  /// No description provided for @projectCalculationPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de Projet'**
  String get projectCalculationPage_title;

  /// No description provided for @projectCalculationPage_powerProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet Puissance'**
  String get projectCalculationPage_powerProject;

  /// No description provided for @projectCalculationPage_weightProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet Poids'**
  String get projectCalculationPage_weightProject;

  /// No description provided for @projectCalculationPage_powerTab.
  ///
  /// In fr, this message translates to:
  /// **'Puiss.'**
  String get projectCalculationPage_powerTab;

  /// No description provided for @projectCalculationPage_weightTab.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get projectCalculationPage_weightTab;

  /// No description provided for @projectCalculationPage_noPresetSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun préréglage sélectionné'**
  String get projectCalculationPage_noPresetSelected;

  /// No description provided for @projectCalculationPage_powerConsumption.
  ///
  /// In fr, this message translates to:
  /// **'Consommation électrique'**
  String get projectCalculationPage_powerConsumption;

  /// No description provided for @projectCalculationPage_weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get projectCalculationPage_weight;

  /// No description provided for @projectCalculationPage_total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get projectCalculationPage_total;

  /// No description provided for @projectCalculationPage_presetTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total du préréglage'**
  String get projectCalculationPage_presetTotal;

  /// No description provided for @projectCalculationPage_globalTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total global'**
  String get projectCalculationPage_globalTotal;

  /// No description provided for @ledWallSchemaPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Schéma Mur LED'**
  String get ledWallSchemaPage_title;

  /// No description provided for @ledWallSchemaPage_dimensions.
  ///
  /// In fr, this message translates to:
  /// **'Dimensions'**
  String get ledWallSchemaPage_dimensions;

  /// No description provided for @ledWallSchemaPage_width.
  ///
  /// In fr, this message translates to:
  /// **'Largeur'**
  String get ledWallSchemaPage_width;

  /// No description provided for @ledWallSchemaPage_height.
  ///
  /// In fr, this message translates to:
  /// **'Hauteur'**
  String get ledWallSchemaPage_height;

  /// No description provided for @ledWallSchemaPage_panelSelection.
  ///
  /// In fr, this message translates to:
  /// **'Sélection des panneaux'**
  String get ledWallSchemaPage_panelSelection;

  /// No description provided for @ledWallSchemaPage_selectPanel.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un panneau'**
  String get ledWallSchemaPage_selectPanel;

  /// No description provided for @ledWallSchemaPage_calculate.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get ledWallSchemaPage_calculate;

  /// No description provided for @electricityPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Électricité'**
  String get electricityPage_title;

  /// No description provided for @electricityPage_project.
  ///
  /// In fr, this message translates to:
  /// **'Projet'**
  String get electricityPage_project;

  /// No description provided for @electricityPage_calculations.
  ///
  /// In fr, this message translates to:
  /// **'Calculs'**
  String get electricityPage_calculations;

  /// No description provided for @electricityPage_noPresetSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun préréglage sélectionné'**
  String get electricityPage_noPresetSelected;

  /// No description provided for @electricityPage_selectedPreset.
  ///
  /// In fr, this message translates to:
  /// **'Préréglage sélectionné'**
  String get electricityPage_selectedPreset;

  /// No description provided for @electricityPage_powerConsumption.
  ///
  /// In fr, this message translates to:
  /// **'Consommation électrique'**
  String get electricityPage_powerConsumption;

  /// No description provided for @electricityPage_presetTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total du préréglage'**
  String get electricityPage_presetTotal;

  /// No description provided for @electricityPage_globalTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total global'**
  String get electricityPage_globalTotal;

  /// No description provided for @electricityPage_consumptionByCategory.
  ///
  /// In fr, this message translates to:
  /// **'Consommation par catégorie'**
  String get electricityPage_consumptionByCategory;

  /// No description provided for @electricityPage_powerCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de puissance'**
  String get electricityPage_powerCalculation;

  /// No description provided for @electricityPage_voltage.
  ///
  /// In fr, this message translates to:
  /// **'Tension'**
  String get electricityPage_voltage;

  /// No description provided for @electricityPage_phase.
  ///
  /// In fr, this message translates to:
  /// **'Phase'**
  String get electricityPage_phase;

  /// No description provided for @electricityPage_threePhase.
  ///
  /// In fr, this message translates to:
  /// **'Triphasé'**
  String get electricityPage_threePhase;

  /// No description provided for @electricityPage_singlePhase.
  ///
  /// In fr, this message translates to:
  /// **'Monophasé'**
  String get electricityPage_singlePhase;

  /// No description provided for @electricityPage_current.
  ///
  /// In fr, this message translates to:
  /// **'Courant (A)'**
  String get electricityPage_current;

  /// No description provided for @electricityPage_power.
  ///
  /// In fr, this message translates to:
  /// **'Puissance (W)'**
  String get electricityPage_power;

  /// No description provided for @electricityPage_powerConversion.
  ///
  /// In fr, this message translates to:
  /// **'Conversion de puissance'**
  String get electricityPage_powerConversion;

  /// No description provided for @electricityPage_kw.
  ///
  /// In fr, this message translates to:
  /// **'Puissance active (kW)'**
  String get electricityPage_kw;

  /// No description provided for @electricityPage_kva.
  ///
  /// In fr, this message translates to:
  /// **'Puissance apparente (kVA)'**
  String get electricityPage_kva;

  /// No description provided for @electricityPage_powerFactor.
  ///
  /// In fr, this message translates to:
  /// **'Facteur de puissance'**
  String get electricityPage_powerFactor;

  /// No description provided for @networkPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get networkPage_title;

  /// No description provided for @networkPage_bandwidth.
  ///
  /// In fr, this message translates to:
  /// **'Bande passante'**
  String get networkPage_bandwidth;

  /// No description provided for @networkPage_networkScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan réseau'**
  String get networkPage_networkScan;

  /// No description provided for @networkPage_detectedNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau détecté'**
  String get networkPage_detectedNetwork;

  /// No description provided for @networkPage_noNetworkDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun réseau détecté'**
  String get networkPage_noNetworkDetected;

  /// No description provided for @networkPage_testBandwidth.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le test'**
  String get networkPage_testBandwidth;

  /// No description provided for @networkPage_testResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats du test'**
  String get networkPage_testResults;

  /// No description provided for @networkPage_bandwidthTestInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Test de bande passante en cours...'**
  String get networkPage_bandwidthTestInProgress;

  /// No description provided for @networkPage_download.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement'**
  String get networkPage_download;

  /// No description provided for @networkPage_upload.
  ///
  /// In fr, this message translates to:
  /// **'Envoi'**
  String get networkPage_upload;

  /// No description provided for @networkPage_downloadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du téléchargement'**
  String get networkPage_downloadError;

  /// No description provided for @networkPage_scanError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du scan réseau'**
  String get networkPage_scanError;

  /// No description provided for @networkPage_noNetworksFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun réseau trouvé'**
  String get networkPage_noNetworksFound;

  /// No description provided for @networkPage_signalStrength.
  ///
  /// In fr, this message translates to:
  /// **'Force du signal'**
  String get networkPage_signalStrength;

  /// No description provided for @networkPage_frequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get networkPage_frequency;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @resetApp.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser l\'application'**
  String get resetApp;

  /// No description provided for @resetAppDescription.
  ///
  /// In fr, this message translates to:
  /// **'Supprime toutes les données locales et simule une première visite'**
  String get resetAppDescription;

  /// No description provided for @resetUserData.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les données utilisateur'**
  String get resetUserData;

  /// No description provided for @resetUserDataDescription.
  ///
  /// In fr, this message translates to:
  /// **'Supprime uniquement les données utilisateur (projets, panier, etc.)'**
  String get resetUserDataDescription;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la réinitialisation'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir réinitialiser l\'application ? Cette action est irréversible.'**
  String get resetConfirmMessage;

  /// No description provided for @resetUserDataConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer toutes vos données utilisateur ? Cette action est irréversible.'**
  String get resetUserDataConfirmMessage;

  /// No description provided for @resetComplete.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation terminée'**
  String get resetComplete;

  /// No description provided for @resetError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la réinitialisation'**
  String get resetError;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @patchScenePage_title.
  ///
  /// In fr, this message translates to:
  /// **'Patch Scène'**
  String get patchScenePage_title;

  /// No description provided for @patchScenePage_createPatch.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton patch !'**
  String get patchScenePage_createPatch;

  /// No description provided for @patchScenePage_input.
  ///
  /// In fr, this message translates to:
  /// **'ENTRÉE'**
  String get patchScenePage_input;

  /// No description provided for @patchScenePage_output.
  ///
  /// In fr, this message translates to:
  /// **'SORTIE'**
  String get patchScenePage_output;

  /// No description provided for @patchScenePage_track.
  ///
  /// In fr, this message translates to:
  /// **'PISTE'**
  String get patchScenePage_track;

  /// No description provided for @patchScenePage_track1.
  ///
  /// In fr, this message translates to:
  /// **'PISTE 1'**
  String get patchScenePage_track1;

  /// No description provided for @patchScenePage_instrument_dj.
  ///
  /// In fr, this message translates to:
  /// **'DJ'**
  String get patchScenePage_instrument_dj;

  /// No description provided for @patchScenePage_instrument_voice.
  ///
  /// In fr, this message translates to:
  /// **'Voix'**
  String get patchScenePage_instrument_voice;

  /// No description provided for @patchScenePage_instrument_piano.
  ///
  /// In fr, this message translates to:
  /// **'Piano'**
  String get patchScenePage_instrument_piano;

  /// No description provided for @patchScenePage_instrument_drums.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get patchScenePage_instrument_drums;

  /// No description provided for @patchScenePage_instrument_bass.
  ///
  /// In fr, this message translates to:
  /// **'Bass'**
  String get patchScenePage_instrument_bass;

  /// No description provided for @patchScenePage_instrument_guitar.
  ///
  /// In fr, this message translates to:
  /// **'Guitare'**
  String get patchScenePage_instrument_guitar;

  /// No description provided for @patchScenePage_instrument_brass.
  ///
  /// In fr, this message translates to:
  /// **'Cuivres'**
  String get patchScenePage_instrument_brass;

  /// No description provided for @patchScenePage_instrument_violin.
  ///
  /// In fr, this message translates to:
  /// **'Violon'**
  String get patchScenePage_instrument_violin;

  /// No description provided for @patchScenePage_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get patchScenePage_quantity;

  /// No description provided for @patchScenePage_rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get patchScenePage_rename;

  /// No description provided for @patchScenePage_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get patchScenePage_delete;

  /// No description provided for @patchScenePage_newName.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau nom'**
  String get patchScenePage_newName;

  /// No description provided for @patchScenePage_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get patchScenePage_confirm;

  /// No description provided for @patchScenePage_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get patchScenePage_cancel;

  /// No description provided for @patch_title.
  ///
  /// In fr, this message translates to:
  /// **'Patch Scène'**
  String get patch_title;

  /// No description provided for @patch_input.
  ///
  /// In fr, this message translates to:
  /// **'INPUT'**
  String get patch_input;

  /// No description provided for @patch_output.
  ///
  /// In fr, this message translates to:
  /// **'OUTPUT'**
  String get patch_output;

  /// No description provided for @patch_add_track.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une piste'**
  String get patch_add_track;

  /// No description provided for @patch_ajout.
  ///
  /// In fr, this message translates to:
  /// **'Ajout'**
  String get patch_ajout;

  /// No description provided for @structurePage_distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get structurePage_distance;

  /// No description provided for @structurePage_chargeRepartie.
  ///
  /// In fr, this message translates to:
  /// **'Charge répartie uniformément'**
  String get structurePage_chargeRepartie;

  /// No description provided for @structurePage_pointAccrocheCentre.
  ///
  /// In fr, this message translates to:
  /// **'1 point d\'accroche au centre'**
  String get structurePage_pointAccrocheCentre;

  /// No description provided for @structurePage_pointsAccrocheExtremites.
  ///
  /// In fr, this message translates to:
  /// **'2 points d\'accroche aux extrémités'**
  String get structurePage_pointsAccrocheExtremites;

  /// No description provided for @structurePage_3pointsAccroche.
  ///
  /// In fr, this message translates to:
  /// **'3 points d\'accroche'**
  String get structurePage_3pointsAccroche;

  /// No description provided for @structurePage_4pointsAccroche.
  ///
  /// In fr, this message translates to:
  /// **'4 points d\'accroche'**
  String get structurePage_4pointsAccroche;

  /// No description provided for @structurePage_chargeMaximale.
  ///
  /// In fr, this message translates to:
  /// **'Charge maximale'**
  String get structurePage_chargeMaximale;

  /// No description provided for @structurePage_poidsStructure.
  ///
  /// In fr, this message translates to:
  /// **'Poids de la structure'**
  String get structurePage_poidsStructure;

  /// No description provided for @structurePage_flecheMaximale.
  ///
  /// In fr, this message translates to:
  /// **'Flèche maximale'**
  String get structurePage_flecheMaximale;

  /// No description provided for @structurePage_ratioFleche.
  ///
  /// In fr, this message translates to:
  /// **'Ratio de flèche'**
  String get structurePage_ratioFleche;

  /// No description provided for @structurePage_annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get structurePage_annuler;

  /// No description provided for @structurePage_quantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get structurePage_quantite;

  /// No description provided for @structurePage_modifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get structurePage_modifier;

  /// No description provided for @projectPage_title.
  ///
  /// In fr, this message translates to:
  /// **'Voir Projet'**
  String get projectPage_title;

  /// No description provided for @projectPage_powerTab.
  ///
  /// In fr, this message translates to:
  /// **'Projet Puissance'**
  String get projectPage_powerTab;

  /// No description provided for @projectPage_weightTab.
  ///
  /// In fr, this message translates to:
  /// **'Projet Poids'**
  String get projectPage_weightTab;

  /// No description provided for @projectPage_totalArticles.
  ///
  /// In fr, this message translates to:
  /// **'Nb total articles'**
  String get projectPage_totalArticles;

  /// No description provided for @projectPage_totalPower.
  ///
  /// In fr, this message translates to:
  /// **'Total Puissance'**
  String get projectPage_totalPower;

  /// No description provided for @projectPage_totalWeight.
  ///
  /// In fr, this message translates to:
  /// **'Total Poids'**
  String get projectPage_totalWeight;

  /// No description provided for @projectPage_preset.
  ///
  /// In fr, this message translates to:
  /// **'Preset'**
  String get projectPage_preset;

  /// No description provided for @projectPage_articles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get projectPage_articles;

  /// No description provided for @projectPage_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get projectPage_quantity;

  /// No description provided for @projectPage_power.
  ///
  /// In fr, this message translates to:
  /// **'Puissance'**
  String get projectPage_power;

  /// No description provided for @projectPage_weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get projectPage_weight;

  /// No description provided for @projectPage_category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get projectPage_category;

  /// No description provided for @projectPage_exportCount.
  ///
  /// In fr, this message translates to:
  /// **'Nb Export'**
  String get projectPage_exportCount;

  /// No description provided for @projectPage_searchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un article...'**
  String get projectPage_searchPlaceholder;

  /// No description provided for @projectPage_searchResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats de recherche'**
  String get projectPage_searchResults;

  /// No description provided for @projectPage_modify.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get projectPage_modify;

  /// No description provided for @projectPage_addToPreset.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au preset'**
  String get projectPage_addToPreset;

  /// No description provided for @projectPage_enterQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Entrez la quantité'**
  String get projectPage_enterQuantity;

  /// No description provided for @projectPage_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get projectPage_confirm;

  /// No description provided for @projectPage_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get projectPage_cancel;

  /// No description provided for @projectPage_powerTabShort.
  ///
  /// In fr, this message translates to:
  /// **'Puiss.'**
  String get projectPage_powerTabShort;

  /// No description provided for @projectPage_weightTabShort.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get projectPage_weightTabShort;

  /// No description provided for @defaultProjectName.
  ///
  /// In fr, this message translates to:
  /// **'Projet'**
  String get defaultProjectName;

  /// No description provided for @defaultPresetName.
  ///
  /// In fr, this message translates to:
  /// **'Preset'**
  String get defaultPresetName;

  /// No description provided for @newProject.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Projet'**
  String get newProject;

  /// No description provided for @saveProject.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder le Projet'**
  String get saveProject;

  /// No description provided for @loadProject.
  ///
  /// In fr, this message translates to:
  /// **'Charger un Projet'**
  String get loadProject;

  /// No description provided for @exportProject.
  ///
  /// In fr, this message translates to:
  /// **'Exporter le Projet'**
  String get exportProject;

  /// No description provided for @projectNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du nouveau projet'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Festival Rock, Théâtre...'**
  String get projectNameHint;

  /// No description provided for @projectArchiveInfo.
  ///
  /// In fr, this message translates to:
  /// **'L\'ancien projet sera automatiquement archivé.'**
  String get projectArchiveInfo;

  /// No description provided for @projectSaved.
  ///
  /// In fr, this message translates to:
  /// **'Projet sauvegardé !'**
  String get projectSaved;

  /// No description provided for @noProjectsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet disponible à charger'**
  String get noProjectsAvailable;

  /// No description provided for @selectProjectToLoad.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un projet à charger :'**
  String get selectProjectToLoad;

  /// No description provided for @projectExportTitle.
  ///
  /// In fr, this message translates to:
  /// **'PROJET : {name}'**
  String projectExportTitle(Object name);

  /// No description provided for @exportDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'export : {date}'**
  String exportDate(Object date);

  /// No description provided for @presetsToExport.
  ///
  /// In fr, this message translates to:
  /// **'{count} preset{count, plural, =1 {} other {s}} à exporter'**
  String presetsToExport(num count);

  /// No description provided for @defaultProject1.
  ///
  /// In fr, this message translates to:
  /// **'Projet 1'**
  String get defaultProject1;

  /// No description provided for @defaultProject2.
  ///
  /// In fr, this message translates to:
  /// **'Projet 2'**
  String get defaultProject2;

  /// No description provided for @defaultProject3.
  ///
  /// In fr, this message translates to:
  /// **'Projet 3'**
  String get defaultProject3;

  /// No description provided for @presetView.
  ///
  /// In fr, this message translates to:
  /// **'Voir Preset'**
  String get presetView;

  /// No description provided for @presetRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer Preset'**
  String get presetRename;

  /// No description provided for @presetDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer Preset'**
  String get presetDelete;

  /// No description provided for @presetDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer Preset'**
  String get presetDuplicate;

  /// No description provided for @presetNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Preset'**
  String get presetNew;

  /// No description provided for @presetName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du Preset'**
  String get presetName;

  /// No description provided for @presetEnterName.
  ///
  /// In fr, this message translates to:
  /// **'Entrer le nom du preset'**
  String get presetEnterName;

  /// No description provided for @presetRenameTo.
  ///
  /// In fr, this message translates to:
  /// **'Renommer en'**
  String get presetRenameTo;

  /// No description provided for @presetDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Preset supprimé'**
  String get presetDeleted;

  /// No description provided for @presetRenamed.
  ///
  /// In fr, this message translates to:
  /// **'Preset renommé'**
  String get presetRenamed;

  /// No description provided for @presetCreated.
  ///
  /// In fr, this message translates to:
  /// **'Preset créé'**
  String get presetCreated;

  /// No description provided for @presetLoad.
  ///
  /// In fr, this message translates to:
  /// **'Charger Preset'**
  String get presetLoad;

  /// No description provided for @presetSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder Preset'**
  String get presetSave;

  /// No description provided for @presetExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter Preset'**
  String get presetExport;

  /// No description provided for @presetImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer Preset'**
  String get presetImport;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @renameProject.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le Projet'**
  String get renameProject;

  /// No description provided for @enterProjectName.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau nom du projet'**
  String get enterProjectName;

  /// No description provided for @projectRenamed.
  ///
  /// In fr, this message translates to:
  /// **'Projet renommé en'**
  String get projectRenamed;

  /// No description provided for @noPresetSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun preset sélectionné'**
  String get noPresetSelected;

  /// No description provided for @searchArticlePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un article...'**
  String get searchArticlePlaceholder;

  /// No description provided for @searchResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats de recherche'**
  String get searchResults;

  /// No description provided for @presetCount.
  ///
  /// In fr, this message translates to:
  /// **'Nb Preset'**
  String get presetCount;

  /// No description provided for @totalArticlesCount.
  ///
  /// In fr, this message translates to:
  /// **'Nb total articles'**
  String get totalArticlesCount;

  /// No description provided for @exportCount.
  ///
  /// In fr, this message translates to:
  /// **'Nb Export'**
  String get exportCount;

  /// No description provided for @presetCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get presetCategory;

  /// No description provided for @articleName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'article'**
  String get articleName;

  /// No description provided for @quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantity;

  /// No description provided for @power.
  ///
  /// In fr, this message translates to:
  /// **'Puissance'**
  String get power;

  /// No description provided for @weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get weight;

  /// No description provided for @totalPreset.
  ///
  /// In fr, this message translates to:
  /// **'Total Preset'**
  String get totalPreset;

  /// No description provided for @totalProject.
  ///
  /// In fr, this message translates to:
  /// **'Total Projet'**
  String get totalProject;

  /// No description provided for @totalPower.
  ///
  /// In fr, this message translates to:
  /// **'Total Puissance'**
  String get totalPower;

  /// No description provided for @totalWeight.
  ///
  /// In fr, this message translates to:
  /// **'Total Poids'**
  String get totalWeight;

  /// No description provided for @unitWatt.
  ///
  /// In fr, this message translates to:
  /// **'W'**
  String get unitWatt;

  /// No description provided for @unitKilowatt.
  ///
  /// In fr, this message translates to:
  /// **'kW'**
  String get unitKilowatt;

  /// No description provided for @unitKilogram.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// No description provided for @addToPreset.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au preset'**
  String get addToPreset;

  /// No description provided for @enterQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Entrer la quantité'**
  String get enterQuantity;

  /// No description provided for @modify.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modify;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get rename;

  /// No description provided for @duplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get duplicate;

  /// No description provided for @view.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get save;

  /// No description provided for @load.
  ///
  /// In fr, this message translates to:
  /// **'Charger'**
  String get load;

  /// No description provided for @export.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get export;

  /// No description provided for @import.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get import;

  /// No description provided for @newItem.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get newItem;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Éditer'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @patch_instrument.
  ///
  /// In fr, this message translates to:
  /// **'Instrument'**
  String get patch_instrument;

  /// No description provided for @patch_destination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get patch_destination;

  /// No description provided for @patch_type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get patch_type;

  /// No description provided for @patch_quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get patch_quantity;

  /// No description provided for @patch_track_name.
  ///
  /// In fr, this message translates to:
  /// **'Nom de piste'**
  String get patch_track_name;

  /// No description provided for @patch_rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get patch_rename;

  /// No description provided for @patch_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get patch_delete;

  /// No description provided for @patch_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get patch_cancel;

  /// No description provided for @patch_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get patch_confirm;

  /// No description provided for @patch_export_png.
  ///
  /// In fr, this message translates to:
  /// **'Exporter PNG'**
  String get patch_export_png;

  /// No description provided for @patch_export_csv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter CSV'**
  String get patch_export_csv;

  /// No description provided for @patch_saved_to.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {path}'**
  String patch_saved_to(Object path);

  /// No description provided for @patch_export_failed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'export'**
  String get patch_export_failed;

  /// No description provided for @patch_no_entries.
  ///
  /// In fr, this message translates to:
  /// **'Aucune piste'**
  String get patch_no_entries;

  /// No description provided for @patch_number.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get patch_number;

  /// No description provided for @patch_source.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get patch_source;

  /// No description provided for @patch_microphone.
  ///
  /// In fr, this message translates to:
  /// **'Microphone'**
  String get patch_microphone;

  /// No description provided for @patch_output_dest.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get patch_output_dest;

  /// No description provided for @patch_output_kind.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get patch_output_kind;

  /// No description provided for @loginMenu_accountSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres du compte'**
  String get loginMenu_accountSettings;

  /// No description provided for @loginMenu_myProjects.
  ///
  /// In fr, this message translates to:
  /// **'Mes projets'**
  String get loginMenu_myProjects;

  /// No description provided for @loginMenu_logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get loginMenu_logout;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
