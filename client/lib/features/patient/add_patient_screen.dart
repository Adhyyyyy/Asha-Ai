import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isLoading = false;

  // Controllers
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
          const SnackBar(content: Text('Patient Added Successfully!')),
        );
        Navigator.pop(context, true); // Return "true" to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter age' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trimesterController,
                decoration: const InputDecoration(labelText: 'Trimester (1-3)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                   if (value == null || value.isEmpty) return 'Enter trimester';
                   final t = int.tryParse(value);
                   if (t == null || t < 1 || t > 3) return 'Must be 1, 2, or 3';
                   return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPatient,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('REGISTER PATIENT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
