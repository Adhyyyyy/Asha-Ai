import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';

class AiScreeningScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AiScreeningScreen({
    super.key, 
    required this.patientId, 
    required this.patientName
  });

  @override
  State<AiScreeningScreen> createState() => _AiScreeningScreenState();
}

class _AiScreeningScreenState extends State<AiScreeningScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  
  // WIZARD STATE
  int _currentStep = 0; // 0: Select, 1: Capture, 2: Intake, 3: Processing, 4: Result
  String? _selectedModality;
  Uint8List? _mediaBytes; // Can be Image or Audio
  String? _mediaName;
  bool _isRecording = false;

  Map<String, bool> _intakeAnswers = {
    'fever': false,
    'dizziness': false,
    'weakness': false,
    'chest_pain': false,
  };
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  late AnimationController _scanningController;

  @override
  void initState() {
    super.initState();
    _scanningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanningController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- STEP 1: Select Modality ---
  void _selectModality(String modality) {
    setState(() {
      _selectedModality = modality;
      _currentStep = 1;
    });
  }

  // --- STEP 2: Capture Media ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _mediaBytes = bytes;
        _mediaName = photo.name;
        _currentStep = 2; // Move to Intake
      });
    }
  }

  Future<void> _handleAudioRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        Uint8List? bytes;
        if (kIsWeb) {
          // stop() returns a blob URL on web (blob:http://...)
          final blobResult = await http.get(Uri.parse(path));
          bytes = blobResult.bodyBytes;
        } else {
          bytes = await File(path).readAsBytes();
        }

        if (bytes != null) {
          setState(() {
            _mediaBytes = bytes;
            _mediaName = "cough_recording.m4a";
            _isRecording = false;
            _currentStep = 2; // Move to Intake
          });
        }
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        String? path;
        if (!kIsWeb) {
          final directory = await getTemporaryDirectory();
          path = '${directory.path}/recording.m4a';
        }
        
        const config = RecordConfig();
        await _audioRecorder.start(config, path: path ?? '');
        setState(() => _isRecording = true);
      }
    }
  }

  // --- STEP 3: Analysis ---
  Future<void> _runAnalysis() async {
    try {
      dynamic result;
      if (_mediaBytes != null) {
        result = await _api.uploadFile(
          '/ai/predict', 
          _mediaBytes!, 
          _mediaName ?? 'screening.jpg',
          {
            'patientId': widget.patientId,
            'modality': _selectedModality!,
            'manualData': jsonEncode(_intakeAnswers),
          }
        );
      } else {
        result = await _api.post('/ai/predict', {
          'patientId': widget.patientId,
          'modality': _selectedModality!,
          'manualData': _intakeAnswers,
        });
      }

      setState(() {
        _analysisResult = result;
        _currentStep = 4; 
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _currentStep = 4; 
      });
    }
  }

  // UI: STEP 2 (Patient Intake)
  Widget _buildIntakeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Intake', style: DesignSystem.heading1),
          const SizedBox(height: DesignSystem.spacingS),
          Text('Collect additional context for the ${_selectedModality?.replaceAll('_', ' ')}', style: DesignSystem.bodySmall),
          const SizedBox(height: DesignSystem.spacingXL),
          
          _buildIntakeToggle('Fever / Chills', 'fever', Icons.thermostat_rounded),
          _buildIntakeToggle('Dizziness / Fatigue', 'dizziness', Icons.sensors_rounded),
          _buildIntakeToggle('Extreme Weakness', 'weakness', Icons.bolt_rounded),
          _buildIntakeToggle('Chest Pain', 'chest_pain', Icons.monitor_heart_rounded),
          
          const SizedBox(height: 60),
          _buildPrimaryButton('Run Advanced Analysis', Icons.psychology_rounded, () {
            setState(() => _currentStep = 3);
            _runAnalysis();
          }),
        ],
      ),
    );
  }

  Widget _buildIntakeToggle(String label, String key, IconData icon) {
    bool isSelected = _intakeAnswers[key] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _intakeAnswers[key] = !isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? DesignSystem.primary.withOpacity(0.05) : DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(color: isSelected ? DesignSystem.primary : Colors.transparent),
          boxShadow: DesignSystem.softShadow,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? DesignSystem.primary : DesignSystem.textSecondary),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            Switch.adaptive(
              value: isSelected,
              onChanged: (val) => setState(() => _intakeAnswers[key] = val),
              activeColor: DesignSystem.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text(_getStepTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildCurrentStepView(),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'AI Screening';
      case 1: return 'Capture Phase';
      case 2: return 'Patient Intake';
      case 3: return 'Analyzing...';
      case 4: return 'Assessment Result';
      default: return 'Screening';
    }
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0: return _buildModalitySelection();
      case 1: return _buildCaptureStep();
      case 2: return _buildIntakeStep();
      case 3: return _buildProcessingStep();
      case 4: return _buildResultStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildModalitySelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient: ${widget.patientName}', style: DesignSystem.bodySmall),
          const SizedBox(height: DesignSystem.spacingS),
          Text('Select Diagnostic Suite', style: DesignSystem.heading1),
          const SizedBox(height: DesignSystem.spacingXL),
          
          _buildModalityCard('Ocular Suite', 'Comprehensive Eye & Anemia check', Icons.visibility_rounded, Colors.teal, 'ocular_suite'),
          _buildModalityCard('Dermal Scan', 'Skin rashes & nutritional markers', Icons.fingerprint_rounded, Colors.blue, 'dermal_suite'),
          _buildModalityCard('Respiratory IQ', 'Advanced lung & audio assessment', Icons.mic_external_on_rounded, Colors.orange, 'respiratory_suite'),
        ],
      ),
    );
  }

  Widget _buildModalityCard(String title, String sub, IconData icon, Color color, String id) {
    return GestureDetector(
      onTap: () => _selectModality(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSystem.spacingM),
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          boxShadow: DesignSystem.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingM),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: DesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(sub, style: DesignSystem.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: DesignSystem.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureStep() {
    bool isAudio = _selectedModality == 'respiratory_suite';

    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAudio ? Icons.mic_rounded : Icons.camera_rounded, 
            size: 80, 
            color: DesignSystem.primary
          ),
          const SizedBox(height: DesignSystem.spacingXL),
          Text(isAudio ? 'Cough IQ Recording' : 'Capture Instructions', style: DesignSystem.heading2),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            isAudio 
              ? 'Ask the patient to cough clearly twice near the microphone. AI will analyze the sound markers.'
              : '1. Ensure good natural lighting.\n2. Keep the lens clean.\n3. Steady the camera for 2 seconds.',
            style: const TextStyle(height: 1.8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          if (isAudio)
            _buildAudioRecorderUI()
          else ...[
            _buildPrimaryButton('Open Camera', Icons.camera_alt_rounded, () => _pickImage(ImageSource.camera)),
            const SizedBox(height: DesignSystem.spacingM),
            _buildSecondaryButton('Choose from Gallery', Icons.photo_library_rounded, () => _pickImage(ImageSource.gallery)),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioRecorderUI() {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleAudioRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _isRecording ? DesignSystem.riskHigh.withOpacity(0.1) : DesignSystem.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRecording ? DesignSystem.riskHigh : DesignSystem.primary,
                width: 3,
              ),
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              size: 40,
              color: _isRecording ? DesignSystem.riskHigh : DesignSystem.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isRecording ? 'RECORDING... (Tap to stop)' : 'TAP TO START RECORDING',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isRecording ? DesignSystem.riskHigh : DesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scanningController,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(20 + (_scanningController.value * 20)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DesignSystem.primary.withOpacity(1 - _scanningController.value), width: 2),
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 64, color: DesignSystem.primary),
              );
            },
          ),
          const SizedBox(height: DesignSystem.spacingXL),
          Text('Analyzing Health Data', style: DesignSystem.heading2),
          const SizedBox(height: DesignSystem.spacingS),
          Text('Gemini AI is processing the screening...', style: DesignSystem.bodySmall),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    final risk = _analysisResult?['risk_score'] ?? 0;
    final severity = _analysisResult?['severity'] ?? 'Low';
    final severityColor = _getSeverityColor(severity);
    final condition = _analysisResult?['condition'] ?? 'General Screening';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(condition, severity, severityColor, risk),
              const SizedBox(height: DesignSystem.spacingXL),
              Text('PREVENTION JOURNEY', style: DesignSystem.label.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: DesignSystem.spacingM),
              _buildJourneyItem(
                'Current Finding',
                _analysisResult?['current_status'] ?? 'Observation identified by AI.',
                Icons.radar_rounded,
                DesignSystem.primary,
                true,
              ),
              _buildJourneyItem(
                'Future Projection',
                _analysisResult?['future_projection'] ?? 'Escalation risk if ignored.',
                Icons.history_toggle_off_rounded,
                DesignSystem.riskHigh,
                true,
              ),
              _buildJourneyItem(
                'Prevention Action',
                _analysisResult?['prevention_plan'] ?? 'Immediate care plan.',
                Icons.verified_user_rounded,
                DesignSystem.riskLow,
                false,
              ),
              const SizedBox(height: DesignSystem.spacingXL),
              Text('CLINICAL REASONING', style: DesignSystem.label.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: DesignSystem.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignSystem.spacingL),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  border: Border.all(color: DesignSystem.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: DesignSystem.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('AI Logical Deduction', style: DesignSystem.bodySmall.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _analysisResult?['clinical_reasoning'] ?? 'The AI is processing clinical evidence based on visual markers and context.',
                      style: DesignSystem.bodySmall.copyWith(height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignSystem.spacingXL),
              Text('PROFESSIONAL GUIDANCE', style: DesignSystem.label.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: DesignSystem.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignSystem.spacingL),
                decoration: BoxDecoration(
                  color: DesignSystem.surface,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  boxShadow: DesignSystem.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdviceModRow(Icons.lightbulb_outline_rounded, 'Key Advice', _analysisResult?['advice'] ?? ''),
                    const Divider(height: 32),
                    _buildAdviceModRow(Icons.health_and_safety_outlined, 'Next Steps', 'Refer to nearest PHC for confirmatory tests.'),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            child: _buildPrimaryButton('Done', Icons.check_circle_rounded, () => Navigator.pop(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(String title, String severity, Color color, int risk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        boxShadow: DesignSystem.intenseShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(DesignSystem.radiusS)),
                child: Text('AI ASSESSMENT', style: DesignSystem.label.copyWith(color: Colors.white, fontSize: 10)),
              ),
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(severity.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat('Risk', '$risk%'),
              const SizedBox(width: 40),
              _buildMiniStat('Type', _selectedModality?.toUpperCase() ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildJourneyItem(String label, String text, IconData icon, Color color, bool showConnector) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            if (showConnector)
              Container(width: 2, height: 40, color: DesignSystem.textSecondary.withOpacity(0.1)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DesignSystem.label.copyWith(color: color, fontSize: 11)),
              const SizedBox(height: 4),
              Text(text, style: DesignSystem.bodyMain.copyWith(fontSize: 14)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceModRow(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: DesignSystem.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(text, style: DesignSystem.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: DesignSystem.riskHigh, size: 60),
          const SizedBox(height: 16),
          Text('Assessment Error', style: DesignSystem.heading2),
          const SizedBox(height: 8),
          Text(_errorMessage!, style: DesignSystem.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildSecondaryButton('Try Again', Icons.refresh_rounded, () => setState(() => _currentStep = 0)),
        ],
      ),
    );
  }

  Widget _buildHorizontalGauge(int risk, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: DesignSystem.label.copyWith(fontSize: 10)),
            Text('$risk%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text('100%', style: DesignSystem.label.copyWith(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: DesignSystem.background,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMax),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 12,
              width: risk.toDouble() * 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.5), color]),
                borderRadius: BorderRadius.circular(DesignSystem.radiusMax),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: DesignSystem.primaryGradient,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          boxShadow: DesignSystem.intenseShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: DesignSystem.spacingS),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: DesignSystem.textSecondary),
      label: Text(label, style: const TextStyle(color: DesignSystem.textMain, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        side: const BorderSide(color: DesignSystem.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
      ),
    );
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
