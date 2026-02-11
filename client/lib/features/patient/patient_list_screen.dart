import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'add_patient_screen.dart';
import '../screening/ai_screening_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final data = await _api.get('/patients'); // Calls /api/patients
      setState(() {
        _patients = data; // The list [ {name: 'Rina'...}, ... ]
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
      appBar: AppBar(title: const Text('Patient List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 1. Wait for them to come back
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );

          // 2. If they added someone (result == true), refresh the list!
          if (result == true) {
            _fetchPatients();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                       // Navigate to AI Screening
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => AiScreeningScreen(
                             patientId: patient['id'].toString(),
                             patientName: patient['name'],
                           ),
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
