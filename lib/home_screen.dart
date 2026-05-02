import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'messages_screen.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'listing_detail_screen.dart';

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
        indicatorColor: const Color(0xFF5B8DB8).withValues(alpha: 0.15),
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
            .eq('type', 'Worker / Freelancer')
            .eq('featured', true)
            .order('created_at', ascending: false)
            .limit(10);
      if (mounted) setState(() { _jobs = List<Map<String, dynamic>>.from(jobs); _gigs = List<Map<String, dynamic>>.from(gigs); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchListings,
          color: const Color(0xFF5B8DB8),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildUrgentBanner()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: _buildOpportunities()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5B8DB8), Color(0xFF3A6B96)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('CW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CariWorks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2B3C))),
              Text('Caribbean Jobs & Services', style: TextStyle(fontSize: 12, color: Color(0xFF6B7C8D))),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF5B8DB8)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notifications coming soon!"), backgroundColor: Color(0xFF5B8DB8)))),
      ],
    ),
  );

  Widget _buildSearchBar() => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF5B8DB8), size: 22),
          const SizedBox(width: 12),
          const Expanded(child: Text('Search jobs, gigs, companies...', style: TextStyle(color: Color(0xFFADB8C3), fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Color(0x195B8DB8), borderRadius: BorderRadius.circular(8)),
            child: const Text('SVG', style: TextStyle(color: Color(0xFF5B8DB8), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );

  Widget _buildUrgentBanner() => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen(initialTab: 'jobs', recentOnly: true))),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C5F8A), Color(0xFF5B8DB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Color(0x665B8DB8), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Urgently Hiring!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                SizedBox(height: 2),
                Text('Jobs & services posted in last 24 hours', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    ),
  );

  Widget _buildCategories() {
    final cats = <(String, IconData, Color)>[
      ('Trades', Icons.construction_rounded, const Color(0xFFE8833A)),
      ('Tech', Icons.computer_rounded, const Color(0xFF5B8DB8)),
      ('Creative', Icons.palette_rounded, const Color(0xFFB85C9E)),
      ('Education', Icons.school_rounded, const Color(0xFF4CAF7D)),
      ('Marketing', Icons.campaign_rounded, const Color(0xFFE0B840)),
      ('Finance', Icons.account_balance_rounded, const Color(0xFF6B7FDB)),
      ('Health', Icons.favorite_rounded, const Color(0xFFE85B5B)),
      ('Hospitality', Icons.restaurant_rounded, const Color(0xFF42A5A0)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              const Expanded(child: Text('Browse Categories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A2B3C)))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                child: const Text('See all', style: TextStyle(color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 94,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final (label, icon, color) = cats[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialCategory: label))),
                child: Container(
                  width: 74,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 8)],
                        ),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      const SizedBox(height: 6),
                      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4A5568)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunities() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Text('Latest Opportunities', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A2B3C))),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: _tabChip('Jobs', 0)),
              Expanded(child: _tabChip('Services', 1)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (_loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF5B8DB8))),
        )
      else if (_activeTab == 0) ...[
        if (_jobs.isEmpty)
          _buildEmptyState('No jobs posted yet.\nBe the first to post!', Icons.work_outline_rounded)
        else
          ..._jobs.take(5).map((j) => _buildJobCard(j)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen(initialTab: 'jobs'))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF5B8DB8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('See All Jobs', style: TextStyle(color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600)),
          ),
        ),
      ] else ...[
        if (_gigs.isEmpty)
          _buildEmptyState('No services posted yet.\nBe the first!', Icons.construction_outlined)
        else
          ..._gigs.take(5).map((g) => _buildGigCard(g)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen(initialTab: 'gigs'))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF5B8DB8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('See All Services', style: TextStyle(color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ],
  );

  Widget _tabChip(String label, int index) => GestureDetector(
    onTap: () => setState(() => _activeTab = index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: _activeTab == index ? const Color(0xFF5B8DB8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: _activeTab == index ? Colors.white : const Color(0xFF8395A7), fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    ),
  );

  Widget _buildEmptyState(String message, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFEEF2F7), borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, size: 32, color: const Color(0xFFB0BEC5)),
          ),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: Color(0xFF9AACBA), fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Widget _buildJobCard(Map<String, dynamic> j) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: j))),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(j['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2B3C)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Color(0x195B8DB8), borderRadius: BorderRadius.circular(8)),
                child: const Text('Job', style: TextStyle(color: Color(0xFF5B8DB8), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(j['company'] ?? '', style: const TextStyle(color: Color(0xFF707D89), fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF5B8DB8)),
              const SizedBox(width: 4),
              Expanded(child: Text((j['location'] ?? 'SVG').toString(), style: const TextStyle(color: Color(0xFF8EA0AE), fontSize: 12), overflow: TextOverflow.ellipsis)),
              if ((j['salary'] ?? '').toString().isNotEmpty)
                Text(j['salary'].toString(), style: const TextStyle(color: Color(0xFF2C5F8A), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildGigCard(Map<String, dynamic> g) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: g))),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: g['featured'] == true ? Border.all(color: Color(0x445B8DB8)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(g['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2B3C)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (g['featured'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF5B8DB8), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(g['company'] ?? '', style: const TextStyle(color: Color(0xFF707D89), fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF5B8DB8)),
              const SizedBox(width: 4),
              Expanded(child: Text((g['location'] ?? 'SVG').toString(), style: const TextStyle(color: Color(0xFF8EA0AE), fontSize: 12), overflow: TextOverflow.ellipsis)),
              if ((g['salary'] ?? '').toString().isNotEmpty)
                Text(g['salary'].toString(), style: const TextStyle(color: Color(0xFF2C5F8A), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    ),
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
