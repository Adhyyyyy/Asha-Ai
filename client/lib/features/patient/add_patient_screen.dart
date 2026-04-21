import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _trimesterController = TextEditingController();

  Future<void> _submitPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _api.post('/patients', {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'trimester': int.parse(_trimesterController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Patient Registered Successfully!'),
            backgroundColor: DesignSystem.riskLow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), 
            backgroundColor: DesignSystem.riskHigh,
            behavior: SnackBarBehavior.floating,
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
      appBar: AppBar(
        title: const Text('New Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient Details', style: DesignSystem.heading2),
              const SizedBox(height: DesignSystem.spacingS),
              Text('Enter the patient information carefully.', style: DesignSystem.bodySmall),
              
              const SizedBox(height: DesignSystem.spacingXL),

              // FORM CARD
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: DesignSystem.surface,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  boxShadow: DesignSystem.softShadow,
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age (Years)',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Age required' : null,
                    ),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildTextField(
                      controller: _trimesterController,
                      label: 'Current Trimester (1-3)',
                      icon: Icons.pregnant_woman_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final t = int.tryParse(v);
                        if (t == null || t < 1 || t > 3) return 'Invalid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignSystem.spacingXL),

              const Text(
                'Note: Risk level will be established after your first AI screening.',
                style: TextStyle(color: DesignSystem.textSecondary, fontStyle: FontStyle.italic, fontSize: 13),
              ),
              
              const SizedBox(height: 60),

              // SUBMIT BUTTON
              GestureDetector(
                onTap: _isLoading ? null : _submitPatient,
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register Patient',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: DesignSystem.bodySmall,
        prefixIcon: Icon(icon, color: DesignSystem.primary.withOpacity(0.5)),
        filled: true,
        fillColor: DesignSystem.background.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
