import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/design_system.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const AshaAiApp());
}

class AshaAiApp extends StatelessWidget {
  const AshaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASHA-AI',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignSystem.primary,
          surface: DesignSystem.surface,
          background: DesignSystem.background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: DesignSystem.background,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      
      // START SCREEN: Show Login first
      home: const LoginScreen(),
    );
  }
}
