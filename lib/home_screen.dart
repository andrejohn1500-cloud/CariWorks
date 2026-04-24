import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'messages_screen.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
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
      backgroundColor: const Color(0xFFFFFAF8),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        shadowColor: Colors.black12,
        elevation: 8,
        indicatorColor: const Color(0xFF5B8DB8).withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF5B8DB8)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search, color: Color(0xFF5B8DB8)), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF5B8DB8)), label: 'Post'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF5B8DB8)), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF5B8DB8)), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeFeedTab extends StatefulWidget {
  const HomeFeedTab({super.key});
  @override
  State<HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends State<HomeFeedTab> {
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _gigs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      final jobs = await Supabase.instance.client
          .from('listings')
          .select()
          .eq('type', 'Job')
          .order('created_at', ascending: false)
          .limit(5);
      final gigs = await Supabase.instance.client
          .from('listings')
          .select()
          .eq('type', 'Gig')
          .order('created_at', ascending: false)
          .limit(5);
      if (mounted) setState(() { _jobs = List<Map<String, dynamic>>.from(jobs); _gigs = List<Map<String, dynamic>>.from(gigs); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchListings,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true,
              snap: true,
              elevation: 0,
              title: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF5B8DB8), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('CW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                const SizedBox(width: 10),
                const Text('CariWorks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              ]),
              actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2D3436)), onPressed: () {}), const SizedBox(width: 4)],
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
                    if (_loading) const Center(child: CircularProgressIndicator())
                    else if (_jobs.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No jobs posted yet. Be the first!', style: TextStyle(color: Colors.grey))))
                    else ..._jobs.map((j) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildJobCard(j))),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Featured Gigs'),
                    const SizedBox(height: 14),
                    if (_loading) const SizedBox()
                    else if (_gigs.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No gigs posted yet.', style: TextStyle(color: Colors.grey))))
                    else ..._gigs.map((g) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildGigCard(g))),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() => Container(
    height: 52,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: const Row(children: [SizedBox(width: 16), Icon(Icons.search_rounded, color: Color(0xFF5B8DB8), size: 22), SizedBox(width: 10), Text('Search jobs, gigs, companies...', style: TextStyle(color: Color(0xFFB2BEC3), fontSize: 15))]),
  );

  Widget _buildSectionHeader(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
      Text('See all', style: const TextStyle(fontSize: 14, color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildCategories() {
    final cats = [
      {'icon': Symbols.handyman, 'label': 'Trades', 'color': const Color(0xFFD4A843)},
      {'icon': Icons.code_rounded, 'label': 'Tech', 'color': const Color(0xFF5B8DB8)},
      {'icon': Symbols.brush, 'label': 'Creative', 'color': const Color(0xFFD66A5E)},
      {'icon': Symbols.school, 'label': 'Education', 'color': const Color(0xFF55A375)},
      {'icon': Symbols.campaign, 'label': 'Marketing', 'color': const Color(0xFF9B59B6)},
      {'icon': Symbols.restaurant, 'label': 'Food', 'color': const Color(0xFFE67E22)},
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
            child: Column(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: (cat['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(16)), child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 26)),
              const SizedBox(height: 6),
              Text(cat['label'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF636E72), fontWeight: FontWeight.w500)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildUrgentBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5B8DB8), Color(0xFF4A7BA7)]), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      const Icon(Symbols.bolt, color: Colors.white, size: 28),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Urgently Hiring!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text('New jobs posted in SVG today', style: TextStyle(color: Colors.white70, fontSize: 13)),
      ])),
      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
    ]),
  );

  Widget _buildJobCard(Map<String, dynamic> j) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF5B8DB8).withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.business_center_rounded, color: Color(0xFF5B8DB8), size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(j['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        const SizedBox(height: 3),
        Text(j['company'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFB2BEC3)), const SizedBox(width: 3), Text(j['location'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFB2BEC3)))]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF5B8DB8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(j['job_type'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600))),
        const SizedBox(height: 8),
        Text(j['salary'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
      ]),
    ]),
  );

  Widget _buildGigCard(Map<String, dynamic> g) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8E4DE), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFD4A843).withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Symbols.brush, color: Color(0xFFD4A843), size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(g['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        const SizedBox(height: 3),
        Text(g['company'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A843)), const SizedBox(width: 3), Text(g['job_type'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF2D3436), fontWeight: FontWeight.w600))]),
      ])),
      Text(g['salary'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4A843))),
    ]),
  );
}

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context) => SearchScreen();
}

class PostTab extends StatelessWidget {
  const PostTab({super.key});
  @override
  Widget build(BuildContext context) => const PostScreen();
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});
  @override
  Widget build(BuildContext context) => const MessagesScreen();
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
