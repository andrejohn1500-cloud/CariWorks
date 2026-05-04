import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplyForm extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onApplied;
  const ApplyForm({super.key, required this.listing, required this.onApplied});

  @override
  State<ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends State<ApplyForm> {
  final _coverLetterCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _certsCtrl = TextEditingController();
  final _rateValueCtrl = TextEditingController();
  String _rateCurrency = 'XCD';
  String _rateType = 'monthly';

  // Approximate XCD conversion rates (no API needed)
  final Map<String, double> _toXCD = {
    'XCD': 1.0, 'USD': 2.70, 'JMD': 0.018, 'TTD': 0.40, 'BBD': 1.35,
  };

  String _convertedEstimate() {
    final v = double.tryParse(_rateValueCtrl.text);
    if (v == null || v == 0 || _rateCurrency == 'XCD') return '';
    final xcd = v * (_toXCD[_rateCurrency] ?? 1.0);
    return '≈ \$${xcd.toStringAsFixed(0)} XCD';
  }
  String _availability = 'Immediately';
  bool _submitting = false;

  final _availabilityOptions = ['Immediately', 'Within 2 weeks', 'Within 1 month', 'Negotiable'];

  String _experienceLabel() {
    final y = int.tryParse(_yearsCtrl.text) ?? 0;
    if (y == 0) return '';
    return y == 1 ? '1 year' : '$y years';
  }

  Future<void> _submit() async {
    if (_coverLetterCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cover letter is required'), backgroundColor: Colors.red));
      return;
    }
    if (_yearsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Years of experience is required'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final listingId = widget.listing['id'] ?? '';
      await Supabase.instance.client.from('applications').insert({
        'user_id': user.id,
        'listing_id': listingId,
        'cover_letter': _coverLetterCtrl.text.trim(),
        'years_experience': int.tryParse(_yearsCtrl.text.trim()) ?? 0,
        'availability': _availability,
        'portfolio_url': _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
        'certifications': _certsCtrl.text.trim().isEmpty ? null : _certsCtrl.text.trim(),
        'expected_rate': _rateValueCtrl.text.trim().isEmpty ? null : '\${_rateValueCtrl.text.trim()} \$_rateCurrency/\$_rateType',
        'expected_rate_value': double.tryParse(_rateValueCtrl.text.trim()),
        'expected_rate_currency': _rateCurrency,
        'rate_type': _rateType,
        'status': 'pending',
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onApplied();
        // Open email
        final email = widget.listing['contact_email'] ?? '';
        if (email.isNotEmpty) {
          final uri = Uri.parse('mailto:$email?subject=Application for ${widget.listing["title"]}');
          // ignore: deprecated_member_use
          await launchUrl(uri);
        }
      }
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('duplicate')) {
        if (mounted) { Navigator.pop(context); widget.onApplied(); }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _requiredLabel(String label) => RichText(
    text: TextSpan(children: [
      TextSpan(text: label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
      const TextSpan(text: ' ✱', style: TextStyle(color: Colors.red, fontSize: 14)),
    ]),
  );

  Widget _optionalLabel(String label) => Text(
    '$label (optional)',
    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 14),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text('Apply — ${widget.listing["title"] ?? ""}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              // Cover Letter
              _requiredLabel('Cover Letter'),
              const SizedBox(height: 4),
              const Text('Tell the employer why you\'re the right fit', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _coverLetterCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'I am applying because...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: const Color(0xFFF8F8F8),
                ),
              ),
              const SizedBox(height: 16),

              // Years Experience
              _requiredLabel('Years of Experience in this field'),
              const SizedBox(height: 8),
              Row(children: [
                SizedBox(width: 100, child: TextField(
                  controller: _yearsCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: const Color(0xFFF8F8F8),
                    suffixText: 'yrs',
                  ),
                )),
                const SizedBox(width: 12),
                if (_yearsCtrl.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90B8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4A90B8)),
                    ),
                    child: Text(_experienceLabel(),
                      style: const TextStyle(color: Color(0xFF4A90B8), fontWeight: FontWeight.bold)),
                  ),
              ]),
              const SizedBox(height: 16),

              // Availability
              _requiredLabel('Availability'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _availability,
                items: _availabilityOptions.map<DropdownMenuItem<String>>((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _availability = v!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: const Color(0xFFF8F8F8),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('OPTIONAL DETAILS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),

              // Expected Rate
              _optionalLabel('Expected Rate'),
              const SizedBox(height: 4),
              const Text('What rate do you expect for this role?', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                SizedBox(width: 120, child: TextField(
                  controller: _rateValueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: const Color(0xFFF8F8F8),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: DropdownButtonFormField<String>(
                  initialValue: _rateCurrency,
                  items: ['XCD','USD','JMD','TTD','BBD'].map<DropdownMenuItem<String>>((c) =>
                    DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _rateCurrency = v!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: const Color(0xFFF8F8F8),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: DropdownButtonFormField<String>(
                  initialValue: _rateType,
                  items: ['hourly','daily','weekly','monthly','per job'].map<DropdownMenuItem<String>>((t) =>
                    DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _rateType = v!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: const Color(0xFFF8F8F8),
                  ),
                )),
              ]),
              if (_rateValueCtrl.text.isNotEmpty && _convertedEstimate().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(_convertedEstimate(),
                  style: const TextStyle(color: Color(0xFF4A90B8), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 16),

              // Portfolio
              _optionalLabel('Portfolio / Website'),
              const SizedBox(height: 8),
              TextField(
                controller: _portfolioCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://yourportfolio.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: const Color(0xFFF8F8F8),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),

              // Certifications
              _optionalLabel('Certifications / Qualifications'),
              const SizedBox(height: 8),
              TextField(
                controller: _certsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. CXC Carpentry, City & Guilds Level 2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: const Color(0xFFF8F8F8),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          )),
        ]),
      ),
    );
  }
}
