import 'package:flutter/material.dart';
import 'colors.dart';

class ResultContainerTheme extends ThemeExtension<ResultContainerTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final TextStyle titleStyle;

  const ResultContainerTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.textStyle,
    required this.titleStyle,
  });

  @override
  ThemeExtension<ResultContainerTheme> copyWith({
    Color? backgroundColor,
    Color? borderColor,
    TextStyle? textStyle,
    TextStyle? titleStyle,
  }) {
    return ResultContainerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textStyle: textStyle ?? this.textStyle,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }

  @override
  ThemeExtension<ResultContainerTheme> lerp(
    ThemeExtension<ResultContainerTheme>? other,
    double t,
  ) {
    if (other is! ResultContainerTheme) {
      return this;
    }
    return ResultContainerTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
    );
  }
}

class LightPageTheme extends ThemeExtension<LightPageTheme> {
  final Color tabBackgroundColor;
  final Color tabSelectedColor;
  final Color tabUnselectedColor;
  final Color tabIndicatorColor;
  final TextStyle tabTextStyle;
  final TextStyle tabSelectedTextStyle;
  final Color dropdownTextColor;
  final Color dropdownBackgroundColor;
  final Color searchTextColor;
  final Color searchIconColor;
  final Color dialogBackgroundColor;
  final Color dialogBorderColor;
  final Color titleTextColor;
  final Color subtitleTextColor;

  const LightPageTheme({
    required this.tabBackgroundColor,
    required this.tabSelectedColor,
    required this.tabUnselectedColor,
    required this.tabIndicatorColor,
    required this.tabTextStyle,
    required this.tabSelectedTextStyle,
    required this.dropdownTextColor,
    required this.dropdownBackgroundColor,
    required this.searchTextColor,
    required this.searchIconColor,
    required this.dialogBackgroundColor,
    required this.dialogBorderColor,
    required this.titleTextColor,
    required this.subtitleTextColor,
  });

  @override
  ThemeExtension<LightPageTheme> copyWith({
    Color? tabBackgroundColor,
    Color? tabSelectedColor,
    Color? tabUnselectedColor,
    Color? tabIndicatorColor,
    TextStyle? tabTextStyle,
    TextStyle? tabSelectedTextStyle,
    Color? dropdownTextColor,
    Color? dropdownBackgroundColor,
    Color? searchTextColor,
    Color? searchIconColor,
    Color? dialogBackgroundColor,
    Color? dialogBorderColor,
    Color? titleTextColor,
    Color? subtitleTextColor,
  }) {
    return LightPageTheme(
      tabBackgroundColor: tabBackgroundColor ?? this.tabBackgroundColor,
      tabSelectedColor: tabSelectedColor ?? this.tabSelectedColor,
      tabUnselectedColor: tabUnselectedColor ?? this.tabUnselectedColor,
      tabIndicatorColor: tabIndicatorColor ?? this.tabIndicatorColor,
      tabTextStyle: tabTextStyle ?? this.tabTextStyle,
      tabSelectedTextStyle: tabSelectedTextStyle ?? this.tabSelectedTextStyle,
      dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
      dropdownBackgroundColor: dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      searchTextColor: searchTextColor ?? this.searchTextColor,
      searchIconColor: searchIconColor ?? this.searchIconColor,
      dialogBackgroundColor: dialogBackgroundColor ?? this.dialogBackgroundColor,
      dialogBorderColor: dialogBorderColor ?? this.dialogBorderColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      subtitleTextColor: subtitleTextColor ?? this.subtitleTextColor,
    );
  }

  @override
  ThemeExtension<LightPageTheme> lerp(
    ThemeExtension<LightPageTheme>? other,
    double t,
  ) {
    if (other is! LightPageTheme) {
      return this;
    }
    return LightPageTheme(
      tabBackgroundColor: Color.lerp(tabBackgroundColor, other.tabBackgroundColor, t)!,
      tabSelectedColor: Color.lerp(tabSelectedColor, other.tabSelectedColor, t)!,
      tabUnselectedColor: Color.lerp(tabUnselectedColor, other.tabUnselectedColor, t)!,
      tabIndicatorColor: Color.lerp(tabIndicatorColor, other.tabIndicatorColor, t)!,
      tabTextStyle: TextStyle.lerp(tabTextStyle, other.tabTextStyle, t)!,
      tabSelectedTextStyle: TextStyle.lerp(tabSelectedTextStyle, other.tabSelectedTextStyle, t)!,
      dropdownTextColor: Color.lerp(dropdownTextColor, other.dropdownTextColor, t)!,
      dropdownBackgroundColor: Color.lerp(dropdownBackgroundColor, other.dropdownBackgroundColor, t)!,
      searchTextColor: Color.lerp(searchTextColor, other.searchTextColor, t)!,
      searchIconColor: Color.lerp(searchIconColor, other.searchIconColor, t)!,
      dialogBackgroundColor: Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t)!,
      dialogBorderColor: Color.lerp(dialogBorderColor, other.dialogBorderColor, t)!,
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t)!,
      subtitleTextColor: Color.lerp(subtitleTextColor, other.subtitleTextColor, t)!,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.mainBlue,
      scaffoldBackgroundColor: AppColors.lightBackground,

      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        labelLarge: TextStyle(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.appBarColor, // Couleur exacte du sélecteur
        iconTheme: const IconThemeData(color: Colors.white), // Icônes blanches
        titleTextStyle: const TextStyle(
          color: Colors.white, // Titre blanc
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins-SemiBold',
        ),
      ),

          tabBarTheme: TabBarThemeData(
        labelColor: AppColors.mainBlue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.mainBlue,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins-SemiBold',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins-Regular',
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.mainBlue,
        inactiveTrackColor: AppColors.mainBlue.withOpacity(0.3),
        thumbColor: AppColors.mainBlue,
        overlayColor: AppColors.mainBlue.withOpacity(0.2),
        valueIndicatorColor: AppColors.mainBlue,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),

          cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.cardBlue),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue),
        ),
        labelStyle: TextStyle(color: AppColors.mainBlue),
        hintStyle: TextStyle(color: AppColors.mainBlue.withOpacity(0.6)),
      ),

      extensions: [
        ResultContainerTheme(
          backgroundColor: const Color(0xFF0A1128).withOpacity(0.3),
          borderColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins-Regular',
          ),
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        LightPageTheme(
          tabBackgroundColor: Colors.transparent,
          tabSelectedColor: AppColors.mainBlue,
          tabUnselectedColor: Colors.grey,
          tabIndicatorColor: AppColors.mainBlue,
          tabTextStyle: const TextStyle(
            fontFamily: 'Poppins-Regular',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87, // Texte noir pour le thème clair
          ),
          tabSelectedTextStyle: const TextStyle(
            fontFamily: 'Poppins-SemiBold',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.mainBlue, // Texte bleu pour l'onglet sélectionné
          ),
          dropdownTextColor: Colors.black87, // Texte noir pour les menus déroulants
          dropdownBackgroundColor: Colors.white, // Fond blanc pour les menus déroulants
          searchTextColor: Colors.black87, // Texte noir pour la recherche
          searchIconColor: Colors.black87, // Icône noire pour la recherche
          dialogBackgroundColor: AppColors.darkBackground, // Fond bleu nuit pour les dialogues
          dialogBorderColor: AppColors.mainBlue, // Bordure bleue pour les dialogues
          titleTextColor: AppColors.mainBlue, // Titres en bleu nuit
          subtitleTextColor: Colors.black87, // Sous-titres en noir
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final Color skyBlue = Colors.lightBlue[300]!;  // Bleu ciel

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF1E3A8A),      // bleu nuit
        secondary: const Color(0xFF0EA5E9),    // accent cyan doux
        surface: const Color(0xFF0B152B),
        background: const Color(0xFF0B152B),
      ),
      primaryColor: const Color(0xFF1E3A8A),
      scaffoldBackgroundColor: const Color(0xFF0B152B),
      canvasColor: const Color(0xFF0B152B),
      cardColor: AppColors.cardBlue,

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        labelLarge: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.appBarColor, // Couleur exacte du sélecteur
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins-SemiBold',
        ),
      ),

          tabBarTheme: TabBarThemeData(
        labelColor: skyBlue,  // Onglet sélectionné en bleu ciel
        unselectedLabelColor: AppColors.lightText,  // Onglets non sélectionnés en blanc
        indicatorColor: skyBlue,  // Indicateur en bleu ciel
        labelStyle: const TextStyle(
          fontFamily: 'Poppins-SemiBold',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins-Regular',
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: skyBlue,
        inactiveTrackColor: skyBlue.withOpacity(0.3),
        thumbColor: skyBlue,
        overlayColor: skyBlue.withOpacity(0.2),
        valueIndicatorColor: skyBlue,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),

          cardTheme: CardThemeData(
        color: AppColors.cardBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.mainBlue, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainBlue,
          foregroundColor: AppColors.lightText,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainBlue),
        ),
        labelStyle: const TextStyle(color: AppColors.lightText),
        hintStyle: TextStyle(color: AppColors.lightText.withOpacity(0.6)),
      ),

      extensions: [
        ResultContainerTheme(
          backgroundColor: const Color(0xFF0A1128).withOpacity(0.3),
          borderColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins-Regular',
          ),
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        LightPageTheme(
          tabBackgroundColor: Colors.transparent,
          tabSelectedColor: skyBlue,
          tabUnselectedColor: Colors.white,
          tabIndicatorColor: skyBlue,
          tabTextStyle: const TextStyle(
            fontFamily: 'Poppins-Regular',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          tabSelectedTextStyle: TextStyle(
            fontFamily: 'Poppins-SemiBold',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: skyBlue,
          ),
          dropdownTextColor: Colors.white,
          dropdownBackgroundColor: AppColors.darkBackground, // Fond bleu nuit uni pour les menus déroulants
          searchTextColor: Colors.white,
          searchIconColor: Colors.white,
          dialogBackgroundColor: AppColors.darkBackground, // Fond bleu nuit pour les dialogues
          dialogBorderColor: skyBlue, // Bordure bleue pour les dialogues
          titleTextColor: Colors.white, // Titres en blanc
          subtitleTextColor: Colors.white70, // Sous-titres en blanc transparent
        ),
      ],
    );
  }
}
