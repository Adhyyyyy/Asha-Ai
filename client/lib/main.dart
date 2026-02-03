import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
      
      // THEME: This is where we set the colors for the whole app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Use Google Fonts globally
        textTheme: GoogleFonts.interTextTheme(),
      ),
      
      // START SCREEN: Show Login first
      home: const LoginScreen(),
    );
  }
}
