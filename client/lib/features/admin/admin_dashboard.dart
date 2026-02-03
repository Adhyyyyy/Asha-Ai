import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final data = await _api.get('/admin/stats');
      debugPrint('✅ API DATA RECEIVED: $data'); // Print data to console
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ STATS ERROR: $e'); // Print error to console
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // 2 Cards per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard('Total Patients', _stats?['total_patients'], Icons.people, Colors.blue),
                  _buildCard('Total ASHAs', _stats?['total_ashas'], Icons.medical_services, Colors.green),
                  _buildCard('Screenings', _stats?['total_screenings'], Icons.analytics, Colors.orange),
                  _buildCard('High Risk', _stats?['risk_distribution']['high'], Icons.warning, Colors.red),
                ],
              ),
            ),
    );
  }

  // Helper Widget
  Widget _buildCard(String title, dynamic count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            count?.toString() ?? '0',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}