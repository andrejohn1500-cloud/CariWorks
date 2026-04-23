import 'package:flutter/material.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeFeedTab(),
    SearchTab(),
    PostTab(),
    MessagesTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        elevation: 8,
        indicatorColor: const Color(0xFF5B8DB8).withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF5B8DB8)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search, color: Color(0xFF5B8DB8)), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF5B8DB8)), label: 'Post'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF5B8DB8)), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF5B8DB8)), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeFeedTab extends StatelessWidget {
  const HomeFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            floating: true,
            snap: true,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xFF5B8DB8), borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('CJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ),
                const SizedBox(width: 10),
                const Text('CariWorks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2D3436)), onPressed: () {}),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Browse Categories'),
                  const SizedBox(height: 14),
                  _buildCategories(),
                  const SizedBox(height: 24),
                  _buildUrgentBanner(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Latest Jobs'),
                  const SizedBox(height: 14),
                  _buildJobCard(title: 'Web Developer', company: 'TechSVG Ltd', location: 'Kingstown, SVG', type: 'Full-Time', salary: r'$2,500/mo', color: const Color(0xFF5B8DB8), icon: Icons.code_rounded),
                  const SizedBox(height: 12),
                  _buildJobCard(title: 'Electrician', company: 'PowerPro TT', location: 'Port of Spain, TT', type: 'Contract', salary: r'$800/wk', color: const Color(0xFFD4A843), icon: Icons.electrical_services_rounded),
                  const SizedBox(height: 12),
                  _buildJobCard(title: 'Marketing Officer', company: 'Caribbean Brands', location: 'Bridgetown, BB', type: 'Full-Time', salary: r'$3,000/mo', color: const Color(0xFF55A375), icon: Icons.campaign_rounded),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Featured Gigs'),
                  const SizedBox(height: 14),
                  _buildGigCard(title: 'Professional Logo Design', seller: 'Marcus D.', price: r'From $50', rating: '4.9', reviews: '34', color: const Color(0xFF5B8DB8), icon: Icons.brush_rounded),
                  const SizedBox(height: 12),
                  _buildGigCard(title: 'Roof Repair & Waterproofing', seller: 'Roy Construction', price: r'From $200', rating: '5.0', reviews: '18', color: const Color(0xFFD4A843), icon: Icons.roofing_rounded),
                  const SizedBox(height: 12),
                  _buildGigCard(title: 'CXC Maths Tutoring', seller: 'Miss Clarke', price: r'From $30/hr', rating: '4.8', reviews: '52', color: const Color(0xFF55A375), icon: Icons.school_rounded),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: const Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.search_rounded, color: Color(0xFF5B8DB8), size: 22),
          SizedBox(width: 10),
          Text('Search jobs, gigs, companies...', style: TextStyle(color: Color(0xFFB2BEC3), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        Text('See all', style: const TextStyle(fontSize: 14, color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCategories() {
    final cats = [
      {'icon': Icons.handyman_outlined, 'label': 'Trades', 'color': const Color(0xFFD4A843)},
      {'icon': Icons.code_rounded, 'label': 'Tech', 'color': const Color(0xFF5B8DB8)},
      {'icon': Icons.brush_rounded, 'label': 'Creative', 'color': const Color(0xFFD66A5E)},
      {'icon': Icons.school_rounded, 'label': 'Education', 'color': const Color(0xFF55A375)},
      {'icon': Icons.campaign_rounded, 'label': 'Marketing', 'color': const Color(0xFF9B59B6)},
      {'icon': Icons.restaurant_rounded, 'label': 'Food', 'color': const Color(0xFFE67E22)},
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, i) {
          final cat = cats[i];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(cat['label'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF636E72), fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUrgentBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5B8DB8), Color(0xFF4A7BA7)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Urgently Hiring!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('12 new jobs posted in SVG today', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildJobCard({required String title, required String company, required String location, required String type, required String salary, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                const SizedBox(height: 3),
                Text(company, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFB2BEC3)),
                    const SizedBox(width: 3),
                    Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFFB2BEC3))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(type, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGigCard({required String title, required String seller, required String price, required String rating, required String reviews, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                const SizedBox(height: 3),
                Text(seller, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A843)),
                    const SizedBox(width: 3),
                    Text(rating, style: const TextStyle(fontSize: 12, color: Color(0xFF2D3436), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Text('($reviews reviews)', style: const TextStyle(fontSize: 12, color: Color(0xFFB2BEC3))),
                  ],
                ),
              ],
            ),
          ),
          Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

