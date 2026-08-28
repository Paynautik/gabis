import 'package:flutter/material.dart';

class AppColors {
  final Brightness brightness;
  const AppColors(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get bluePrimary => const Color(0xFF00B876); // Fintech Green
  Color get blueHighlight => isDark ? const Color(0xFF1E283F) : const Color(0xFFEDF4FF);
  Color get ink => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF101828); // White or dark text
  Color get inkSoft => isDark ? const Color(0xFF8A90A6) : const Color(0xFF667085);
  Color get bgSoft => isDark ? const Color(0xFF131520) : const Color(0xFFFFFFFF); // Card background
  Color get border => isDark ? const Color(0xFF222436) : const Color(0xFFEDF0F5);
  Color get success => const Color(0xFF16A34A);
  Color get danger => const Color(0xFFFF3B30);
  Color get scaffoldBg => isDark ? const Color(0xFF090A10) : const Color(0xFFF8FAFC); // Main background
}

extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors(Theme.of(this).brightness);
}

class AppTheme {
  static ThemeData getTheme(Brightness brightness) {
    final colors = AppColors(brightness);
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: colors.bluePrimary,
        surface: colors.bgSoft,
      ),
      scaffoldBackgroundColor: colors.scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.scaffoldBg,
        foregroundColor: colors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.bluePrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), // Pill
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), // Pill
          foregroundColor: colors.ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.bluePrimary, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.inkSoft),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.scaffoldBg,
        indicatorColor: colors.blueHighlight,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? (isDark ? Colors.white : colors.bluePrimary) : colors.inkSoft,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.bgSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border),
        ),
      ),
    );
  }

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF00B876)],
  );

  static const LinearGradient darkMetalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C2D35), Color(0xFF15161A)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9D976), Color(0xFFE9B646)],
  );

  static const LinearGradient platinumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
  );
}
