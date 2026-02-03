import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../admin/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers = like refs in React (to get text from inputs)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true); // Start Loading

    try {
      // Call our API Service (The one we just built!)
      final result = await _apiService.post('/auth/login', {
        'username': _emailController.text,
        'password': _passwordController.text,
      });

      // If success
      if (mounted) {
        // 1. SAVE THE KEY (Token) 🔑
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);

        if (result['role'] == 'ADMIN') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Success! Role: ${result['role']}')),
          );
        }
      }
    } catch (e) {
      // If error, show red alert
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop Loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASHA-AI Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            
            // EMAIL INPUT
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Username / ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // PASSWORD INPUT
            TextField(
              controller: _passwordController,
              obscureText: true, // Hide password
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity, // Full width button
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LOGIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}