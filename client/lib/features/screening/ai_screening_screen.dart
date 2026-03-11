import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  File? _imageFile; // Stores the captured photo
  final ImagePicker _picker = ImagePicker();

  // 1. Pick Image (Camera or Gallery)
  Future<void> _pickImage(String type, {bool fromGallery = false}) async {
    final XFile? photo = await _picker.pickImage(
      source: fromGallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
        _result = null; // Clear previous result
      });
      // Auto-analyze after taking photo
      _runAnalysis(type);
    }
  }

  // 2. The Logic (Upload & Analyze)
  Future<void> _runAnalysis(String testType) async {
    setState(() { _isLoading = true; });

    try {
      dynamic result;
      
      // If we have an image, UPLOAD it
      if (_imageFile != null && testType.startsWith('image')) {
        result = await _api.uploadFile('/ai/predict', _imageFile!.path, {
          'patientId': widget.patientId,
          'modality': testType,
        });
      } 
      // Else, use the Mock (or Manual) logic
      else {
         result = await _api.post('/ai/predict', {
          'patientId': widget.patientId,
          'modality': testType, 
        });
      }

      setState(() {
        final riskScore = result['risk_score'] ?? 'N/A';
        final condition = result['condition'] ?? 'Unknown';
        final advice = result['advice'] ?? 'No advice provided.';
        
        _result = "Risk: $riskScore%\n"
                  "Condition: $condition\n"
                  "Advice: $advice";
      });
    } catch (e) {
      if (mounted) setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. The UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Checkup: ${widget.patientName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Select a Test:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Show Image if taken
            if (_imageFile != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                ),
              ),

            _buildScanButton('📷 Scan Eye (Camera)', Icons.visibility, Colors.blue, 'image_eye', useCamera: true),
            const SizedBox(height: 16),
            _buildScanButton('📁 Upload Screen (Gallery)', Icons.photo_library, Colors.blueGrey, 'image_eye', fromGallery: true),
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
                color: _result!.contains('High') ? Colors.red.shade50 : Colors.green.shade50,
                child: Text(_result!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  // 4. Helper Widget (Button)
  Widget _buildScanButton(String title, IconData icon, Color color, String type, {bool useCamera = false, bool fromGallery = false}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: () {
        if (useCamera || fromGallery) {
          _pickImage(type, fromGallery: fromGallery);
        } else {
          _runAnalysis(type);
        }
      },
    );
  }
}