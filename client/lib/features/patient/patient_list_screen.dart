import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'add_patient_screen.dart';
import '../screening/ai_screening_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  final bool showOnlyHighRisk;
  final String? ashaId; // Optional filter for Admin
  const PatientListScreen({super.key, this.showOnlyHighRisk = false, this.ashaId});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchPatients();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming backend token decode or just basic logic... we'll rely on server for now
    // If not saved, we can just check if widget.ashaId is passed to confirm admin context
  }

  Future<void> _fetchPatients() async {
    try {
      final endpoint = widget.ashaId != null ? '/patients?ashaId=${widget.ashaId}' : '/patients';
      final data = await _api.get(endpoint);
      setState(() {
        if (widget.showOnlyHighRisk) {
            _patients = (data as List).where((p) => p['risk'] == 'High').toList();
        } else {
            _patients = data;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching patients: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ashaId != null ? 'Worker\'s Patients' : 'Patient List')),
      floatingActionButton: widget.ashaId != null ? null : FloatingActionButton( // Hide Add button if filtering by another ASHA
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );
          if (result == true) {
            _fetchPatients();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
            ? const Center(child: Text('No Patients found.'))
            : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRiskColor(patient['risk']),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(patient['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Age: ${patient['age']} • Trimester: ${patient['trimester']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                       // Navigate to Patient Details
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => PatientDetailScreen(patient: patient),
                         ),
                       );
                    },
                  ),
                );
              },
            ),
    );
  }

  // Helper: Color based on Risk
  Color _getRiskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }
}
