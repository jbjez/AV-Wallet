import 'package:flutter/material.dart';
import 'app_theme.dart';

extension LightPageThemeExtension on BuildContext {
  LightPageTheme get lightPageTheme => Theme.of(this).extension<LightPageTheme>()!;
  
  // Couleurs des onglets
  Color get tabSelectedColor => lightPageTheme.tabSelectedColor;
  Color get tabUnselectedColor => lightPageTheme.tabUnselectedColor;
  Color get tabIndicatorColor => lightPageTheme.tabIndicatorColor;
  
  // Couleurs des menus déroulants
  Color get dropdownTextColor => lightPageTheme.dropdownTextColor;
  Color get dropdownBackgroundColor => lightPageTheme.dropdownBackgroundColor;
  
  // Couleurs de recherche
  Color get searchTextColor => lightPageTheme.searchTextColor;
  Color get searchIconColor => lightPageTheme.searchIconColor;
  
  // Couleurs des dialogues
  Color get dialogBackgroundColor => lightPageTheme.dialogBackgroundColor;
  Color get dialogBorderColor => lightPageTheme.dialogBorderColor;
  
  // Couleurs des textes
  Color get titleTextColor => lightPageTheme.titleTextColor;
  Color get subtitleTextColor => lightPageTheme.subtitleTextColor;
  
  // Styles des onglets
  TextStyle get tabTextStyle => lightPageTheme.tabTextStyle;
  TextStyle get tabSelectedTextStyle => lightPageTheme.tabSelectedTextStyle;
}


