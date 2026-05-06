import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { if (mounted) setState(() => _loading = false); return; }
    final data = await Supabase.instance.client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    if (mounted) setState(() { _notifications = List<Map<String, dynamic>>.from(data); _loading = false; });
    // Mark all as read
    await Supabase.instance.client.from('notifications').update({'is_read': true}).eq('user_id', user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)), onPressed: () => Navigator.pop(context)),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3436))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.notifications_none_rounded, size: 64, color: Color(0xFFCDD5DE)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF636E72))),
                  const SizedBox(height: 8),
                  const Text('You will see job alerts and updates here', style: TextStyle(fontSize: 13, color: Color(0xFFB2BEC3))),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, i) {
                    final n = _notifications[i];
                    final isRead = n['is_read'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFEBF5FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isRead ? Colors.grey.withValues(alpha: 0.15) : const Color(0xFF5B8DB8).withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.notifications, color: isRead ? const Color(0xFFB2BEC3) : const Color(0xFF5B8DB8), size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14, color: const Color(0xFF2D3436))),
                          const SizedBox(height: 2),
                          Text(n['body'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                        ])),
                      ]),
                    );
                  }),
    );
  }
}
