import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
import '../admin/admin_dashboard.dart';
import '../asha/asha_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.post('/auth/login', {
        'username': _emailController.text,
        'password': _passwordController.text,
      });

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
        
        if (result['username'] != null) {
          await prefs.setString('username', result['username']);
        }
        if (result['area'] != null) {
          await prefs.setString('area', result['area']);
        }

        if (result['role'] == 'ADMIN') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AshaDashboard()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), 
            backgroundColor: DesignSystem.riskHigh,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              
              // BRAND ICON
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded, 
                  size: 48, 
                  color: DesignSystem.primary
                ),
              ),
              
              const SizedBox(height: DesignSystem.spacingXL),
              
              // WELCOME TEXT
              Text('Welcome to\nASHA-AI', style: DesignSystem.heading1),
              const SizedBox(height: DesignSystem.spacingS),
              Text(
                'Sign in to start healthcare screenings',
                style: DesignSystem.bodySmall,
              ),
              
              const SizedBox(height: 60),

              // LOGIN INPUTS
              Column(
                children: [
                  // USERNAME
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Username or ID',
                      labelStyle: DesignSystem.bodySmall,
                      filled: true,
                      fillColor: DesignSystem.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: DesignSystem.textSecondary),
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacingM),

                  // PASSWORD
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: DesignSystem.bodySmall,
                      filled: true,
                      fillColor: DesignSystem.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: DesignSystem.textSecondary),
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.spacingXL),

                  // GRADIENT LOGIN BUTTON
                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: DesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        boxShadow: DesignSystem.intenseShadow,
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white, 
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Your Health Companion',
                  style: DesignSystem.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}