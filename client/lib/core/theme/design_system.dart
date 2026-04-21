import 'package:flutter/material.dart';

class DesignSystem {
  // --- COLORS (Calm & Nature Palette) ---
  static const Color primary = Color(0xFF00796B); // Deep Teal
  static const Color primaryLight = Color(0xFF48A999);
  static const Color accent = Color(0xFF00B0FF); // Sky Blue
  static const Color background = Color(0xFFF5F7FA); // Soft Gray-Blue
  static const Color surface = Colors.white;
  static const Color glassSurface = Color(0xCCFFFFFF); // 80% Opacity White
  
  static const Color textMain = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF78909C);
  
  static const Color riskHigh = Color(0xFFFF5252);
  static const Color riskModerate = Color(0xFFFFB74D);
  static const Color riskLow = Color(0xFF81C784);

  // --- ADMIN COMMAND CENTER (Mission Control Palette) ---
  static const Color adminBackground = Color(0xFF0A0E21);
  static const Color adminSurface = Color(0xFF1D2136);
  static const Color adminAccent = Color(0xFF00E5FF);
  static const Color adminText = Colors.white;
  static const Color adminTextSecondary = Color(0xFF8D8E98);

  // --- GRADIENTS ---
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- SPACING ---
  static const double spacingEmpty = 0.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // --- RADII (iOS Feel) ---
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 28.0;
  static const double radiusMax = 100.0;

  // --- SHADOWS ---
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> intenseShadow = [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 25,
      offset: const Offset(0, 12),
    ),
  ];

  // --- TEXT STYLES (Clean Hierarchy) ---
  static TextStyle heading1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textMain,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textMain,
    letterSpacing: -0.5,
  );

  static TextStyle bodyMain = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textMain,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static TextStyle label = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: textSecondary,
    letterSpacing: 1.0,
  );
}
