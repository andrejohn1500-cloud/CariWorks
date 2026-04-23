import 'package:flutter/material.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});
  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  String? _selectedType;

  void _continue() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account type to continue.'), backgroundColor: Color(0xFFD66A5E)),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('I am a...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              const SizedBox(height: 8),
              const Text('Choose how you want to use Cari-Jobs&Gigs. You can always change this later.', style: TextStyle(fontSize: 15, color: Color(0xFF636E72), height: 1.5)),
              const SizedBox(height: 32),
              _buildTypeCard(type: 'seeker', icon: Icons.person_search_outlined, title: 'Job Seeker', subtitle: 'I am looking for jobs, gigs or freelance opportunities in the Caribbean.', color: const Color(0xFF5B8DB8)),
              const SizedBox(height: 14),
              _buildTypeCard(type: 'employer', icon: Icons.business_center_outlined, title: 'Employer', subtitle: 'I am hiring staff, posting jobs or looking for freelancers for my business.', color: const Color(0xFFD4A843)),
              const SizedBox(height: 14),
              _buildTypeCard(type: 'both', icon: Icons.swap_horiz_rounded, title: 'Both', subtitle: 'I am looking for work and also hiring or posting gigs at the same time.', color: const Color(0xFF55A375)),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DB8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({required String type, required IconData icon, required String title, required String subtitle, required Color color}) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? color : const Color(0xFFE8E4DE), width: isSelected ? 2 : 1.5),
          boxShadow: [BoxShadow(color: isSelected ? color.withOpacity(0.12) : Colors.black.withOpacity(0.04), blurRadius: isSelected ? 16 : 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isSelected ? color : const Color(0xFF2D3436))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: isSelected ? color : const Color(0xFFE8E4DE), width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }
}
