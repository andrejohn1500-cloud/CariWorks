import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;
  final String listingTitle;
  const ApplicantDetailScreen({super.key, required this.application, required this.listingTitle});
  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _fullApplication;
  bool _loading = true;
  bool _isPremiumPost = false;

  @override
  void initState() { super.initState(); _fetchFullDetails(); }

  Future<void> _fetchFullDetails() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      final premCheck = await _supabase.from('premium_posts').select('id').eq('user_id', uid ?? '').maybeSingle();
      final data = await _supabase.from('applications')
          .select('*, profiles(full_name, email, phone, country, bio, avg_rating, rating_count, avatar_url)')
          .eq('id', widget.application['id']).single();
      if (mounted) setState(() { _fullApplication = data; _isPremiumPost = premCheck != null; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await _supabase.from('applications').update({'status': status}).eq('id', widget.application['id']);
      if (mounted) {
        setState(() => _fullApplication?['status'] = status);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Applicant ${status == "accepted" ? "✓ Accepted" : "✗ Rejected"}'),
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

  Widget _field(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _fullApplication ?? widget.application;
    final profile = (a['profiles'] as Map<String, dynamic>?) ?? {};
    final name = profile['full_name'] ?? 'Unknown';
    final country = profile['country'] ?? '';
    final bio = profile['bio'] ?? '';
    final email = a['email_direct'] ?? profile['email'] ?? '';
    final phone = profile['phone'] ?? '';
    final avgRating = profile['avg_rating'];
    final ratingCount = profile['rating_count'] ?? 0;
    final appStatus = (a['status'] ?? 'pending').toString();
    final coverLetter = a['cover_letter'] ?? '';
    final yearsExp = a['years_experience'];
    final availability = a['availability'] ?? '';
    final portfolioUrl = a['portfolio_url'] ?? '';
    final certifications = a['certifications'] ?? '';
    final rateValue = a['expected_rate_value'];
    final rateCurrency = a['expected_rate_currency'] ?? '';
    final rateType = a['rate_type'] ?? '';
    final rateStr = rateValue != null ? '$rateCurrency $rateValue / $rateType' : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Applicant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(widget.listingTitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        backgroundColor: const Color(0xFF5B8DB8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF5B8DB8),
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (country.isNotEmpty) Text(country, style: const TextStyle(color: Colors.grey)),
                        if (avgRating != null) Row(children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(' ${(avgRating as num).toStringAsFixed(1)} ($ratingCount reviews)',
                              style: const TextStyle(fontSize: 12)),
                        ]),
                      ])),
                      if (appStatus == 'accepted' || appStatus == 'rejected')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: appStatus == 'accepted' ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: appStatus == 'accepted' ? Colors.green : Colors.red, width: 1.5),
                          ),
                          child: Text(appStatus == 'accepted' ? '✓ Accepted' : '✗ Rejected',
                              style: TextStyle(color: appStatus == 'accepted' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Application Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      if (bio.isNotEmpty) _field('About', bio),
                      if (yearsExp != null) _field('Experience', '$yearsExp year${yearsExp == 1 ? "" : "s"}'),
                      if (availability.isNotEmpty) _field('Availability', availability),
                      if (rateStr.isNotEmpty) _field('Expected Rate', rateStr),
                      if (coverLetter.isNotEmpty) ...[
                        const Text('Cover Letter', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        if (_isPremiumPost)
                          Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(coverLetter, style: const TextStyle(fontSize: 15)))
                        else
                          GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Upgrade to Premium Post to read cover letters'),
                              backgroundColor: Color(0xFF5B8DB8),
                            )),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              ),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.lock_outline, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Upgrade to Premium Post to unlock', style: TextStyle(color: Colors.grey)),
                              ]),
                            ),
                          ),
                      ],
                      if (portfolioUrl.isNotEmpty) _field('Portfolio', portfolioUrl),
                      if (certifications.isNotEmpty) _field('Certifications', certifications),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact / Premium gate
                if (_isPremiumPost && (email.isNotEmpty || phone.isNotEmpty))
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
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
                  )
                else if (!_isPremiumPost)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        const Icon(Icons.lock_outline, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Upgrade to Premium Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Unlock full contact details and cover letters',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B8DB8)),
                          onPressed: () async { await launchUrl(Uri.parse('https://www.paypal.com/ncp/payment/359PF493G56BG'), mode: LaunchMode.externalApplication); },
                          child: const Text('Upgrade (\$10)', style: TextStyle(color: Colors.white)),
                        ),
                      ]),
                    ),
                  ),
                const SizedBox(height: 16),

                // Accept / Reject
                if (appStatus == 'pending') Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Accept', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => _updateStatus('accepted'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('Reject', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => _updateStatus('rejected'),
                  )),
                ]),
                const SizedBox(height: 24),
                if (appStatus == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text('Mark as Completed', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _showRatingSheet(),
                      ),
                    ),
                  ),
              ]),
            ),
    );
  }
  void _showRatingSheet() {
    int _selectedRating = 0;
    final TextEditingController _reviewController = TextEditingController();
    final supabase = Supabase.instance.client;
    final revieweeId = widget.application['applicant_id'];
    final listingId = widget.application['listing_id'];
    final reviewerId = supabase.auth.currentUser?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rate this Applicant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber, size: 36,
                  ),
                  onPressed: () => setModalState(() => _selectedRating = i + 1),
                )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D62),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (_selectedRating == 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a star rating'))); return; }
                    await supabase.from('ratings').insert({
                      'reviewer_id': reviewerId,
                      'reviewee_id': revieweeId,
                      'listing_id': listingId,
                      'rating': _selectedRating,
                      'review': _reviewController.text.trim(),
                    });
                    final rows = await supabase
                        .from('ratings')
                        .select('rating')
                        .eq('reviewee_id', revieweeId);
                    if (rows.isNotEmpty) {
                      final avg = rows.map((r) => r['rating'] as int).reduce((a, b) => a + b) / rows.length;
                      await supabase.from('profiles').update({'avg_rating': avg}).eq('id', revieweeId);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating submitted!'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  child: const Text('Submit Rating', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
