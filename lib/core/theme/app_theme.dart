import 'package:flutter/material.dart';

/// Theme iOS clean (Material 3) đồng bộ toàn app.
ThemeData buildIosCleanTheme({
  required bool isDarkMode,
  required double fontScale,
}) {
  const Color bg = Color(0xFFF5F6FA);
  const Color card = Color(0xFFFFFFFF);
  const Color textPrimary = Color(0xFF15171A);
  const Color textSecondary = Color(0xFF7B8191);
  const Color accent = Color(0xFF5B67FF);
  const Color darkBg = Color(0xFF101114);
  const Color darkCard = Color(0xFF1B1D24);
  const Color darkText = Color(0xFFF5F6FA);
  const Color darkSecondary = Color(0xFFA7ADBD);

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
  );
  final Color currentBg = isDarkMode ? darkBg : bg;
  final Color currentCard = isDarkMode ? darkCard : card;
  final Color currentText = isDarkMode ? darkText : textPrimary;
  final Color currentSubText = isDarkMode ? darkSecondary : textSecondary;
  final Color fieldBorder =
      isDarkMode ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF8D93A5);
  final Color panelBorder =
      isDarkMode ? Colors.white.withValues(alpha: 0.28) : Colors.black;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: currentBg,
    cardColor: currentCard,
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.w700,
        color: currentText,
      ),
      titleMedium: TextStyle(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w600,
        color: currentText,
      ),
      bodyMedium: TextStyle(
        fontSize: 15 * fontScale,
        fontWeight: FontWeight.w500,
        color: currentText,
      ),
      bodySmall: TextStyle(
        fontSize: 13 * fontScale,
        fontWeight: FontWeight.w500,
        color: currentSubText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: currentCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: currentSubText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: fieldBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: fieldBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),
    ),
    cardTheme: CardThemeData(
      color: currentCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: panelBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
