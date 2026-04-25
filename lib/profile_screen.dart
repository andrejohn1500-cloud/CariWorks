import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_listings_screen.dart';
import 'saved_jobs_screen.dart';
import 'notifications_screen.dart';
import 'applications_screen.dart';
import 'privacy_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _avatarUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (mounted) setState(() { _profile = data; _avatarUrl = data?['avatar_url']; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }



  Future<void> _showEditProfile() async {
    final nameCtrl = TextEditingController(text: _profile?['full_name'] ?? '');
    final bioCtrl = TextEditingController(text: _profile?['bio'] ?? '');
    String? country = _profile?['country'] ?? _profile?['location'];
    final countries = ['Antigua and Barbuda','Bahamas','Barbados','Belize','Dominica','Grenada','Guyana','Haiti','Jamaica','Montserrat','Saint Kitts and Nevis','Saint Lucia','Saint Vincent and the Grenadines','Suriname','Trinidad and Tobago','Other Caribbean','Other'];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: countries.contains(country) ? country : null,
                decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModal(() => country = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B8DB8), foregroundColor: Colors.white),
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) return;
                    await Supabase.instance.client.from('profiles').update({
                      'full_name': nameCtrl.text.trim(),
                      'bio': bioCtrl.text.trim(),
                      'country': country ?? '',
                    }).eq('id', user.id);
                    if (mounted) { Navigator.pop(ctx); _fetchProfile(); }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (img == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final bytes = await img.readAsBytes();
    final path = '${user.id}/avatar.jpg';
    try {
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
        path, bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
      await Supabase.instance.client.from('profiles').update({'avatar_url': url}).eq('id', user.id);
      if (mounted) setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  String get _initials {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    if (email.isEmpty) return 'U';
    return email[0].toUpperCase();
  }

  String get _displayName {
    if (_profile?['full_name'] != null && (_profile!['full_name'] as String).isNotEmpty) {
      return _profile!['full_name'];
    }
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return email.split('@').first;
  }

  String get _accountTypeLabel {
    final t = _profile?['account_type'] ?? '';
    if (t == 'seeker') return 'Job Seeker';
    if (t == 'employer') return 'Employer';
    if (t == 'both') return 'Job Seeker & Employer';
    return 'CariWorks Member';
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B8DB8),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null ? Text(_initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5B8DB8))) : null,
                    ),
                            Positioned(bottom: 0, right: 0, child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: GestureDetector(onTap: _uploadAvatar, child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF5B8DB8))),
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$_accountTypeLabel · ${_profile?['location'] ?? 'Caribbean'}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _statBox('Applications', '0'),
                          const SizedBox(width: 16),
                          _statBox('Saved', '0'),
                          const SizedBox(width: 16),
                          _statBox('Posted', '0'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                if (_profile?['account_type'] == 'jobseeker')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star, color: Colors.white),
                      label: const Text('Go Premium - USD 3/month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final supabase = Supabase.instance.client;
                        await supabase.from('premium_seekers').insert({
                          'user_id': supabase.auth.currentUser!.id,
                          'status': 'pending',
                        });
                        final uri = Uri.parse('https://www.paypal.com/ncp/payment/S9XKCJPMUSK56');
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E4DE))),
                          child: Row(children: [
                            const Icon(Icons.email_outlined, color: Color(0xFF5B8DB8), size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(email, style: const TextStyle(fontSize: 14, color: Color(0xFF636E72)))),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 12),
                        _menuItem(Icons.person_outline, 'Edit Profile', context),
                        _menuItem(Icons.work_outline, 'My Applications', context),
                        _menuItem(Icons.bookmark_outline, 'Saved Jobs', context),
                        _menuItem(Icons.post_add, 'My Listings', context),
                        const SizedBox(height: 24),
                        const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 12),
                        _menuItem(Icons.notifications_outlined, 'Notifications', context),
                        _menuItem(Icons.lock_outline, 'Privacy & Security', context),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              leading: const Icon(Icons.help_outline, color: Color(0xFF5B8DB8)),
                              title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Logout button
                        GestureDetector(
                          onTap: _logout,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.withOpacity(0.3))),
                            child: ListTile(
                              leading: const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static Widget _statBox(String label, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );

  static Widget _menuItem(IconData icon, String label, BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF5B8DB8)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label coming soon!'), backgroundColor: const Color(0xFF5B8DB8))),
    ),
  );
}
