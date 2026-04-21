import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
import 'add_asha_screen.dart';
import '../patient/patient_list_screen.dart';

class AshaListScreen extends StatefulWidget {
  const AshaListScreen({super.key});

  @override
  State<AshaListScreen> createState() => _AshaListScreenState();
}

class _AshaListScreenState extends State<AshaListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _ashas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAshas();
  }

  Future<void> _fetchAshas() async {
    try {
      final data = await _api.get('/admin/ashas');
      setState(() {
        _ashas = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching ASHAs: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAsha(String id, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.adminSurface,
        title: const Text('Remove Worker', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove $username from the force? This cannot be undone.', style: const TextStyle(color: DesignSystem.adminTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: DesignSystem.adminTextSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Remove', style: TextStyle(color: DesignSystem.riskHigh))
          ),
        ],
      )
    );

    if (confirm == true) {
      try {
        await _api.delete('/admin/ashas/$id');
        _fetchAshas();
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _editAsha(Map<String, dynamic> asha) async {
    final areaController = TextEditingController(text: asha['area']);
    final usernameController = TextEditingController(text: asha['username']);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.adminSurface,
        title: const Text('Edit ASHA Worker', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(usernameController, 'Username', Icons.person_rounded),
            const SizedBox(height: 16),
            _buildDialogField(areaController, 'Assigned Area', Icons.map_rounded),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: DesignSystem.adminTextSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.adminAccent),
            child: const Text('Save Changes', style: TextStyle(color: DesignSystem.adminBackground, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );

    if (confirm == true) {
      try {
        await _api.put('/admin/ashas/${asha['id']}', {
          'username': usernameController.text,
          'area': areaController.text
        });
        _fetchAshas();
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: DesignSystem.adminTextSecondary),
        prefixIcon: Icon(icon, color: DesignSystem.adminAccent, size: 20),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: DesignSystem.adminAccent), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: DesignSystem.adminAccent))
        : Stack(
            children: [
              _ashas.isEmpty
                  ? const Center(child: Text('No ASHA workers found.', style: TextStyle(color: DesignSystem.adminTextSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: _ashas.length,
                      itemBuilder: (context, index) {
                        final asha = _ashas[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: DesignSystem.adminSurface,
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientListScreen(ashaId: asha['id']),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: DesignSystem.adminAccent.withOpacity(0.1),
                              child: Text(
                                '#${index + 1}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: DesignSystem.adminAccent, fontSize: 12)
                              ),
                            ),
                            title: Text(
                              asha['username'] ?? 'Unknown', 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)
                            ),
                            subtitle: Text(
                              '${asha['area'] ?? 'General Region'} • ⭐️ ${asha['points'] ?? 0} pts',
                              style: const TextStyle(color: DesignSystem.adminTextSecondary, fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.mode_edit_outline_rounded, color: DesignSystem.adminAccent, size: 18),
                                  onPressed: () => _editAsha(asha),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: DesignSystem.riskHigh, size: 18),
                                  onPressed: () => _deleteAsha(asha['id'], asha['username']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddAshaScreen()),
                    );
                    if (result == true) {
                      _fetchAshas();
                    }
                  },
                  backgroundColor: DesignSystem.adminAccent,
                  icon: const Icon(Icons.person_add_rounded, color: DesignSystem.adminBackground),
                  label: const Text('DEPLOY WORKER', style: TextStyle(color: DesignSystem.adminBackground, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          );
  }
}
