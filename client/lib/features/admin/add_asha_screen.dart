import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';

class AddAshaScreen extends StatefulWidget {
  const AddAshaScreen({super.key});

  @override
  State<AddAshaScreen> createState() => _AddAshaScreenState();
}

class _AddAshaScreenState extends State<AddAshaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _areaController = TextEditingController();

  Future<void> _submitAsha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _api.post('/admin/ashas', {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'area': _areaController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ASHA Worker Deployed Successfully!')),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.riskHigh),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.adminBackground,
      appBar: AppBar(
        title: const Text('Add ASHA Worker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Worker Deployment', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Register a new health worker for community surveillance.', style: TextStyle(color: DesignSystem.adminTextSecondary)),
              const SizedBox(height: DesignSystem.spacingXL),
              
              _buildModernField(_usernameController, 'Login Username', Icons.alternate_email_rounded),
              const SizedBox(height: 16),
              _buildModernField(_passwordController, 'Initial Password', Icons.lock_outline_rounded, isPassword: true),
              const SizedBox(height: 16),
              _buildModernField(_areaController, 'Assigned Service Area', Icons.location_on_outlined),
              
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAsha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.adminAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
                    elevation: 10,
                    shadowColor: DesignSystem.adminAccent.withOpacity(0.3),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: DesignSystem.adminBackground) 
                    : const Text(
                        'DEPLOY WORKER', 
                        style: TextStyle(color: DesignSystem.adminBackground, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: DesignSystem.adminAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: DesignSystem.adminTextSecondary, size: 20),
            filled: true,
            fillColor: DesignSystem.adminSurface,
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: DesignSystem.adminAccent, width: 2), borderRadius: BorderRadius.circular(12)),
            errorStyle: const TextStyle(color: DesignSystem.riskHigh),
          ),
          validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
        ),
      ],
    );
  }
}
