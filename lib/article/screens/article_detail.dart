import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/article/models/article_entry.dart';
import 'package:intl/intl.dart';
import 'package:wikilympics/article/screens/article_form.dart';
import 'package:wikilympics/screens/login.dart';
import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/screens/sport_entry_detail.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleEntry article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late int _currentLikes;
  bool _isUpvoting = false;
  bool _isAdmin = false; 
  late bool _isLiked;
  late ArticleEntry _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _currentLikes = _article.likes;
    _isLiked = _article.isLiked;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
      _refreshArticleData();
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      final response = await request.get("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/status/");
      if (mounted) {
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      }
    }
  }

  Future<void> _refreshArticleData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/json/');
      for (var item in response) {
        if (item['id'] == _article.id) {
          setState(() {
            _article = ArticleEntry.fromJson(item);
            _currentLikes = _article.likes;
            _isLiked = _article.isLiked;
          });
          break;
        }
      }
    } catch (e) {
      debugPrint("Error refresh: $e");
    }
  }

  Future<void> _handleDelete(CookieRequest request) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162235),
        title: Text("Delete Article", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this story?", style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await request.postJson(
        'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/delete-flutter/${_article.id}/',
        null,
      );
      if (mounted && response['status'] == 'success') {
        Navigator.pop(context, "deleted");
      }
    }
  }

  Future<void> _handleUpvote() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      _showLoginDialog();
      return;
    }

    if (_isLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have already upvoted this article.")),
      );
      return;
    }

    if (_isUpvoting) return;
    setState(() => _isUpvoting = true);

    try {
      final response = await request.post(
        'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/like/${_article.id}/',
        {},
      );

      if (mounted) {
        if (response['success'] == true) {
          setState(() {
            // Mengambil jumlah like terbaru dari Django response
            _currentLikes = response['likes']; 
            _isLiked = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Article status updated!"),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    } finally {
      if (mounted) setState(() => _isUpvoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final formattedDate = DateFormat('MMMM dd, yyyy').format(_article.created);

    return Scaffold(
      backgroundColor: AppColors.kPrimaryNavy,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.kPrimaryNavy,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: InkWell(
          onTap: _isUpvoting ? null : _handleUpvote,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 56,
            decoration: BoxDecoration(
              color: _isUpvoting ? Colors.grey : AppColors.kAccentLime,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isUpvoting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.kPrimaryNavy, strokeWidth: 2))
                  : const Icon(Icons.thumb_up_alt_rounded, color: AppColors.kPrimaryNavy),
                const SizedBox(width: 12),
                Text(_isUpvoting ? "PROCESSING..." : "UPVOTE THIS ARTICLE",
                  style: const TextStyle(color: AppColors.kPrimaryNavy, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.kPrimaryNavy,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context, _currentLikes),
                ),
              ),
            ),
            
            // Menu titik tiga(admin)
            actions: [
              if (_isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: AppColors.kDarkBlueDetail,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleFormPage(article: _article),
                            ),
                          );
                          _refreshArticleData();
                        } else if (value == 'delete') {
                          _handleDelete(request);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white70, size: 20),
                              SizedBox(width: 12),
                              Text("Edit", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              SizedBox(width: 12),
                              Text("Delete", style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(_article.thumbnail, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, AppColors.kPrimaryNavy],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60, left: 20, right: 20,
                    child: Text(_article.title.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1)),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.kDarkBlueDetail,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_article.sportId != null) {
                            _navigateToSportDetail(_article.sportId!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Sport category not found")),
                            );
                          }
                        },
                        child: _buildStatItem(Icons.category, "CATEGORY", _article.category.toUpperCase(), AppColors.kAccentLime),
                      ),
                    ),
                    _buildDivider(),
                    Expanded(child: _buildStatItem(Icons.favorite, "LIKES", "$_currentLikes", Colors.pinkAccent)),
                    _buildDivider(),
                    Expanded(child: _buildStatItem(Icons.event, "DATE", formattedDate.split(',')[0].toUpperCase(), Colors.cyanAccent)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: AppColors.kAccentLime),
                      const SizedBox(width: 10),
                      const Text("ARTICLE COVERAGE",
                        style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(_article.content,
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.8),
                    textAlign: TextAlign.justify),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 25, color: Colors.white.withOpacity(0.1));

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(label, 
          style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value, 
            key: ValueKey<String>(value),
            style: TextStyle(
              color: label == "CATEGORY" ? Color(0xFFD2F665) : Colors.white,
              fontSize: 12, 
              fontWeight: FontWeight.w900,
              decoration: label == "CATEGORY" ? TextDecoration.underline : TextDecoration.none,
              decorationColor: Color(0xFFD2F665),
              decorationThickness: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to vote.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToSportDetail(String sportId) async {
    final request = context.read<CookieRequest>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFD2F665))),
    );

    try {
      // Ambil semua data sports
      final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//sports/json/');
      
      SportEntry? targetSport;
      for (var item in response) {
        if (item['pk'].toString() == sportId) {
          targetSport = SportEntry.fromJson(item);
          break;
        }
      }

      if (mounted) Navigator.pop(context);

      if (targetSport != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SportDetailPage(sport: targetSport!),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sport details not found")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Error: $e");
    }
  }
}