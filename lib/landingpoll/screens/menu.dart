import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/app_colors.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/screens/sport_entry_list.dart';
import 'package:wikilympics/sports/screens/sport_entry_detail.dart';

import 'package:wikilympics/athletes/models/athlete_entry.dart';
import 'package:wikilympics/athletes/screens/athletes_entry_list.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_detail.dart';

import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/article/screens/article_detail.dart';
import 'package:wikilympics/article/screens/article_list.dart';

import 'package:wikilympics/upcomingevents/models/events_entry.dart';
import 'package:wikilympics/upcomingevents/screens/events_detail_screen.dart';
import 'package:wikilympics/upcomingevents/screens/events_list_screen.dart';

import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/Razan/Screens/forum_main.dart';
import 'package:wikilympics/Razan/Screens/forum_detail.dart';

import 'package:wikilympics/screens/login.dart';
import '../../widgets/left_drawer.dart';

import '../models/poll_model.dart';
import '../widgets/poll_service.dart';
import 'package:wikilympics/landingpoll/screens/poll_list_page.dart';

import '../widgets/popular_sport_card.dart';
import '../widgets/athlete_highlight_card.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/latest_article_card.dart';
import '../widgets/forum_review_card.dart';

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
  bool _isAdmin = false;
  int _selectedIndex = 0;
  Widget? _selectedPage;

  Widget _buildModernForumCard(ForumEntry forum) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ForumDetailPage(forum: forum)));
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    fixImageUrl(forum.fields.thumbnail),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey, height: 140),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "${forum.fields.dateCreated.day}/${forum.fields.dateCreated.month}",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forum.fields.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF01203F)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    forum.fields.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF155F90)),
                      const SizedBox(width: 4),
                      Text("Join Discussion", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF155F90))),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget> _navbarPages = const [
    Placeholder(),
    ForumListPage(),
    Placeholder(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAdminStatus();

      if (!_alreadyLoad) {
        _alreadyLoad = true;
        _loadPoll();
      }
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      try {
        final response = await request.get("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/status/");
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      } catch (e) {
        setState(() => _isAdmin = false);
      }
    } else {
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _loadPoll() async {
    final request = context.read<CookieRequest>();
    if (_isAdmin) {
      setState(() {
        _showPopup = false;
      });
      return;
    }

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

  void _selectMenuPage(Widget page) {
    Navigator.pop(context);
    setState(() {
      _selectedPage = page;
      _selectedIndex = 2;
    });
  }

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

                _menuItem(
                  icon: Icons.sports_basketball_outlined,
                  label: "Sports",
                  onTap: () => _selectMenuPage(const SportEntryListPage()),
                ),

                _menuItem(
                  icon: Icons.article_outlined,
                  label: "Article",
                  onTap: () => _selectMenuPage(const ArticleListPage()),
                ),

                _menuItem(
                  icon: Icons.event_outlined,
                  label: "Upcoming Events",
                  onTap: () => _selectMenuPage(const EventsListScreen()),
                ),

                _menuItem(
                  icon: Icons.person_search_outlined,
                  label: "Athletes",
                  onTap: () => _selectMenuPage(AthleteEntryListPage()),
                ),

                if (_isAdmin) ...[
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[300]),
                  _menuItem(
                    icon: Icons.how_to_vote,
                    label: "Polling Management",
                    onTap: () => _selectMenuPage(const PollListPage()),
                  ),
                ],
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({required IconData icon, required String label, required VoidCallback onTap}) {
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

  void _onNavTap(int index) {
    if (index == 2) {
      _openMenuSheet(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
      _selectedPage = null;
    });
  }

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
          if (_selectedIndex == 2 && _selectedPage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: _selectedPage!,
            )
          else if (_selectedIndex == 0)
            _buildLandingContent(request)
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: _navbarPages[_selectedIndex],
            ),

          if (_showPopup && _poll != null) _buildPopup(greeting),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavbar(),
    );
  }

  Widget _buildLandingContent(CookieRequest request) {
    final username = request.jsonData['username'];

    return SingleChildScrollView(
      child: Column(
        children: [
        
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01203F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  child: const Text("SIGN IN", style: TextStyle(color: Colors.white, fontSize: 12)),
                )
                    : Text(
                  username,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF01203F)),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: Image.asset("assets/hero_wikilympics.jpg", fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),

          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8DB2C), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF01203F), size: 32),
                  title: Text(
                    "Admin Dashboard",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text("Manage Polls & Users"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01203F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PollListPage()));
                    },
                    child: const Text("Manage", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Popular Sports",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF01203F)),
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
                          imageUrl: fixImageUrl(sport.fields.sportImg),
                          flagUrl: fixImageUrl(sport.fields.countryFlagImg),
                          description: sport.fields.sportDescription,
                          origin: sport.fields.countryOfOrigin,
                          type: sport.fields.sportType.toString().split('.').last.replaceAll('_', ' '),
                          onDetailTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SportDetailPage(sport: sport),
                              ),
                            );
                          },
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
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _selectedPage = const SportEntryListPage();
                          _selectedIndex = 2;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "SEE ALL SPORTS",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC8DB2C)),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFC8DB2C), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

         
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
                      color: const Color(0xFF01203F)
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<AthleteEntry>>(
                  future: fetchAthletes(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error loading athletes: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No athletes data available");
                    }

                    final topAthletes = snapshot.data!.take(3).toList();
                    return Column(
                      children: topAthletes.asMap().entries.map<Widget>((entry) {
                        int index = entry.key;
                        AthleteEntry athlete = entry.value;

                        return AthleteHighlightCard(
                          rank: index + 1,
                          athleteName: athlete.fields.athleteName,
                          sportName: athlete.fields.sport,
                          country: athlete.fields.country,
                          imageUrl: fixImageUrl(athlete.fields.athletePhoto),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AthleteDetailPage(athlete: athlete),
                              ),
                            );
                          },
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
                          offset: const Offset(0, 4)
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedPage = AthleteEntryListPage();
                        _selectedIndex = 2;
                      });
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
                                color: Color(0xFFC8DB2C)
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFC8DB2C)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upcoming Events",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF155F90)),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<EventEntry>>(
                  future: fetchEvents(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No upcoming events available.");
                    }
                    final events = snapshot.data!.take(3).toList();
                    return Column(
                      children: events.map((event) {
                        return Column(
                          children: [
                            UpcomingEventCard(
                              image: Image.network(
                                fixImageUrl(event.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                              ),
                              title: event.name,
                              author: event.organizer,
                              date: "${event.date.day.toString().padLeft(2, '0')}-${event.date.month.toString().padLeft(2, '0')}-${event.date.year}",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latest Articles",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF155F90)),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<ArticleEntry>>(
                  future: fetchArticles(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No articles available");
                    }

                    final articles = snapshot.data!.take(2).toList();
                    return Column(
                      children: articles.map((article) {

                        if (article.thumbnail.contains("pinimg.com") || article.thumbnail.isEmpty) {
                          article.thumbnail = "https://cdn.pixabay.com/photo/2016/05/01/17/56/rio-1365366_1280.jpg";
                        }

                        String categoryFormatted = article.category.toUpperCase().replaceAll('_', ' ');

                        return LatestArticleCard(
                          imageUrl: article.thumbnail,
                          title: article.title,
                          author: categoryFormatted,
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reviews & Forums",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF155F90)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Text("View All", style: TextStyle(color: Color(0xFFC8DB2C), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: FutureBuilder<List<ForumEntry>>(
                  future: fetchForums(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No forums yet."));
                    }

                    final forums = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: forums.length,
                      itemBuilder: (context, index) {
                        final forum = forums[index];
                        return _buildModernForumCard(forum);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPopup(String greeting) {
    final poll = _poll!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 340,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8DB2C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_graph_rounded, color: Color(0xFF155F90), size: 22),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => setState(() => _showPopup = false),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                greeting.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: const Color(0xFF155F90).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                poll.questionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: const Color(0xFF01203F),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              ...poll.options.map((o) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _hasVoted ? null : () => _vote(o.id),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _hasVoted ? Colors.grey[200]! : const Color(0xFF01203F).withOpacity(0.1),
                            width: 1.5,
                          ),
                          color: _hasVoted ? Colors.grey[50] : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              o.optionText,
                              style: GoogleFonts.poppins(
                                color: _hasVoted ? Colors.grey[400] : const Color(0xFF01203F),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (!_hasVoted) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFC8DB2C)),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              if (_hasVoted)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Thanks for voting!",
                                style: GoogleFonts.poppins(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNavbar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, -2)),
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
            Icon(icon, size: 22, color: const Color(0xFF01203F)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF01203F)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}


String fixImageUrl(String rawUrl) {
  if (rawUrl.isEmpty) {
    return "https://cdn.pixabay.com/photo/2016/05/01/17/56/rio-1365366_1280.jpg";
  }

  if (!kIsWeb && (rawUrl.contains("127.0.0.1") || rawUrl.contains("localhost"))) {
    rawUrl = rawUrl.replaceAll("127.0.0.1", "10.0.2.2").replaceAll("localhost", "10.0.2.2");
  }

  if (rawUrl.contains("pinimg.com")) {
    return "https://cdn.pixabay.com/photo/2016/05/01/17/56/rio-1365366_1280.jpg";
  }

  if (rawUrl.startsWith("/")) {
    String base = kIsWeb ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/" : "http://10.0.2.2:8000";
    return "$base$rawUrl";
  }

  return rawUrl;
}

Future<List<SportEntry>> fetchSports(CookieRequest request) async {
  final String baseUrl = kIsWeb ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/" : "http://10.0.2.2:8000";

  final response = await request.get('$baseUrl/sports/json/');

  List<SportEntry> listSports = [];
  for (var d in response) {
    if (d != null) {
      listSports.add(SportEntry.fromJson(d));
    }
  }
  return listSports;
}

Future<List<AthleteEntry>> fetchAthletes(CookieRequest request) async {
  final String baseUrl = kIsWeb ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/" : "http://10.0.2.2:8000";
  final response = await request.get('$baseUrl/athletes/flutter/');

  List<AthleteEntry> listAthletes = [];
  for (var d in response) {
    if (d != null) {
      listAthletes.add(AthleteEntry.fromJson(d));
    }
  }
  return listAthletes;
}

Future<List<ArticleEntry>> fetchArticles(CookieRequest request) async {
  final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/json/');
  List<ArticleEntry> listArticles = [];
  for (var d in response) {
    if (d != null) {
      listArticles.add(ArticleEntry.fromJson(d));
    }
  }
  return listArticles;
}

Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
  final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//upcoming_event/json/');
  List<EventEntry> listEvents = [];
  for (var d in response) {
    if (d != null) {
      listEvents.add(EventEntry.fromJson(d));
    }
  }
  return listEvents;
}

Future<List<ForumEntry>> fetchForums(CookieRequest request) async {
  final String baseUrl = kIsWeb ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/" : "http://10.0.2.2:8000";
  final response = await request.get('$baseUrl/forum_section/forums/json-for/');

  List<ForumEntry> listForums = [];
  for (var d in response) {
    if (d != null) {
      listForums.add(ForumEntry.fromJson(d));
    }
  }
  return listForums;
}