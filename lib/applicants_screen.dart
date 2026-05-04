import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'applicant_detail_screen.dart';

class ApplicantsScreen extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  const ApplicantsScreen({super.key, required this.listingId, required this.listingTitle});
  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _applicants = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetchApplicants(); }

  Future<void> _fetchApplicants() async {
    try {
      final data = await _supabase
          .from('applications')
          .select('id, created_at, user_id, profiles(full_name, email, phone, country, bio)')
          .eq('listing_id', widget.listingId)
          .order('created_at', ascending: false);
      final List<Map<String, dynamic>> enriched = [];
    for (final a in data) {
      final map = Map<String, dynamic>.from(a);
      try {
        final emailResult = await _supabase.rpc('get_user_email', params: {'user_id': a['user_id']});
        final profile = Map<String, dynamic>.from(map['profiles'] ?? {});
        profile['email'] = emailResult ?? '';
        map['profiles'] = profile;
        map['email_direct'] = emailResult ?? '';
      } catch (e) {
        map['email_direct'] = '';
      }
      enriched.add(map);
    }
    setState(() { _applicants = enriched; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    try {
      await _supabase
          .from('applications')
          .update({'status': status})
          .eq('id', applicationId);
      await _fetchApplicants();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applicant $status'), backgroundColor: status == 'accepted' ? Colors.green : Colors.red),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Applicants', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(widget.listingTitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        backgroundColor: const Color(0xFF5B8DB8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No applicants yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Share your listing to attract applicants', style: TextStyle(color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applicants.length,
                  itemBuilder: (ctx, i) {
                    final a = _applicants[i];
                    final profile = a['profiles'] as Map<String, dynamic>? ?? {};
                    final name = profile['full_name'] ?? 'Unknown';
                    final email = (a['email_direct'] ?? profile['email'] ?? '') as String;
                    final phone = profile['phone'] ?? '';
                    final country = profile['country'] ?? '';
                    final bio = profile['bio'] ?? '';
                    final date = DateTime.tryParse(a['created_at'] ?? '');
                    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Builder(builder: (context) {
                              final appStatus = (a['status'] ?? 'pending').toString();
                              if (appStatus == 'accepted' || appStatus == 'rejected') {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: appStatus == 'accepted' ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: appStatus == 'accepted' ? Colors.green : Colors.red, width: 1.5),
                                  ),
                                  child: Text(
                                    appStatus == 'accepted' ? '✓ Accepted' : '✗ Rejected',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: appStatus == 'accepted' ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                );
                              }
                              return Row(children: [
                                Expanded(child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                  label: const Text('Accept', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () => _updateStatus(a['id'].toString(), 'accepted'),
                                )),
                                const SizedBox(width: 8),
                                Expanded(child: ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  label: const Text('Reject', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => _updateStatus(a['id'].toString(), 'rejected'),
                                )),
                              ]);
                            }),
                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(bio, style: const TextStyle(fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 12),
                          const SizedBox(height: 8),
                          Row(children: [
                            if (email.isNotEmpty) Expanded(child: OutlinedButton.icon(
                              icon: const Icon(Icons.email, size: 16),
                              label: const Text('Email'),
                              onPressed: () async {
                                final uri = Uri.parse('mailto:$email');
                                // ignore: deprecated_member_use
                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                            )),
                            if (email.isNotEmpty && phone.isNotEmpty) const SizedBox(width: 8),
                            if (phone.isNotEmpty) Expanded(child: OutlinedButton.icon(
                              icon: const Icon(Icons.phone, size: 16),
                              label: const Text('Call'),
                              onPressed: () async {
                                final uri = Uri.parse('tel:$phone');
                                // ignore: deprecated_member_use
                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                            )),
                          ]),
                        ]),
                      ),
                    );
                  }),
    );
  }
}
