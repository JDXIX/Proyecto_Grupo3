import 'package:flutter/material.dart';

/// Paleta de colores VOXIA basada en el logo
class VoxiaColors {
  // Colores principales del logo
  static const Color primaryDark = Color(0xFF1E3A8A);    // Azul oscuro
  static const Color primary = Color(0xFF3B82F6);        // Azul medio
  static const Color primaryLight = Color(0xFF60A5FA);   // Azul claro
  static const Color accent = Color(0xFF67E8F9);         // Celeste/Cyan
  static const Color accentLight = Color(0xFFCFFAFE);    // Celeste muy claro
  
  // Colores de fondo
  static const Color backgroundLight = Color(0xFFF0F9FF);  // Fondo azul muy suave
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFE0F2FE);     // Superficie azul claro
  
  // Colores de texto
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Colores de estado
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundWhite],
  );
}

/// Tema principal de la aplicación VOXIA
class VoxiaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de colores
      colorScheme: const ColorScheme.light(
        primary: VoxiaColors.primary,
        primaryContainer: VoxiaColors.primaryLight,
        secondary: VoxiaColors.accent,
        secondaryContainer: VoxiaColors.accentLight,
        surface: VoxiaColors.backgroundWhite,
        error: VoxiaColors.error,
        onPrimary: Colors.white,
        onSecondary: VoxiaColors.primaryDark,
        onSurface: VoxiaColors.textDark,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: VoxiaColors.backgroundLight,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: VoxiaColors.primaryDark,
        titleTextStyle: TextStyle(
          color: VoxiaColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: VoxiaColors.primary),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: VoxiaColors.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: VoxiaColors.backgroundWhite,
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: VoxiaColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VoxiaColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VoxiaColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VoxiaColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoxiaColors.primaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: VoxiaColors.primaryLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoxiaColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoxiaColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: VoxiaColors.textMedium),
        hintStyle: const TextStyle(color: VoxiaColors.textLight),
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: VoxiaColors.backgroundWhite,
        titleTextStyle: const TextStyle(
          color: VoxiaColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VoxiaColors.primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: VoxiaColors.primary,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: VoxiaColors.primaryDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: VoxiaColors.primaryDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: VoxiaColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: VoxiaColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: VoxiaColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: VoxiaColors.textDark,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: VoxiaColors.textMedium,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: VoxiaColors.textLight,
          fontSize: 12,
        ),
      ),
    );
  }
}
