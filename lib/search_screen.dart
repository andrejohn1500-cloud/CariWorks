import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});
  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String,String>> jobs = const [
    {'title':'Web Developer','company':'TechSVG Ltd','location':'Kingstown, SVG','type':'Full-Time','salary':r'$2,500/mo'},
    {'title':'Electrician','company':'PowerPro TT','location':'Port of Spain, TT','type':'Contract','salary':r'$800/wk'},
    {'title':'Marketing Officer','company':'Caribbean Brands','location':'Bridgetown, BB','type':'Full-Time','salary':r'$3,000/mo'},
    {'title':'Nurse','company':'Milton Cato Hospital','location':'Kingstown, SVG','type':'Full-Time','salary':r'$2,000/mo'},
    {'title':'Teacher','company':'SVG Grammar School','location':'Kingstown, SVG','type':'Full-Time','salary':r'$2,200/mo'},
  ];

  final List<Map<String,String>> gigs = const [
    {'title':'Logo Design','seller':'Marcus D.','price':r'From $50','rating':'4.9'},
    {'title':'Roof Repair','seller':'Roy Construction','price':r'From $200','rating':'5.0'},
    {'title':'CXC Maths Tutoring','seller':'Miss Clarke','price':r'From $30/hr','rating':'4.8'},
    {'title':'Photography','seller':'Shawn Pics','price':r'From $100','rating':'4.7'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String,String>> get filteredJobs {
    if (_query.isEmpty) return jobs;
    final q = _query.toLowerCase();
    return jobs.where((j) =>
      j['title']!.toLowerCase().contains(q) ||
      j['company']!.toLowerCase().contains(q) ||
      j['location']!.toLowerCase().contains(q)
    ).toList();
  }

  List<Map<String,String>> get filteredGigs {
    if (_query.isEmpty) return gigs;
    final q = _query.toLowerCase();
    return gigs.where((g) =>
      g['title']!.toLowerCase().contains(q) ||
      g['seller']!.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  tabs: const [Tab(text: 'Jobs'), Tab(text: 'Gigs')],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                filteredJobs.isEmpty
                  ? const Center(child: Text('No jobs found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredJobs.length,
                      itemBuilder: (ctx, i) {
                        final j = filteredJobs[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEFE8E4)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(j['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                              const SizedBox(height: 4),
                              Text(j['company']!, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                              const SizedBox(height: 8),
                              Row(children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFB2BEC3)),
                                const SizedBox(width: 3),
                                Text(j['location']!, style: const TextStyle(fontSize: 12, color: Color(0xFFB2BEC3))),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF5B8DB8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(j['type']!, style: const TextStyle(fontSize: 11, color: Color(0xFF5B8DB8), fontWeight: FontWeight.w600)),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Text(j['salary']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                            ],
                          ),
                        );
                      },
                    ),
                filteredGigs.isEmpty
                  ? const Center(child: Text('No gigs found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredGigs.length,
                      itemBuilder: (ctx, i) {
                        final g = filteredGigs[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEFE8E4)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))],
                          ),
                          child: Row(children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                                const SizedBox(height: 4),
                                Text(g['seller']!, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD443)),
                                  const SizedBox(width: 3),
                                  Text(g['rating']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            )),
                            Text(g['price']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B8DB8))),
                          ]),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
