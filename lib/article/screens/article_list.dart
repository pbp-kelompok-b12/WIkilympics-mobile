import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/article/screens/article_form.dart';
import 'package:wikilympics/screens/login.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/article/widgets/article_card.dart'; 
import 'package:wikilympics/article/widgets/trending_card.dart'; 
import 'package:wikilympics/article/screens/article_detail.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kBgGrey = const Color(0xFFF9F9F9);
  final Color kAccentLime = const Color(0xFFD9E74C);

  bool _isAdmin = false;

  // Filter
  String _searchQuery = "";
  List<String> _selectedCategories = [];

  final List<String> _categoryOptions = [
    'Athletics', 'Archery', 'Artistic Gymnastics', 'Artistic Swimming',
    'Badminton', 'Baseball Softball', 'Basketball', 'Beach Volleyball',
    'Boxing', 'Canoe Slalom', 'Cycling Road', 'Diving', 'Fencing',
    'Football', 'Handball', 'Hockey', 'Judo', 'Karate', 'Marathon Swimming',
    'Rowing', 'Rhythmic Gymnastics', 'Sailing', 'Shooting', 'Swimming',
    'Table Tennis', 'Taekwondo', 'Trampoline Gymnastics', 'Triathlon',
    'Water Polo', 'Weightlifting', 'Wrestling',
  ];

  IconData getSportIcon(String sportName) {
    String sport = sportName.toLowerCase().replaceAll(" ", "_");

    if (['football', 'basketball', 'baseball_softball', 'beach_volleyball', 
         'handball', 'hockey', 'table_tennis', 'water_polo', 'badminton'].contains(sport)) {
      return Icons.sports_soccer;
    }
    
    if (['archery', 'shooting', 'fencing'].contains(sport)) {
      return Icons.ads_click;
    }

    if (['swimming', 'artistic_swimming', 'marathon_swimming', 'diving', 
         'rowing', 'sailing', 'canoe_slalom'].contains(sport)) {
      return Icons.waves;
    }

    if (['boxing', 'judo', 'karate', 'taekwondo', 'wrestling'].contains(sport)) {
      return Icons.sports_martial_arts;
    }

    if (['athletics', 'cycling_road', 'triathlon'].contains(sport)) {
      return Icons.directions_run;
    }

    if (['artistic_gymnastics', 'rhythmic_gymnastics', 'trampoline_gymnastics'].contains(sport)) {
      return Icons.accessibility_new;
    }

    if (['weightlifting'].contains(sport)) {
      return Icons.fitness_center;
    }

    return Icons.sports;
  }

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      final response = await request.get("http://127.0.0.1:8000/auth/status/");
      if (mounted) {
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      }
    }
  }

  Future<List<ArticleEntry>> fetchArticles(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/article/json/');
    List<ArticleEntry> listArticles = [];
    for (var d in response) {
      if (d != null) {
        listArticles.add(ArticleEntry.fromJson(d));
      }
    }
    return listArticles;
  }

  // Filter logic
  List<ArticleEntry> _applyFilters(List<ArticleEntry> allArticles) {
    return allArticles.where((article) {
      final title = article.title.toLowerCase();
      if (!title.contains(_searchQuery)) return false;

      if (_selectedCategories.isNotEmpty) {
        String rawCat = article.category.toString().replaceAll("_", " ").toLowerCase();
        bool catMatch = _selectedCategories.any((selected) =>
            rawCat == selected.toLowerCase());
        if (!catMatch) return false;
      }
      return true;
    }).toList();
  }

  void _showFilterModal() {
    List<String> tempSelected = List.from(_selectedCategories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // Handle Bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4, width: 40,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  Text("Filter by Category", 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryNavy)),
                  const Divider(),
                  
                  // Daftar Kategori
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: _categoryOptions.length,
                      itemBuilder: (context, index) {
                        final cat = _categoryOptions[index];
                        final isSelected = tempSelected.contains(cat);
                        
                        return CheckboxListTile(
                          secondary: Icon(getSportIcon(cat), color: kPrimaryNavy),
                          title: Text(cat, style: GoogleFonts.poppins(fontSize: 14)),
                          value: isSelected,
                          activeColor: kPrimaryNavy,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelected.add(cat);
                              } else {
                                tempSelected.remove(cat);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              // Simpan perubahan ke State utama aplikasi
                              setState(() => _selectedCategories = tempSelected);
                              Navigator.pop(context);
                            },
                            child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        title: Image.asset('assets/wikilympics_banner.png', height: 60, fit: BoxFit.contain),
        backgroundColor: kBgGrey,
        iconTheme: IconThemeData(color: kPrimaryNavy),
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: _isAdmin
        ? FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const ArticleFormPage()));
              setState(() {
                fetchArticles(request);
              });
            },
            label: Text("ADD ARTICLE", style: TextStyle(color: kPrimaryNavy, fontWeight: FontWeight.bold)),
            icon: Icon(Icons.add, color: kPrimaryNavy),
            backgroundColor: kAccentLime,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )
        : null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: kPrimaryNavy, size: 20),
                            hintText: "Search articles...",
                            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: kPrimaryNavy, borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.tune, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_selectedCategories.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._selectedCategories.map((e) => _buildChip(e)),
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategories.clear()),
                          child: Text(" Clear All", style: TextStyle(color: kPrimaryNavy, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<ArticleEntry>>(
              future: fetchArticles(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No articles yet.'));

                final filteredAll = _applyFilters(snapshot.data!);
                
                final trendingList = filteredAll.where((a) => a.likes >= 7).toList();
                final regularList = filteredAll.where((a) => a.likes < 7).toList();

                if (filteredAll.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                        Text("No articles match your filters.", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    // Trending list
                    if (trendingList.isNotEmpty) ...[
                      _buildSectionTitle("Trending Now", Icons.whatshot, Colors.orange),
                      SizedBox(
                        height: 165,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          scrollDirection: Axis.horizontal,
                          itemCount: trendingList.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 280,
                              child: TrendingCard(
                                article: trendingList[index],
                                onTap: () => _handleNavigation(request, trendingList[index]),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Article list
                    _buildSectionTitle("Olympic Articles", Icons.article_outlined, kPrimaryNavy),
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAll.length,
                      itemBuilder: (context, index) => ArticleCard(
                        article: filteredAll[index],
                        onTap: () => _handleNavigation(request, filteredAll[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimaryNavy)),
        ],
      ),
    );
  }

  void _handleNavigation(CookieRequest request, ArticleEntry article) async{
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article)));
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article))
      );
      
      // KETIKA KEMBALI DARI DETAIL, REFRESH LIST
      if (mounted) {
        setState(() {
          // Ini akan memicu FutureBuilder untuk memanggil fetchArticles lagi
        });
      }
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimaryNavy.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryNavy.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getSportIcon(label), size: 14, color: kPrimaryNavy),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimaryNavy)),
        ],
      ),
    );
  }
  
}