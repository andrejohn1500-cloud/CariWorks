import 'help_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      body: SingleChildScrollView(
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
                      CircleAvatar(radius: 48, backgroundColor: Colors.white,
                        child: Text('JD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5B8DB8)))),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF5B8DB8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('John Doe', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Job Seeker · Kingstown, SVG', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statBox('Applications', '12'),
                      const SizedBox(width: 16),
                      _statBox('Saved', '5'),
                      const SizedBox(width: 16),
                      _statBox('Posted', '0'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            child: const ListTile(
              leading: Icon(Icons.help_outline, color: Color(0xFF5B8DB8)),
              title: Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.chevron_right, color: Colors.black26),
            ),
          ),
        ),
                  const SizedBox(height: 12),
                  _menuItem(Icons.logout, 'Log Out', context, color: Colors.red),
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

  static Widget _menuItem(IconData icon, String label, BuildContext context, {Color? color}) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF5B8DB8)),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? Colors.black87)),
      trailing: color == null ? const Icon(Icons.chevron_right, color: Colors.black26) : null,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label coming soon!'), backgroundColor: const Color(0xFF5B8DB8)),
      ),
    ),
  );
}
