import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

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
          const SnackBar(content: Text('ASHA Worker Created Successfully!')),
        );
        Navigator.pop(context, true); // Return true to refresh list
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
      appBar: AppBar(title: const Text('Add ASHA Worker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username (Login ID)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Initial Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Assigned Area (Village/Ward)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please assign an area' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAsha,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('CREATE WORKER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
