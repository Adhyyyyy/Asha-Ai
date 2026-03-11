import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../patient/patient_list_screen.dart';
import '../auth/login_screen.dart';
import 'asha_list_screen.dart';
import 'screening_list_screen.dart';

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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Clear the saved token
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              
              // 2. Go back to Login Screen
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Clears the whole navigation stack
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // 2 Cards per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    title: 'Total Patients', 
                    count: _stats?['total_patients'], 
                    icon: Icons.people, 
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientListScreen()))
                  ),
                  _buildCard(
                    title: 'Total ASHAs', 
                    count: _stats?['total_ashas'], 
                    icon: Icons.medical_services, 
                    color: Colors.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AshaListScreen()))
                  ),
                  _buildCard(
                    title: 'Screenings', 
                    count: _stats?['total_screenings'], 
                    icon: Icons.analytics, 
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreeningListScreen()))
                  ),
                  _buildCard(
                    title: 'High Risk', 
                    count: _stats?['risk_distribution']['high'], 
                    icon: Icons.warning, 
                    color: Colors.red,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientListScreen(showOnlyHighRisk: true)))
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widget
   Widget _buildCard({required String title, required dynamic count, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}