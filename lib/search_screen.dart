import 'package:flutter/material.dart';
import 'listing_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialTab, this.initialCategory, this.recentOnly = false});
  final String? initialTab;
  final String? initialCategory;
  final bool recentOnly;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';
  final String _selectedCountry = 'All';
  final List<String> _categories = ['All', 'IT', 'Construction', 'Healthcare', 'Education', 'Retail', 'Hospitality', 'Agriculture', 'Finance', 'Other']; // ignore: unused_field
  final List<String> _countries = ['All', 'Saint Vincent', 'Barbados', 'Trinidad', 'Jamaica', 'Grenada', 'Saint Lucia', 'Antigua', 'Dominica']; // ignore: unused_field
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _gigs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory != '') {
      _selectedCategory = widget.initialCategory!;
    }
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab == 'gigs' ? 1 : 0);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      final jobs = widget.recentOnly
          ? await Supabase.instance.client
              .from('listings').select('*, profiles(avg_rating, rating_count)').eq('type', 'Employer')
              .gte('created_at', cutoff)
              .order('featured', ascending: false)
        .order('is_premium', ascending: false)
        .order('created_at', ascending: false)
          : await Supabase.instance.client
              .from('listings').select('*, profiles(avg_rating, rating_count)').eq('type', 'Employer')
              .order('featured', ascending: false)
        .order('is_premium', ascending: false)
        .order('created_at', ascending: false);
      final gigs = widget.recentOnly
        ? await Supabase.instance.client
            .from('listings').select('*, profiles(avg_rating, rating_count)').eq('type', 'Worker / Freelancer')
            .gte('created_at', cutoff)
            .order('featured', ascending: false)
        .order('is_premium', ascending: false)
        .order('created_at', ascending: false)
        : await Supabase.instance.client
            .from('listings').select('*, profiles(avg_rating, rating_count)').eq('type', 'Worker / Freelancer')
            .order('featured', ascending: false)
        .order('is_premium', ascending: false)
        .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
        _jobs = List<Map<String, dynamic>>.from(jobs);
        _gigs = List<Map<String, dynamic>>.from(gigs);
        _loading = false;
      });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredJobs {
    final q = _query.toLowerCase();
    return _jobs.where((j) =>
      (q.isEmpty ||
        (j['title'] ?? '').toLowerCase().contains(q) ||
        (j['company'] ?? '').toLowerCase().contains(q) ||
        (j['location'] ?? '').toLowerCase().contains(q)) &&
      (_selectedCategory == 'All' || (j['category'] ?? '') == _selectedCategory) &&
      (_selectedCountry == 'All' || (j['location'] ?? '').contains(_selectedCountry))
    ).toList();
  }

  List<Map<String, dynamic>> get _filteredGigs {
    final q = _query.toLowerCase();
    return _gigs.where((g) =>
      (q.isEmpty ||
        (g['title'] ?? '').toLowerCase().contains(q) ||
        (g['company'] ?? '').toLowerCase().contains(q)) &&
      (_selectedCategory == 'All' || (g['category'] ?? '') == _selectedCategory)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search jobs, gigs...',
                      hintStyle: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF5B8DB8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF5B8DB8),
                  unselectedLabelColor: const Color(0xFF9E9E9E),
                  indicatorColor: const Color(0xFF5B8DB8),
                  tabs: const [Tab(text: 'Jobs'), Tab(text: 'Services')],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: _fetchAll,
                        child: _filteredJobs.isEmpty
                            ? const Center(child: Text('No jobs found', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredJobs.length,
                                itemBuilder: (ctx, i) => _buildJobCard(_filteredJobs[i]),
                              ),
                      ),
                      RefreshIndicator(
                        onRefresh: _fetchAll,
                        child: _filteredGigs.isEmpty
                            ? const Center(child: Text('No services found', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredGigs.length,
                                itemBuilder: (ctx, i) => _buildGigCard(_filteredGigs[i]),
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> j) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: j))),
    child: Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEFEFE8)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(j['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              if (j['featured'] == true)
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 11, color: Colors.white),
                      SizedBox(width: 3),
                      Text('Featured', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
      const SizedBox(height: 4),
      Text(j['company'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFB2BEC3)),
        const SizedBox(width: 3),
        Text(j['location'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFB2BEC3))),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF5B8DB8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(j['job_type'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600))),
      ]),
              if ((j['profiles']?['avg_rating'] ?? 0) > 0) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                  const SizedBox(width: 3),
                  Text('${(j['profiles']['avg_rating'] as num).toStringAsFixed(1)} (${j['profiles']['rating_count']} reviews)', style: const TextStyle(fontSize: 11, color: Color(0xFF636E72))),
                ]),
              ),
      const SizedBox(height: 6),
      Text(j['salary'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: g))),
    child: Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEFEFE8)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(g['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              if (g['featured'] == true)
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 11, color: Colors.white),
                      SizedBox(width: 3),
                      Text('Featured', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
      const SizedBox(height: 4),
      Text(g['company'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A843)),
        const SizedBox(width: 3),
        Text(g['job_type'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            if ((g['profiles']?['avg_rating'] ?? 0) > 0) Row(children: [const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)), const SizedBox(width: 3), Text('${(g['profiles']['avg_rating'] as num).toStringAsFixed(1)} (${g['profiles']['rating_count']} reviews)', style: const TextStyle(fontSize: 11, color: Color(0xFF636E72)))]),
        const Spacer(),
        Text(g['salary'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B8DB8))),
      ]),
    ]),
  ));
}
