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
          .select('id, created_at, status, user_id, profiles(full_name, email, phone, country, bio)')
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
      await _supabase.from('applications').update({'status': status}).eq('id', applicationId);
      await _fetchApplicants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Applicant $status'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
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
                    final country = profile['country'] ?? '';
                    final bio = profile['bio'] ?? '';
                    final status = (a['status'] ?? 'pending').toString();
                    final date = DateTime.tryParse(a['created_at'] ?? '');
                    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';
                    final statusColor = status == 'accepted' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;
                    final statusLabel = status == 'accepted' ? '✓ Accepted' : status == 'rejected' ? '✗ Rejected' : '● Pending';

                    return GestureDetector(
                      onTap: () => Navigator.push(ctx,
                        MaterialPageRoute(builder: (_) => ApplicantDetailScreen(
                          application: a, listingTitle: widget.listingTitle,
                        ))).then((_) => _fetchApplicants()),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF5B8DB8),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                if (country.isNotEmpty) Text(country, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                if (dateStr.isNotEmpty) Text('Applied $dateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor, width: 1.2),
                                ),
                                child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ]),
                            if (bio.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(bio, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                            const SizedBox(height: 8),
                            if (status == 'pending')
                              Row(children: [
                                Expanded(child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                  label: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _updateStatus(a['id'].toString(), 'accepted'),
                                )),
                                const SizedBox(width: 6),
                                Expanded(child: ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                  label: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _updateStatus(a['id'].toString(), 'rejected'),
                                )),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: Color(0xFF5B8DB8)),
                                  ),
                                  onPressed: null,
                                  child: const Text('View', style: TextStyle(color: Color(0xFF5B8DB8), fontSize: 12)),
                                ),
                              ])
                            else
                              Row(children: [
                                if (email.isNotEmpty) OutlinedButton.icon(
                                  icon: const Icon(Icons.email_outlined, size: 14),
                                  label: const Text('Email', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final uri = Uri.parse('mailto:$email');
                                    // ignore: deprecated_member_use
                                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                                  },
                                ),
                                const Spacer(),
                                const Text('View Profile', style: TextStyle(color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(width: 2),
                                const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF5B8DB8)),
                              ]),
                          ]),
                        ),
                      ),
                    );
                  }),
    );
  }
}
