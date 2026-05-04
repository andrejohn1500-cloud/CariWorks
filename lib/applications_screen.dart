import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<dynamic> _apps = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from("applications")
          .select("id, status, created_at, listings(title, category, location)")
          .eq("user_id", user.id)
          .order("created_at", ascending: false);
      if (mounted) setState(() { _apps = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case "accepted": return Colors.green;
      case "rejected": return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5B8DB8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _apps.isEmpty
              ? const Center(child: Text("No applications yet.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _apps.length,
                  itemBuilder: (ctx, i) {
                    final a = _apps[i];
                    final j = a["listings"];
                    final status = a["status"] ?? "pending";
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(j?["title"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _statusColor(status), width: 1.5),
                          ),
                          child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${j?["category"] ?? ""} • ${j?["location"] ?? ""}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                    );
                  },
                ),
    );
  }
}