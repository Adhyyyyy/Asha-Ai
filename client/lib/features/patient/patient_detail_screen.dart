import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
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
      if (mounted) {
        setState(() {
          _screenings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = widget.patient['risk']?.toString() ?? 'Low';
    final riskColor = _getRiskColor(risk);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // PATIENT HEADER
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(DesignSystem.spacingL),
              padding: const EdgeInsets.all(DesignSystem.spacingL),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                boxShadow: DesignSystem.softShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: riskColor.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, color: riskColor, size: 40),
                  ),
                  const SizedBox(width: DesignSystem.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.patient['name'], style: DesignSystem.heading2),
                        const SizedBox(height: 4),
                        Text('Age: ${widget.patient['age']} • Trimester: ${widget.patient['trimester']}', style: DesignSystem.bodySmall),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                          ),
                          child: Text(
                            risk.toUpperCase(),
                            style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // HISTORY TITLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
              child: Text('Screening History', style: DesignSystem.heading2.copyWith(fontSize: 18)),
            ),
          ),

          // HISTORY LIST
          SliverPadding(
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            sliver: _isLoading
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : _screenings.isEmpty
                    ? _buildEmptyHistory()
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _screenings[index];
                            return _buildHistoryCard(item);
                          },
                          childCount: _screenings.length,
                        ),
                      ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToScreening(context),
        backgroundColor: DesignSystem.primary,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: const Text('Start AI Checkup', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final modality = item['modality']?.toString() ?? 'unknown';
    final severity = item['severity'] ?? 'Low';
    final severityColor = _getRiskColor(severity);
    
    String dateStr = 'Recent';
    if (item['timestamp'] != null && item['timestamp']['_seconds'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']['_seconds'] * 1000);
      dateStr = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: DesignSystem.softShadow,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: severityColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(_getModalityIcon(modality), color: severityColor, size: 24),
        ),
        title: Text(modality.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(dateStr, style: DesignSystem.bodySmall),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assessed Condition:', style: DesignSystem.label),
                Text(item['condition'] ?? 'General Screening', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignSystem.spacingM),
                Text('AI Advice:', style: DesignSystem.label),
                Text(item['advice'] ?? 'No specific advice.', style: DesignSystem.bodySmall),
                if (item['file_url'] != null) ...[
                  const SizedBox(height: DesignSystem.spacingM),
                  const Text('Image successfully saved to cloud.', style: TextStyle(fontSize: 12, color: DesignSystem.primary, fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.history_toggle_off_rounded, size: 48, color: DesignSystem.textSecondary.withOpacity(0.3)),
            const SizedBox(height: DesignSystem.spacingS),
            Text('No screenings yet', style: DesignSystem.bodySmall),
          ],
        ),
      ),
    );
  }

  void _navigateToScreening(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiScreeningScreen(
          patientId: widget.patient['id'].toString(),
          patientName: widget.patient['name'],
        ),
      ),
    ).then((_) => _fetchScreenings());
  }

  IconData _getModalityIcon(String modality) {
    if (modality.contains('eye')) return Icons.visibility_rounded;
    if (modality.contains('nail')) return Icons.fingerprint_rounded;
    if (modality.contains('audio')) return Icons.mic_rounded;
    return Icons.health_and_safety_rounded;
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
      case 'critical': return DesignSystem.riskHigh;
      case 'moderate': return DesignSystem.riskModerate;
      default: return DesignSystem.riskLow;
    }
  }
}
