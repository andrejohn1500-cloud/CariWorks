import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isSaved = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final listingId = widget.listing['id'] ?? '';
    final res = await Supabase.instance.client
        .from('applications')
        .select('id')
        .eq('user_id', user.id)
        .eq('listing_id', listingId)
        .limit(1);
    if (mounted) setState(() => _isApplied = (res as List).isNotEmpty);
  }

  Future<void> _saveJob() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { _showSnack('Sign in to save listings', Colors.orange); return; }
    final listingId = widget.listing['id'] ?? '';
    try {
      await Supabase.instance.client.from('saved_jobs').insert({'user_id': user.id, 'listing_id': listingId});
      if (mounted) { setState(() => _isSaved = true); _showSnack('Listing saved!', const Color(0xFF5B8DB8)); }
    } catch (e) {
      if (mounted) _showSnack('Already saved', Colors.orange);
    }
  }

  Future<void> _applyJob() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { _showSnack('Sign in to apply', Colors.orange); return; }
    final listingId = widget.listing['id'] ?? '';
    try {
      await Supabase.instance.client.from('applications').insert({'user_id': user.id, 'listing_id': listingId});
      if (mounted) setState(() => _isApplied = true);
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('duplicate')) {
        if (mounted) setState(() => _isApplied = true);
      } else {
        if (mounted) _showSnack('Error: $e', Colors.red);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _handleApplyNow() async {
    await _applyJob();
    final email = widget.listing['contact_email'] ?? '';
    if (email.isNotEmpty) {
      final uri = Uri.parse('mailto:$email?subject=Application for ${widget.listing["title"]}');
      await launchUrl(uri);
    } else {
      if (mounted) _showSnack('No contact info available', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isJob = widget.listing['type'] == 'Job';
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isJob ? 'Job Details' : 'Service Details',
            style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF5B8DB8)),
            onPressed: _saveJob,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.listing['featured'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(4)),
                child: const Text('⭐ Featured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            Text(widget.listing['title'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 8),
            Text(widget.listing['company'] ?? widget.listing['user_id'] ?? '',
                style: const TextStyle(fontSize: 16, color: Color(0xFF636E72))),
            const SizedBox(height: 16),
            _infoRow(Icons.location_on_outlined, widget.listing['location'] ?? 'Location not specified'),
            const SizedBox(height: 8),
            _infoRow(Icons.work_outline, widget.listing['job_type'] ?? widget.listing['type'] ?? ''),
            if (widget.listing['salary'] != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.payments_outlined, widget.listing['salary']),
            ],
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 8),
            Text(widget.listing['description'] ?? 'No description provided.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF636E72), height: 1.6)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DB8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isApplied ? null : _handleApplyNow,
                child: Text(_isApplied ? 'Applied ✓' : 'Apply Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF636E72)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF636E72)))),
        ],
      );
}
