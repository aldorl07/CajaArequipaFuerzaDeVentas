import 'package:flutter/material.dart';

class AppColors {
  static const Color azulMarino = Color(0xFF002454);
  static const Color turquesaBrillante = Color(0xFF00C4D3);
  static const Color amarilloMostaza = Color(0xFFFF9E1B);
  static const Color verdeCesped = Color(0xFF1FA02F);
  static const Color turquesaOscuro = Color(0xFF008EA7);
  static const Color naranjaOcre = Color(0xFFC67A43);
  static const Color verdeOliva = Color(0xFF7B8C47);
  static const Color rojoCoral = Color(0xFFD93D41);
  static const Color grisClaro = Color(0xFFF0F4F8);
  static const Color blancoPuro = Color(0xFFFFFFFF);
  
  // Extra UI Colors
  static const Color textoOscuro = Color(0xFF1E293B);
  static const Color textoMutado = Color(0xFF64748B);
  static const Color borde = Color(0xFFE2E8F0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.azulMarino,
        secondary: AppColors.turquesaBrillante,
        tertiary: AppColors.amarilloMostaza,
        surface: AppColors.blancoPuro,
        error: AppColors.rojoCoral,
        onPrimary: AppColors.blancoPuro,
        onSecondary: AppColors.azulMarino,
        onSurface: AppColors.textoOscuro,
      ),
      scaffoldBackgroundColor: AppColors.grisClaro,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulMarino,
        foregroundColor: AppColors.blancoPuro,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.blancoPuro),
      ),
      cardTheme: CardThemeData(
        color: AppColors.blancoPuro,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borde, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquesaBrillante,
          foregroundColor: AppColors.azulMarino,
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.azulMarino,
          side: const BorderSide(color: AppColors.azulMarino, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blancoPuro,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borde, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borde, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.azulMarino, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.rojoCoral, width: 1),
        ),
        labelStyle: const TextStyle(color: AppColors.textoMutado, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textoMutado, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blancoPuro,
        indicatorColor: AppColors.turquesaBrillante.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.azulMarino,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.textoMutado,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.azulMarino);
          }
          return const IconThemeData(color: AppColors.textoMutado);
        }),
      ),
    );
  }
}
