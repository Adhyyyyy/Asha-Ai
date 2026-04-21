import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
import '../patient/patient_list_screen.dart';
import '../patient/add_patient_screen.dart';
import '../auth/login_screen.dart';

class AshaDashboard extends StatefulWidget {
  const AshaDashboard({super.key});

  @override
  State<AshaDashboard> createState() => _AshaDashboardState();
}

class _AshaDashboardState extends State<AshaDashboard> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;
  String _username = 'Worker';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'ASHA Worker';
    
    try {
      final data = await _api.get('/asha/stats');
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // --- PREMIUM HEADER ---
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(DesignSystem.spacingL, 60, DesignSystem.spacingL, DesignSystem.spacingXL),
                    decoration: const BoxDecoration(
                      gradient: DesignSystem.primaryGradient,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(DesignSystem.radiusL)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                                Text(_username, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _handleLogout(context),
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignSystem.spacingXL),
                        
                        // GLASS STATS CARD
                        _buildGlassStatsCard(),
                      ],
                    ),
                  ),
                ),

                // --- QUICK ACTIONS ---
                SliverPadding(
                  padding: const EdgeInsets.all(DesignSystem.spacingL),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Actions', style: DesignSystem.heading2),
                        const SizedBox(height: DesignSystem.spacingM),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: DesignSystem.spacingM,
                          crossAxisSpacing: DesignSystem.spacingM,
                          childAspectRatio: 1.1,
                          children: [
                            _buildActionCard(
                              context,
                              'New Screening',
                              Icons.add_a_photo_rounded,
                              DesignSystem.primary,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientListScreen(filterForScreening: true))),
                            ),
                            _buildActionCard(
                              context,
                              'Patients',
                              Icons.people_alt_rounded,
                              Colors.blueAccent,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientListScreen())),
                            ),
                            _buildActionCard(
                              context,
                              'Add Patient',
                              Icons.person_add_rounded,
                              Colors.orangeAccent,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPatientScreen())),
                            ),
                            _buildActionCard(
                              context,
                              'Sync Data',
                              Icons.sync_rounded,
                              Colors.purpleAccent,
                              _loadData,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- TASKS / HISTORY ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Activity', style: DesignSystem.heading2),
                        const SizedBox(height: DesignSystem.spacingM),
                        
                        if ((_stats?['recent_activities'] as List?)?.isEmpty ?? true)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: DesignSystem.surface,
                              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            ),
                            child: const Center(
                              child: Text('No screenings registered yet', style: TextStyle(color: DesignSystem.textSecondary)),
                            ),
                          )
                        else
                          ...(_stats!['recent_activities'] as List).map((activity) {
                            return _buildActivityItem(
                              activity['condition'] ?? activity['modality']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'SCREENING', 
                              activity['severity'] ?? 'Outcome pending', 
                              _getSeverityColor(activity['severity'])
                            );
                          }).toList(),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGlassStatsCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Points', '${_stats?['points'] ?? 0}', Icons.stars_rounded),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStat('Rank', '#${_stats?['leaderboard_rank'] ?? '-'}', Icons.leaderboard_rounded),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStat('Today', '${_stats?['screenings_today'] ?? 0}', Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amberAccent, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          boxShadow: DesignSystem.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: DesignSystem.spacingS),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String name, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingM),
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: DesignSystem.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(Icons.person, color: statusColor)),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: DesignSystem.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: DesignSystem.textSecondary),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    if (severity == null) return Colors.grey;
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return DesignSystem.riskHigh;
      case 'moderate':
        return DesignSystem.riskModerate;
      default:
        return DesignSystem.riskLow;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
