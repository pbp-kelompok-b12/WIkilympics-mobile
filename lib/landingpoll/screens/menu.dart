import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/article/widgets/article_card.dart';
import 'package:wikilympics/article/screens/article_detail.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// polling
import '../models/poll_model.dart';
import '../widgets/poll_service.dart';

// drawer
import '../../widgets/left_drawer.dart';

// login
import 'package:wikilympics/screens/login.dart';

// navbar pages
import 'forum_page.dart';
import 'profile_page.dart';

// modul punya temen temen
import '../widgets/popular_sport_card.dart';
import '../widgets/athlete_highlight_card.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/latest_article_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PollQuestion? _poll;
  bool _showPopup = false;
  bool _hasVoted = false;
  bool _alreadyLoad = false;

  int _selectedIndex = 0;

  final List<Widget> _navbarPages = const [
    Placeholder(), // home landing
    ForumPage(),
    Placeholder(), // ini tidak dipakai karena menu buka bottom sheet
    ProfilePage(),
  ];

  // ======================================================
  // LOAD POLL
  // ======================================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_alreadyLoad) {
      _alreadyLoad = true;
      _loadPoll();
    }
  }

  Future<void> _loadPoll() async {
    final request = context.read<CookieRequest>();
    try {
      final data = await PollService.fetchPolls(request);
      if (data.isNotEmpty) {
        final poll = data[Random().nextInt(data.length)];
        setState(() {
          _poll = poll;
          _showPopup = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _vote(int optionId) async {
    if (_hasVoted) return;

    final request = context.read<CookieRequest>();
    setState(() => _hasVoted = true);

    await PollService.vote(request, optionId);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showPopup = false);
    });
  }

// ======================================================
  // BOTTOM SHEET MENU (FIXED OVERFLOW)
  // ======================================================
  void _openMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tambahkan ini agar sheet menyesuaikan konten
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        // WRAP DENGAN SingleChildScrollView AGAR BISA SCROLL
        return SingleChildScrollView(
          child: Padding(
            // Tambahkan padding bottom menyesuaikan viewInsets (opsional, untuk safety)
            padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Menu",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01203F),
                  ),
                ),
                const SizedBox(height: 15),

                // ============================================
                //  DAFTAR ITEM
                // ============================================

                _menuItem(
                  icon: Icons.sports_basketball_outlined,
                  label: "Sports",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => SportsPage()));
                  },
                ),

                _menuItem(
                  icon: Icons.article_outlined,
                  label: "Article",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ArticlePage()));
                  },
                ),

                _menuItem(
                  icon: Icons.event_outlined,
                  label: "Olympic Events",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _menuItem(
                  icon: Icons.person_search_outlined,
                  label: "Athletes",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF01203F), size: 26),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF01203F),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ======================================================
  // NAVBAR HANDLER
  // ======================================================
  void _onNavTap(int index) {
    if (index == 2) {
      _openMenuSheet(context);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  // ======================================================
  // BUILD UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final username = request.jsonData['username'];

    final greeting = username == null ? "Hello" : "Hello, $username";

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4E5),
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: AppBar(backgroundColor: Colors.white, elevation: 0),
      ),
      drawer: const LeftDrawer(),

      body: Stack(
        children: [
          _selectedIndex == 0
              ? _buildLandingContent(request)
              : _navbarPages[_selectedIndex],

          if (_showPopup && _poll != null) _buildPopup(greeting),
        ],
      ),

      // custom navbar
      bottomNavigationBar: _buildCustomBottomNavbar(),
    );
  }

  // ======================================================
  // HOME LANDING
  // ======================================================
  Widget _buildLandingContent(CookieRequest request) {
    final username = request.jsonData['username'];

    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),

                Expanded(
                  child: Center(
                    child: Image.asset("assets/wikilympics_banner.png", height: 40),
                  ),
                ),

                username == null
                    ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01203F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                  ),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
                    : Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01203F),
                  ),
                ),
              ],
            ),
          ),

          // HERO IMAGE
          SizedBox(
            width: double.infinity,
            child: Image.asset("assets/hero_wikilympics.jpg", fit: BoxFit.cover),
          ),

          const SizedBox(height: 16),

          // ===== POPULAR SPORTS SECTION =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Popular Sports",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01203F),
                  ),
                ),

                const SizedBox(height: 12),

                PopularSportCard(
                  rank: 1,
                  sportName: "Basketball",
                  firstYear: "1896",
                  imageUrl: "https://via.placeholder.com/150",
                ),

                PopularSportCard(
                  rank: 2,
                  sportName: "Football",
                  firstYear: "1863",
                  imageUrl: "https://via.placeholder.com/150",
                ),

                PopularSportCard(
                  rank: 3,
                  sportName: "Tennis",
                  firstYear: "1873",
                  imageUrl: "https://via.placeholder.com/150",
                ),

                const SizedBox(height: 8),

                // GANTI DENGAN INI
                Container(
                  width: double.infinity, // Agar lebarnya memenuhi layar
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background putih
                    borderRadius: BorderRadius.circular(20), // Radius membulat
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // Bayangan tipis
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Tambahkan aksi di sini nanti
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "SEE ALL SPORTS",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                // Sesuaikan kode warna ini dengan warna hijau/kuning di Figma kamu
                                color: Color(0xFFC8DB2C),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded, // Pakai yang rounded biar lebih halus
                              color: Color(0xFFC8DB2C), // Samakan warnanya
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

// ===== ATHLETES HIGHLIGHT =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Athletes Highlight",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01203F),
                  ),
                ),
                const SizedBox(height: 12),

                AthleteHighlightCard(
                  rank: 1,
                  athleteName: "Verstappen",
                  sportName: "Handball",
                  country: "Netherlands",
                  onTap: () {
                    // nanti sambung ke modul athlete detail
                  },
                ),

                AthleteHighlightCard(
                  rank: 2,
                  athleteName: "Verstappen",
                  sportName: "Archery",
                  country: "Netherlands",
                ),

                AthleteHighlightCard(
                  rank: 3,
                  athleteName: "Verstappen",
                  sportName: "Basketball",
                  country: "Netherlands",
                ),

                const SizedBox(height: 8),

                // SEE ALL ATHLETES
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // NAVIGATE KE MODUL ATHLETES TEMAN
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "SEE ALL ATHLETES",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC8DB2C),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFC8DB2C),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ===== UPCOMING EVENTS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER JUDUL (Disesuaikan Style Figma yang besar & biru)
                Text(
                  "Upcoming Events",
                  style: GoogleFonts.poppins(
                    fontSize: 22, // Diperbesar
                    fontWeight: FontWeight.w700, // Sangat tebal
                    color: const Color(0xFF155F90), // Biru agak terang sesuai header Figma
                  ),
                ),
                const SizedBox(height: 16),

                // CARD 1 (Contoh Data Real)
                UpcomingEventCard(
                  // Gunakan Image.network untuk test, atau asset jika ada
                  image: Image.network(
                    "https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Minnesota_Wild.svg/1200px-Minnesota_Wild.svg.png",
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                  ),
                  title: "Titans Post Elite PFF Tackling in 2019",
                  author: "Bob Dylan",
                  date: "Mar. 05, 2020",
                  onTap: () {
                    // nanti sambung ke modul event temen
                  },
                ),

                // GARIS PEMBATAS TIPIS (Optional, biar rapi)
                Divider(color: Colors.grey[300], height: 20),

                // CARD 2 (Duplikasi biar terlihat list)
                UpcomingEventCard(
                  image: Image.network(
                    "https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Minnesota_Wild.svg/1200px-Minnesota_Wild.svg.png",
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                  ),
                  title: "Wild post Elite PFF Tackling in 2024",
                  author: "Bob Dylan",
                  date: "Mar. 10, 2024",
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ===== LATEST ARTICLES =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latest Articles",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF155F90),
                  ),
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<ArticleEntry>>(
                  future: fetchArticles(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No articles available");
                    }

                    final articles = snapshot.data!.take(2).toList();

                    return Column(
                      children: articles.map((article) {
                        return LatestArticleCard(
                          imageUrl: article.thumbnail.isNotEmpty
                              ? article.thumbnail
                              : "https://picsum.photos/600",

                          title: article.title,

                          // Karena model TIDAK punya author → aman pakai placeholder
                          author: article.category,

                          // created = DateTime → HARUS diubah ke String
                          date: "${article.created.day.toString().padLeft(2, '0')} "
                              "${article.created.month.toString().padLeft(2, '0')} "
                              "${article.created.year}",

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailPage(article: article),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          _section("Forum & Reviews"),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF01203F),
        ),
      ),
    );
  }

  // ======================================================
  // POLLING POPUP
  // ======================================================
  Widget _buildPopup(String greeting) {
    final poll = _poll!;

    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showPopup = false),
                ),
              ),

              Text(
                greeting,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF01203F),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                poll.questionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF155F90),
                ),
              ),
              const SizedBox(height: 14),

              ...poll.options.map(
                    (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01203F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _hasVoted ? null : () => _vote(o.id),
                    child: Text(o.optionText),
                  ),
                ),
              ),

              if (_hasVoted)
                Text(
                  "Terima kasih sudah memilih!",
                  style: GoogleFonts.poppins(color: Colors.green),
                )
            ],
          ),
        ),
      ),
    );
  }
  // ======================================================
  // CUSTOM NAVBAR (SESUAI FIGMA)
  // ======================================================
  Widget _buildCustomBottomNavbar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        // Membuat sudut atas kiri & kanan melengkung (Rounded)
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_filled, "HOME"),
          _buildNavItem(1, Icons.forum, "FORUM & REVIEW"),
          _buildNavItem(2, Icons.assignment, "MENU"), // Icon papan jalan
          _buildNavItem(3, Icons.person, "PROFIL"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68, // Area sentuh
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 1. GARIS INDIKATOR (Garis Lime di atas)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                // Warna garis lime saat aktif, transparan saat tidak aktif
                color: isSelected ? const Color(0xFFC8DB2C) : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),

            const Spacer(),

            // 2. ICON
            Icon(
              icon,
              size: 22,
              // Warna ikon tetap Navy gelap (sesuai gambar)
              color: const Color(0xFF01203F),
            ),

            const SizedBox(height: 4),

            // 3. TEXT LABEL
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01203F),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
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

