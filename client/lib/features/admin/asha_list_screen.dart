import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
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

  // ---- ADD THESE METHODS FOR EDIT/DELETE ----
  Future<void> _deleteAsha(String id, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Worker'),
        content: Text('Are you sure you want to delete $username? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );

    if (confirm == true) {
      try {
        await _api.delete('/admin/ashas/$id');
        _fetchAshas();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker deleted.')));
        }
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
        title: const Text('Edit Worker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area'),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
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
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASHA Workers (Leaderboard)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAshaScreen()),
          );
          if (result == true) {
            _fetchAshas();
          }
        },
        child: const Icon(Icons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ashas.isEmpty
              ? const Center(child: Text('No ASHA workers found.'))
              : ListView.builder(
                  itemCount: _ashas.length,
                  itemBuilder: (context, index) {
                    final asha = _ashas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), // Leaderboard Rank
                        ),
                        title: Text(asha['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Area: ${asha['area'] ?? 'Not Assigned'} • ⭐️ ${asha['points'] ?? 0} pts'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editAsha(asha),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAsha(asha['id'], asha['username']),
                            ),
                          ],
                        ),
                        // ---- NEW ONTAP INTERACTION ----
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientListScreen(ashaId: asha['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
