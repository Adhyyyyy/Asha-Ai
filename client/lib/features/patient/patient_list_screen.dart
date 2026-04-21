import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  final bool showOnlyHighRisk;
  final bool filterForScreening;
  final String? ashaId;
  const PatientListScreen({
    super.key, 
    this.showOnlyHighRisk = false, 
    this.filterForScreening = false,
    this.ashaId
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _patients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    try {
      final endpoint = widget.ashaId != null ? '/patients?ashaId=${widget.ashaId}' : '/patients';
      final data = await _api.get(endpoint);
      if (mounted) {
        setState(() {
          _patients = data as List;
          if (widget.showOnlyHighRisk) {
            _patients = _patients.where((p) => p['risk'] == 'High').toList();
          }
          _filteredPatients = _patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) {
        final name = p['name'].toString().toLowerCase();
        final id = p['id']?.toString().toLowerCase() ?? '';
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text(widget.filterForScreening ? 'Select Patient' : 'Directory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL, vertical: DesignSystem.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: DesignSystem.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.ashaId != null || widget.filterForScreening
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToAdd(context),
              backgroundColor: DesignSystem.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Patient', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
            ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    final risk = patient['risk']?.toString() ?? 'Low';
    final riskColor = _getRiskColor(risk);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: DesignSystem.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM, vertical: DesignSystem.spacingS),
        leading: CircleAvatar(
          backgroundColor: riskColor.withOpacity(0.1),
          child: Icon(Icons.person_rounded, color: riskColor),
        ),
        title: Text(patient['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Age: ${patient['age']} • ${patient['area'] ?? "Unknown"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
              child: Text(
                risk.toUpperCase(),
                style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            if (!widget.filterForScreening)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: DesignSystem.riskHigh, size: 20),
                onPressed: () => _confirmDelete(patient['id'], patient['name']),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.surface,
        title: const Text('Delete Patient?'),
        content: Text('Are you sure you want to remove $name and all associated records? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePatient(id);
            },
            child: const Text('Delete', style: TextStyle(color: DesignSystem.riskHigh)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient(String id) async {
    try {
      await _api.delete('/patients/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted successfully')),
        );
        _fetchPatients(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.riskHigh),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: DesignSystem.textSecondary.withOpacity(0.3)),
          const SizedBox(height: DesignSystem.spacingM),
          Text('No patients found', style: DesignSystem.bodySmall),
        ],
      ),
    );
  }

  void _navigateToAdd(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    );
    if (result == true) _fetchPatients();
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high': return DesignSystem.riskHigh;
      case 'moderate': return DesignSystem.riskModerate;
      default: return DesignSystem.riskLow;
    }
  }
}
