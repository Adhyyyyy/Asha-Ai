import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../screening/ai_screening_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
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
      final data = await _api.get('/patients/${widget.patient['id']}/screenings');
      setState(() {
        _screenings = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching screenings: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getRiskColor(String risk) {
    if (risk == 'High') return Colors.red;
    if (risk == 'Medium') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patient['name'])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Push to new screening screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AiScreeningScreen(
                patientId: widget.patient['id'].toString(),
                patientName: widget.patient['name'],
              ),
            ),
          ).then((_) => _fetchScreenings()); // Refresh on return
        },
        child: const Icon(Icons.biotech),
      ),
      body: Column(
        children: [
          // Patient Header Details
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getRiskColor(widget.patient['risk']),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${widget.patient['age']}', style: const TextStyle(fontSize: 16)),
                      Text('Trimester: ${widget.patient['trimester']}', style: const TextStyle(fontSize: 16)),
                      Text('Status: ${widget.patient['risk']}', style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: _getRiskColor(widget.patient['risk'])
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Screening History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          // History List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _screenings.isEmpty
                ? const Center(child: Text('No screenings registered yet.'))
                : ListView.builder(
                    itemCount: _screenings.length,
                    itemBuilder: (context, index) {
                      final item = _screenings[index];
                      // format date if available
                      String dateStr = 'Unknown Date';
                      if (item['timestamp'] != null && item['timestamp']['_seconds'] != null) {
                         final date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']['_seconds'] * 1000);
                         dateStr = "${date.day}/${date.month}/${date.year}";
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          leading: Icon(
                            item['modality'] == 'audio' ? Icons.mic : Icons.camera_alt, 
                            color: _getRiskColor(item['risk_level'] ?? 'Low')
                          ),
                          title: Text('${item['modality']?.toUpperCase()} Test - $dateStr'),
                          subtitle: Text('Risk: ${item['risk_level']}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item['file_url'] != null) 
                                     Text('View Media: ${item['file_url']} (Link available in Firebase)', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                  const SizedBox(height: 8),
                                  const Text('Identified Indicators:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...(item['indicators'] as List<dynamic>? ?? []).map((ind) => Text('• $ind')),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
          )
        ],
      ),
    );
  }
}
