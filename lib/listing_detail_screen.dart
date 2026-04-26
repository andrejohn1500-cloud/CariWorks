import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isJob = listing['type'] == 'Job';
    final color = isJob ? const Color(0xFFFF5B8DB8) : const Color(0xFFFFD4A843);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isJob ? 'Job Details' : 'Service Details',
            style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing['featured'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(4)),
                child: const Text('⭐ Featured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            Text(listing['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 8),
            Text(listing['company'] ?? listing['user_id'] ?? '', style: const TextStyle(fontSize: 16, color: Color(0xFF636E72))),
            const SizedBox(height: 16),
            _infoRow(Icons.location_on_outlined, listing['location'] ?? 'Location not specified'),
            const SizedBox(height: 8),
            _infoRow(Icons.work_outline, listing['job_type'] ?? listing['type'] ?? ''),
            if (listing['salary'] != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.payments_outlined, listing['salary']),
            ],
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 8),
            Text(listing['description'] ?? 'No description provided.', style: const TextStyle(fontSize: 14, color: Color(0xFF636E72), height: 1.6)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B8DB8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final email = listing['contact_email'] ?? '';
                  if (email.isNotEmpty) {
                    final uri = Uri.parse('mailto:$email?subject=Application for ${listing['title']}');
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No contact info available')));
                  }
                },
                child: const Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
