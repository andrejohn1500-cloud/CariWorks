import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _profileVisible = true;
  bool _showEmail = false;
  bool _jobAlerts = true;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadSettings(); }

  Future<void> _loadSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('profile_visible, show_email, job_alerts')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted && data != null) setState(() {
        _profileVisible = data['profile_visible'] ?? true;
        _showEmail = data['show_email'] ?? false;
        _jobAlerts = data['job_alerts'] ?? true;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSetting(String key, bool val) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('profiles').update({key: val}).eq('id', user.id);
  }

  Widget _toggle(String title, String subtitle, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        value: val,
        activeThumbColor: const Color(0xFF5B8DB8),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5B8DB8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _toggle('Public Profile', 'Allow others to view your profile', _profileVisible, (v) {
                    setState(() => _profileVisible = v);
                    _saveSetting('profile_visible', v);
                  }),
                  _toggle('Show Email', 'Display your email on your profile', _showEmail, (v) {
                    setState(() => _showEmail = v);
                    _saveSetting('show_email', v);
                  }),
                  const SizedBox(height: 16),
                  const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _toggle('Job Alerts', 'Receive notifications for new matching jobs', _jobAlerts, (v) {
                    setState(() => _jobAlerts = v);
                    _saveSetting('job_alerts', v);
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Delete Account'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
