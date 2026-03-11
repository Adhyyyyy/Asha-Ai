import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  State<ScreeningListScreen> createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _screenings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScreenings();
  }

  Future<void> _fetchScreenings() async {
    try {
      final data = await _api.get('/admin/screenings');
      setState(() {
        _screenings = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching screenings: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Screenings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screenings.isEmpty
              ? const Center(child: Text('No recent screenings found.'))
              : ListView.builder(
                  itemCount: _screenings.length,
                  itemBuilder: (context, index) {
                    final scan = _screenings[index];
                    final isHighRisk = scan['result']?['risk_score'] != null && scan['result']['risk_score'] > 70;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isHighRisk ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(Icons.analytics, color: isHighRisk ? Colors.red : Colors.blue),
                        ),
                        title: Text('Patient ID: ${scan['patientId']}'),
                        subtitle: Text(
                          'Condition: ${scan['result']?['condition'] ?? 'Unknown'}\n'
                          'Modality: ${scan['modality']?.toUpperCase() ?? 'N/A'}'
                        ),
                        trailing: Text(
                          '${scan['result']?['risk_score'] ?? 0}% Risk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isHighRisk ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
