import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String _type = 'Employer';
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descController = TextEditingController();
  String _jobType = 'Full-Time';
  bool _loading = false;

  final _types = ['Employer', 'Worker / Freelancer'];
  final _jobTypes = ['Full-Time', 'Part-Time', 'Contract', 'Remote'];

  String? _accountType;

  @override
  void initState() {
    super.initState();
    _loadAccountType();
  }

  Future<void> _loadAccountType() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('account_type')
        .eq('id', user.id)
        .maybeSingle();
    if (mounted && data != null) {
      final at = data['account_type'] ?? 'Worker / Freelancer';
      setState(() {
        _accountType = at;
        _type = at == 'Employer' ? 'Employer' : 'Worker / Freelancer';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('listings').insert({
        'user_id': user?.id,
        'type': _type,
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'salary': _salaryController.text.trim(),
        'job_type': _jobType,
        'description': _descController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_type posted successfully! 🎉'),
            backgroundColor: const Color(0xFF5B8DB8),
          ),
        );
        _titleController.clear();
        _companyController.clear();
        _locationController.clear();
        _salaryController.clear();
        _descController.clear();
        setState(() => _type = 'Employer');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Post a Listing', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Container(
              decoration: BoxDecoration(color: const Color(0xFFE8F0FB), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: _types.map((t) {
                  final sel = t == _type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF5B8DB8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(t, textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black54)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _label('${_type} Title *'),
            _field(_titleController, 'e.g. Senior Web Developer'),
            const SizedBox(height: 16),
            _label(_type == 'Employer' ? 'Company Name *' : 'Your Name / Brand *'),
            _field(_companyController, 'e.g. TechSVG Ltd'),
            const SizedBox(height: 16),
            _label('Location *'),
            _field(_locationController, 'e.g. Kingstown, SVG'),
            const SizedBox(height: 16),
            _label(_type == 'Employer' ? 'Salary (per month)' : 'Rate (per hour/project)'),
            _field(_salaryController, 'e.g. \$2,500'),
            const SizedBox(height: 16),
            _label('Type'),
            DropdownButtonFormField<String>(
              value: _jobType,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _jobTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _jobType = v!),
            ),
            const SizedBox(height: 16),
            _label('Description *'),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the role, requirements, responsibilities...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
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
                    : Text(_type == 'Employer' ? 'Post Job' : 'Post My Service', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
  );

  Widget _field(TextEditingController c, String hint) => TextFormField(
    controller: c,
    decoration: InputDecoration(
      hintText: hint,
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
