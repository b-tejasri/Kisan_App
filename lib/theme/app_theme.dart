import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KisanColors {
  // Greens
  static const leafDeep = Color(0xFF1B4332);
  static const leaf = Color(0xFF2D6A4F);
  static const leafMid = Color(0xFF40916C);
  static const leafLight = Color(0xFF74C69D);
  static const leafPale = Color(0xFFD8F3DC);

  // Earthy
  static const soilDark = Color(0xFF3B1F0A);
  static const soil = Color(0xFF6B3F1A);
  static const soilLight = Color(0xFFC8956C);

  // Accents
  static const sun = Color(0xFFF4A226);
  static const sunPale = Color(0xFFFFF3CD);
  static const cream = Color(0xFFFDF6EC);
  static const skyBlue = Color(0xFF0096C7);
  static const skyPale = Color(0xFFDFF0FF);

  // Alerts
  static const alertRed = Color(0xFFE63946);
  static const alertRedDark = Color(0xFFC1121F);
  static const alertYellow = Color(0xFFF4A226);
  static const alertGreen = Color(0xFF40916C);
  static const alertBlue = Color(0xFF0096C7);

  // Text
  static const textDark = Color(0xFF1A2E1F);
  static const textMid = Color(0xFF5A7A65);
  static const textLight = Color(0xFF8AAB90);
  static const border = Color(0xFFE2ECE5);
}

class KisanTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KisanColors.leafMid,
          primary: KisanColors.leaf,
          secondary: KisanColors.sun,
          surface: KisanColors.cream,
        ),
        scaffoldBackgroundColor: KisanColors.cream,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.lora(
              fontWeight: FontWeight.w700, color: KisanColors.textDark),
          displayMedium: GoogleFonts.lora(
              fontWeight: FontWeight.w700, color: KisanColors.textDark),
          headlineLarge: GoogleFonts.nunito(
              fontWeight: FontWeight.w900, color: KisanColors.textDark),
          headlineMedium: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: KisanColors.textDark),
          bodyLarge: GoogleFonts.nunito(color: KisanColors.textDark),
          bodyMedium: GoogleFonts.nunito(color: KisanColors.textMid),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: KisanColors.leafDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.lora(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
