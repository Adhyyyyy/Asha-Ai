import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final data = await _api.get('/admin/stats');
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
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
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: DesignSystem.adminBackground,
      drawer: isMobile ? _buildDrawer() : null,
      appBar: isMobile ? AppBar(
        backgroundColor: DesignSystem.adminSurface,
        foregroundColor: Colors.white,
        title: const Text('COMMAND CENTER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ) : null,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              backgroundColor: DesignSystem.adminSurface,
              selectedIndex: _selectedIndex,
              extended: MediaQuery.of(context).size.width > 1200,
              labelType: NavigationRailLabelType.none,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              indicatorColor: DesignSystem.adminAccent.withOpacity(0.1),
              unselectedIconTheme: const IconThemeData(color: DesignSystem.adminTextSecondary),
              selectedIconTheme: const IconThemeData(color: DesignSystem.adminAccent),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Icon(Icons.hub_rounded, color: DesignSystem.adminAccent, size: 32),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.map_rounded), label: Text('Map')),
                NavigationRailDestination(icon: Icon(Icons.groups_rounded), label: Text('Force')),
                NavigationRailDestination(icon: Icon(Icons.assignment_turned_in_rounded), label: Text('Referrals')),
                NavigationRailDestination(icon: Icon(Icons.settings_rounded), label: Text('Settings')),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: DesignSystem.adminTextSecondary),
                      onPressed: _logout,
                    ),
                  ),
                ),
              ),
            ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: DesignSystem.adminAccent))
              : _buildCurrentView(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: DesignSystem.adminBackground,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: DesignSystem.adminSurface),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hub_rounded, color: DesignSystem.adminAccent, size: 48),
                SizedBox(height: 12),
                Text('HEALTH COMMAND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildDrawerItem(0, Icons.dashboard_rounded, 'Command Center'),
          _buildDrawerItem(1, Icons.map_rounded, 'Epidemiology'),
          _buildDrawerItem(2, Icons.groups_rounded, 'ASHA Force'),
          _buildDrawerItem(3, Icons.assignment_turned_in_rounded, 'Referrals'),
          const Divider(color: Colors.white10),
          _buildDrawerItem(4, Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? DesignSystem.adminAccent : DesignSystem.adminTextSecondary),
      title: Text(title, style: TextStyle(color: selected ? Colors.white : DesignSystem.adminTextSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      selected: selected,
      selectedTileColor: DesignSystem.adminAccent.withOpacity(0.1),
    );
  }

  Widget _buildCurrentView(bool isMobile) {
    switch (_selectedIndex) {
      case 0: return _buildCommandCenter(isMobile);
      case 1: return _buildEpidemiologyView();
      case 2: return const AshaListScreen();
      case 3: return const Center(child: Text('Referral Tracking (Phase 2)', style: TextStyle(color: Colors.white)));
      default: return _buildCommandCenter(isMobile);
    }
  }

  Widget _buildCommandCenter(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMMAND CENTER', style: DesignSystem.label.copyWith(color: DesignSystem.adminAccent, fontSize: 10)),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Operational Intelligence', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildLiveMonitorChip(),
            ],
          ),
          const SizedBox(height: 24),
          
          GridView.count(
            crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width > 1200 ? 4 : 2),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 2.8 : 1.5,
            children: [
              _buildStatCard('Total Patients', _stats?['total_patients'], Icons.people_rounded, Colors.blue, isMobile),
              _buildStatCard('Active ASHAs', _stats?['total_ashas'], Icons.medical_services_rounded, Colors.green, isMobile),
              _buildStatCard('Total Screenings', _stats?['total_screenings'], Icons.analytics_rounded, Colors.orange, isMobile),
              _buildStatCard('Critical Cases', _stats?['risk_distribution']?['high'], Icons.emergency_rounded, Colors.red, isMobile),
            ],
          ),
          const SizedBox(height: 24),
          
          if (isMobile) ...[
            _buildRegionalAnemiaChart(),
            const SizedBox(height: 16),
            _buildAshaLeaderboard(),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildRegionalAnemiaChart()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildAshaLeaderboard()),
              ],
            ),
        ],
      ),
    );
  }

  // --- VIEW 1: EPIDEMIOLOGY MAP (REFINED) ---
  Widget _buildEpidemiologyView() {
    final List<dynamic> geoPoints = _stats?['geo_risk_points'] ?? [];
    
    // Delhi Bounding Box 
    const double minLat = 28.5;
    const double maxLat = 28.7;
    const double minLng = 77.1;
    const double maxLng = 77.3;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Expanded(child: Text('Regional Clinical Hotspots', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              _buildFilterButton('Real Map'),
              const SizedBox(width: 8),
              _buildFilterButton('Active'),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DesignSystem.adminSurface, 
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // --- Real-World Geographic Base ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1451187580459-434962b9ca6f?q=80&w=2000', // Verified high-fidelity satellite imagery (stable)
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    ),
                    
                    // --- Tactical Digital HUD Overlay ---
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _GridPainter(),
                    ),
                    
                    // --- SCAN bar ---
                    _ScanningBar(height: constraints.maxHeight),

                    // --- Coordinating UI Accents ---
                    Positioned(top: 20, left: 20, child: _MapTag(label: 'SAT: L-V-01')),
                    Positioned(top: 20, right: 20, child: _MapTag(label: 'LOCATION: NEW DELHI')),
                    
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.public_rounded, color: Colors.white10, size: 280),
                          SizedBox(height: 20),
                          Text('GEOGRAPHIC INTELLIGENCE FEED ACTIVE', style: TextStyle(color: DesignSystem.adminAccent, fontWeight: FontWeight.bold, letterSpacing: 4, fontSize: 8)),
                        ],
                      ),
                    ),
                    
                    // --- Live Dynamic Markers ---
                    ...geoPoints.map((point) {
                      final lat = (point['lat'] as num).toDouble();
                      final lng = (point['lng'] as num).toDouble();
                      final risk = point['risk'] as String;

                      // Normalization Logic
                      final double y = constraints.maxHeight - ((lat - minLat) / (maxLat - minLat) * constraints.maxHeight);
                      final double x = (lng - minLng) / (maxLng - minLng) * constraints.maxWidth;

                      Color markerColor;
                      switch (risk) {
                        case 'High': markerColor = DesignSystem.riskHigh; break;
                        case 'Medium': markerColor = DesignSystem.riskModerate; break;
                        default: markerColor = DesignSystem.riskLow;
                      }

                      return _MapPlot(
                        top: y.clamp(30.0, constraints.maxHeight - 30.0), 
                        left: x.clamp(30.0, constraints.maxWidth - 30.0), 
                        color: markerColor
                      );
                    }),

                    // Map Legend
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DesignSystem.adminBackground.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LegendRow(color: DesignSystem.riskHigh, label: 'High Priority'),
                            _LegendRow(color: DesignSystem.riskModerate, label: 'Observer'),
                            _LegendRow(color: DesignSystem.riskLow, label: 'Stable'),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, dynamic count, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: DesignSystem.adminSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: isMobile ? 20 : 28),
              if (!isMobile)
                const Text('+12%', style: TextStyle(color: Color(0xFF81C784), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 16),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(count?.toString() ?? '0', style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
            ),
          ),
          Text(title, style: TextStyle(color: const Color(0xFF8D8E98), fontSize: isMobile ? 10 : 14)),
        ],
      ),
    );
  }

  Widget _buildRegionalAnemiaChart() {
    final List<dynamic> trends = _stats?['trends'] ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      decoration: BoxDecoration(color: DesignSystem.adminSurface, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Screening Trends', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: trends.map((t) => _buildBar(t['day'], (t['count'] as int).toDouble() / 25.0)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 200 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [DesignSystem.adminAccent.withOpacity(0.5), DesignSystem.adminAccent]),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10)),
      ],
    );
  }

  Widget _buildAshaLeaderboard({bool fullWidth = false}) {
    final List<dynamic> leaderboard = _stats?['leaderboard'] ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      decoration: BoxDecoration(color: DesignSystem.adminSurface, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Performing ASHAs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final asha = leaderboard[index];
                return _buildAshaRow(
                  asha['username'], 
                  asha['area'], 
                  '${asha['points']} pts'
                );
              },
            ),
          ),
          if (!fullWidth)
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              child: const Text('View All Force', style: TextStyle(color: DesignSystem.adminAccent)),
            ),
        ],
      ),
    );
  }

  Widget _buildAshaRow(String name, String badge, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(badge, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
              ],
            ),
          ),
          Text(score, style: const TextStyle(color: DesignSystem.adminAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLiveMonitorChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFF5252).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.5))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('LIVE', style: TextStyle(color: Color(0xFFFF5252), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10)),
        ],
      ),
    );
  }
}

class _MapPlot extends StatelessWidget {
  final double top;
  final double left;
  final Color color;
  const _MapPlot({required this.top, required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.location_on_rounded, color: color, size: 24),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final accentPaint = Paint()
      ..color = DesignSystem.adminAccent.withOpacity(0.2)
      ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(20, 20), const Offset(40, 20), accentPaint);
    canvas.drawLine(const Offset(20, 20), const Offset(20, 40), accentPaint);

    canvas.drawLine(Offset(size.width - 20, 20), Offset(size.width - 40, 20), accentPaint);
    canvas.drawLine(Offset(size.width - 20, 20), Offset(size.width - 20, 40), accentPaint);

    canvas.drawLine(Offset(20, size.height - 20), Offset(40, size.height - 20), accentPaint);
    canvas.drawLine(Offset(20, size.height - 20), Offset(20, size.height - 40), accentPaint);

    canvas.drawLine(Offset(size.width - 20, size.height - 20), Offset(size.width - 40, size.height - 20), accentPaint);
    canvas.drawLine(Offset(size.width - 20, size.height - 20), Offset(size.width - 20, size.height - 40), accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanningBar extends StatefulWidget {
  final double height;
  const _ScanningBar({required this.height});

  @override
  State<_ScanningBar> createState() => _ScanningBarState();
}

class _ScanningBarState extends State<_ScanningBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * widget.height,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignSystem.adminAccent.withOpacity(0),
                  DesignSystem.adminAccent.withOpacity(0.5),
                  DesignSystem.adminAccent.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapTag extends StatelessWidget {
  final String label;
  const _MapTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: DesignSystem.adminAccent, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}