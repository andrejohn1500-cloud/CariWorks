import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _topics = [
    {'icon': Icons.verified_user_outlined, 'title': 'Verification Failed', 'desc': 'My verification did not go through or I did not receive a code.'},
    {'icon': Icons.block_outlined, 'title': 'Account Suspended', 'desc': 'My account has been suspended and I need help understanding why.'},
    {'icon': Icons.post_add_outlined, 'title': 'Listing Removed', 'desc': 'My job or gig listing was removed and I need clarification.'},
    {'icon': Icons.payment_outlined, 'title': 'Payment Issue', 'desc': 'I have a problem with a payment or charge on my account.'},
    {'icon': Icons.flag_outlined, 'title': 'Report a User', 'desc': 'I want to report a user for suspicious or inappropriate behaviour.'},
    {'icon': Icons.login_outlined, 'title': 'Login / Access Issue', 'desc': 'I cannot log in or access my account.'},
    {'icon': Icons.help_outline, 'title': 'Other Issue', 'desc': 'My issue is not listed above.'},
  ];

  Map<String, dynamic>? _selected;
  final _detailController = TextEditingController();
  final _emailController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _selected != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => setState(() { _selected = null; _submitted = false; }),
              )
            : null,
        title: Text(
          _selected == null ? 'Help & Support' : _selected!['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: _submitted ? _successView() : (_selected == null ? _topicList() : _detailForm()),
    );
  }

  Widget _topicList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5B8DB8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF5B8DB8), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Our team responds within 24–48 hours. Select a topic to get started.',
                  style: TextStyle(color: Color(0xFF5B8DB8), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _topics.length,
            itemBuilder: (ctx, i) {
              final t = _topics[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8DB8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t['icon'] as IconData, color: const Color(0xFF5B8DB8), size: 22),
                  ),
                  title: Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                  onTap: () => setState(() => _selected = t),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _detailForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _selected!['desc'] as String,
              style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Your Email *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Describe your issue *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detailController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Please provide as much detail as possible...',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5B8DB8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Color(0xFF5B8DB8)),
                SizedBox(width: 8),
                Text('Expected response: 24–48 hours', style: TextStyle(fontSize: 12, color: Color(0xFF5B8DB8))),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DB8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DB8).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF5B8DB8)),
            ),
            const SizedBox(height: 24),
            const Text('Request Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Your support request has been received. Our team will get back to you within 24–48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() { _selected = null; _submitted = false; _detailController.clear(); _emailController.clear(); }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DB8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Help', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    final topic = _selected!['title'] as String;
    final userEmail = _emailController.text;
    final message = _detailController.text;
    final subject = '[CariWorks Support] $topic';
    final html = '<h2>CariWorks Support Request</h2><p><b>Topic:</b> $topic</p><p><b>From:</b> $userEmail</p><p><b>Message:</b></p><p>$message</p>';
    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer re_NJBV6fu3_Lp7rfv8v8pWvcr5N7pW623r1',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'onboarding@resend.dev',
          'to': 'andrejohn1500@gmail.com',
          'subject': subject,
          'html': html,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() { _loading = false; _submitted = true; });
      } else {
        setState(() => _loading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }
}
