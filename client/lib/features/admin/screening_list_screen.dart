import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';

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
      backgroundColor: DesignSystem.adminBackground,
      appBar: AppBar(
        title: const Text('Clinical Activity Logs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: DesignSystem.adminAccent))
          : _screenings.isEmpty
              ? const Center(child: Text('No activity recorded.', style: TextStyle(color: DesignSystem.adminTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  itemCount: _screenings.length,
                  itemBuilder: (context, index) {
                    final scan = _screenings[index];
                    final risk = scan['risk_score'] ?? 0;
                    final severity = scan['severity'] ?? 'Low';
                    final color = _getSeverityColor(severity);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: DesignSystem.adminSurface,
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        border: Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(
                            _getModalityIcon(scan['modality']), 
                            color: color, 
                            size: 20
                          ),
                        ),
                        title: Text(
                          scan['condition'] ?? 'General Screening', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Patient ID: ${scan['patientId']}', 
                              style: const TextStyle(color: DesignSystem.adminTextSecondary, fontSize: 12)
                            ),
                            Text(
                              'Analyzed: ${scan['timestamp'] != null ? scan['timestamp'].toString().substring(0, 10) : "Recent"}',
                              style: const TextStyle(color: DesignSystem.adminTextSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$risk%', 
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)
                            ),
                            Text(
                              severity.toUpperCase(), 
                              style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getModalityIcon(String? modality) {
    switch (modality) {
      case 'ocular_suite': return Icons.remove_red_eye_rounded;
      case 'dermal_suite': return Icons.fingerprint_rounded;
      case 'respiratory_suite': return Icons.mic_external_on_rounded;
      default: return Icons.analytics_rounded;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high': return DesignSystem.riskHigh;
      case 'moderate': return DesignSystem.riskModerate;
      default: return DesignSystem.riskLow;
    }
  }
}
