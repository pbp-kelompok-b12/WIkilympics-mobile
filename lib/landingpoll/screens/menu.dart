import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS MODUL LAIN ---
import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/screens/sport_entry_list.dart';
import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/article/widgets/article_card.dart';
import 'package:wikilympics/article/screens/article_detail.dart';
import 'package:wikilympics/screens/login.dart';
import '../../widgets/left_drawer.dart';
// Import Model Events
import 'package:wikilympics/upcomingevents/models/events_entry.dart';
// Import Halaman Detail Events (Sesuai import di file list screen temanmu)
import 'package:wikilympics/upcomingevents/screens/events_detail_screen.dart';

// --- IMPORTS LANDING & POLLING ---
import '../models/poll_model.dart';
import '../widgets/poll_service.dart';
// Import halaman List Admin
import 'package:wikilympics/landingpoll/screens/poll_list_page.dart';

// --- IMPORTS WIDGETS TEMAN ---
import '../widgets/popular_sport_card.dart';
import '../widgets/athlete_highlight_card.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/latest_article_card.dart';
import '../widgets/forum_review_card.dart';

// --- IMPORTS NAVBAR PAGES ---
import 'forum_page.dart';
import 'profile_page.dart';


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

  // 1. TAMBAHKAN VARIABEL ADMIN
  bool _isAdmin = false;

  int _selectedIndex = 0;

  final List<Widget> _navbarPages = const [
    Placeholder(), // home landing (index 0 ditangani khusus di build)
    ForumPage(),
    Placeholder(), // menu (index 2 membuka bottom sheet)
    ProfilePage(),
  ];

  // ======================================================
  // INIT STATE (Load Admin & Poll)
  // ======================================================
  @override
  void initState() {
    super.initState();
    // 2. CEK STATUS ADMIN SAAT MEMBUKA HALAMAN
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_alreadyLoad) {
      _alreadyLoad = true;
      _loadPoll();
    }
  }

  // 3. FUNGSI CEK ADMIN KE DJANGO
  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      try {
        // Pastikan endpoint ini benar di Django kamu
        final response = await request.get("http://127.0.0.1:8000/auth/status/");
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      } catch (e) {
        // Jika error, anggap bukan admin
        setState(() => _isAdmin = false);
      }
    } else {
      setState(() => _isAdmin = false);
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
  // BOTTOM SHEET MENU (FIXED)
  // ======================================================
  void _openMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
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

                // --- LIST MENU ITEMS ---

                _menuItem(
                  icon: Icons.sports_basketball_outlined,
                  label: "Sports",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SportEntryListPage()));
                  },
                ),

                _menuItem(
                  icon: Icons.article_outlined,
                  label: "Article",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlePage()));
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

                // 4. BAGIAN TOMBOL POLLING MANAGEMENT (HANYA ADMIN)
                if (_isAdmin) ...[
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[300]),
                  _menuItem(
                    icon: Icons.how_to_vote,
                    label: "Polling",
                    onTap: () {
                      Navigator.pop(context); // Tutup sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PollListPage()),
                      );
                    },
                  ),
                ],
                // ========================================

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

      bottomNavigationBar: _buildCustomBottomNavbar(),
    );
  }

  // ======================================================
  // HOME LANDING CONTENT
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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

          // ===== POPULAR SPORTS =====
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
                FutureBuilder<List<SportEntry>>(
                  future: fetchSports(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error loading sports: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No sports data available");
                    }

                    final topSports = snapshot.data!.take(3).toList();
                    return Column(
                      children: topSports.asMap().entries.map((entry) {
                        int index = entry.key;
                        SportEntry sport = entry.value;
                        return PopularSportCard(
                          rank: index + 1,
                          sportName: sport.fields.sportName,
                          firstYear: sport.fields.firstYearPlayed.toString(),
                          imageUrl: sport.fields.sportImg,
                          description: sport.fields.sportDescription,
                          origin: sport.fields.countryOfOrigin,
                          type: sport.fields.sportType.toString(),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SportEntryListPage()),
                        );
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
                                color: Color(0xFFC8DB2C),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFC8DB2C),
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
                  onTap: () {},
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
                    onTap: () {},
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
                Text(
                  "Upcoming Events",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF155F90),
                  ),
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<EventEntry>>(
                  future: fetchEvents(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error loading events: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No upcoming events.");
                    }

                    // Ambil 2 event teratas saja
                    final events = snapshot.data!.take(2).toList();

                    return Column(
                      children: events.map((event) {
                        // Format Tanggal Sederhana (YYYY-MM-DD)
                        String formattedDate = "${event.date.year}-${event.date.month.toString().padLeft(2,'0')}-${event.date.day.toString().padLeft(2,'0')}";

                        return Column(
                          children: [
                            UpcomingEventCard(
                              // Konversi URL string ke Widget Image
                              image: Image.network(
                                event.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                              ),
                              title: event.name,
                              author: event.organizer, // Kita pakai organizer sebagai 'author'
                              date: formattedDate,
                              onTap: () {
                                // Navigasi ke Detail Event Teman
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(event: event),
                                  ),
                                );
                              },
                            ),
                            // Tambahkan Divider pembatas (kecuali untuk item terakhir)
                            if (event != events.last)
                              Divider(color: Colors.grey[300], height: 20),
                          ],
                        );
                      }).toList(),
                    );
                  },
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
                          author: article.category,
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

          // ===== FORUM & REVIEWS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forum & Reviews",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF155F90),
                  ),
                ),
                const SizedBox(height: 16),
                ForumReviewCard(
                  username: "Tassy Omah",
                  profileImage: "https://i.pravatar.cc/150?u=a042581f4e29026024d",
                  timeAgo: "6h ago",
                  title: "The Raptors Don't Need Leonard To be in that game! They really don't!",
                  contentImage: "https://images.unsplash.com/photo-1546519638-68e109498ee2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                  likeCount: 334,
                  commentCount: 23440,
                  onTap: () {},
                ),
                ForumReviewCard(
                  username: "Jhon Doe",
                  profileImage: "https://i.pravatar.cc/150?u=a042581f4e29026704d",
                  timeAgo: "2h ago",
                  title: "Why Swimming is the best cardio workout you can do right now.",
                  contentImage: "https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                  likeCount: 120,
                  commentCount: 45,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForumPage())
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "SEE ALL FORUMS",
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
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
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
  // CUSTOM NAVBAR
  // ======================================================
  Widget _buildCustomBottomNavbar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildNavItem(2, Icons.assignment, "MENU"),
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
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC8DB2C) : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF01203F),
            ),
            const SizedBox(height: 4),
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

// --- HELPER FUNCTIONS ---

Future<List<SportEntry>> fetchSports(CookieRequest request) async {
  // Ganti URL jika perlu
  final response = await request.get('http://127.0.0.1:8000/sports/json/');
  List<SportEntry> listSports = [];
  for (var d in response) {
    if (d != null) {
      listSports.add(SportEntry.fromJson(d));
    }
  }
  return listSports;
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

Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
  final response = await request.get('http://127.0.0.1:8000/upcoming_events/json/');
  List<EventEntry> listEvents = [];
  for (var d in response) {
    if (d != null) {
      listEvents.add(EventEntry.fromJson(d));
    }
  }
  return listEvents;
}