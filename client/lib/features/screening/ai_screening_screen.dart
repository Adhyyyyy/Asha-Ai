import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AiScreeningScreen extends StatefulWidget {
  final String patientId; // We need to know WHO we are scanning
  final String patientName;

  const AiScreeningScreen({
    super.key, 
    required this.patientId, 
    required this.patientName
  });

  @override
  State<AiScreeningScreen> createState() => _AiScreeningScreenState();
}

class _AiScreeningScreenState extends State<AiScreeningScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String? _result;

  // 1. The Logic (Simulated AI Call)
  Future<void> _runAnalysis(String testType) async {
    setState(() { _isLoading = true; _result = null; });

    try {
      final result = await _api.post('/ai/predict', {
        'patientId': widget.patientId,
        'modality': testType, 
        'file_path': 'dummy/path/file.jpg' 
      });

      setState(() {
        _result = "Risk: ${result['risk_score']}%\n"
                  "Condition: ${result['condition']}\n"
                  "Advice: ${result['advice']}";
      });
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. The UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Checkup: ${widget.patientName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Select a Test:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildScanButton('📷 Scan Eye (Anemia)', Icons.visibility, Colors.blue, 'image_eye'),
            const SizedBox(height: 16),
            _buildScanButton('🎙️ Analyze Cough (Lungs)', Icons.mic, Colors.orange, 'audio_cough'),
            const SizedBox(height: 16),
            _buildScanButton('✋ Check Vitals (BP/Swell)', Icons.favorite, Colors.red, 'manual_maternal'),
            
            const Divider(height: 40),
            
            // Result Area
            if (_isLoading) 
              const Center(child: CircularProgressIndicator())
            else if (_result != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Text(_result!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  // 3. Helper Widget (Button)
  Widget _buildScanButton(String title, IconData icon, Color color, String type) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: () => _runAnalysis(type),
    );
  }
}