import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/screens/login.dart';

class ArticleCard extends StatefulWidget {
  final ArticleEntry article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  late int _likesCount;
  late bool _isLiked = false;
  late bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(ArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.likes != widget.article.likes || 
        oldWidget.article.isLiked != widget.article.isLiked) {
      setState(() {
        _initData();
      });
    }
  }

  void _initData() {
    _likesCount = widget.article.likes;
    _isLiked = widget.article.isLiked;
    _isDisliked = widget.article.isDisliked;
  }

  // Icon per sports
  IconData getSportIcon(String sportName) {
    String sport = sportName.toLowerCase();

    if (['football', 'basketball', 'baseball_softball', 'beach_volleyball', 
         'handball', 'hockey', 'table_tennis', 'water_polo'].contains(sport)) {
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

    return Icons.sports;
  }

  // Badge category
  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryNavy, // Navy Gelap
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kAccentLime, width: 1), // Lime Border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getSportIcon(category),
            color: AppColors.kAccentLime,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            category.replaceAll("_", " ").toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVote(String action, CookieRequest request) async {
    if (!request.loggedIn) {
      _showLoginDialog();
      return;
    }

    final previousLikes = _likesCount;
    final previousLiked = _isLiked;
    final previousDisliked = _isDisliked;

    setState(() {
      if (action == 'like') {
        if (_isLiked) {
          _isLiked = false;
          _likesCount--;
        } else {
          _isLiked = true;
          _likesCount++;
          _isDisliked = false;
        }
      } else {
        if (_isDisliked) {
          _isDisliked = false;
        } else {
          _isDisliked = true;
          if (_isLiked) {
            _isLiked = false;
            _likesCount--;
          }
        }
      }
    });

    try {
      String url = action == 'like' 
          ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/like/${widget.article.id}/"
          : "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//article/dislike/${widget.article.id}/";

      final response = await request.post(url, {});

      if (response['success'] == true && response.containsKey('likes')) {
        setState(() => _likesCount = response['likes']);
      } else {
        _rollback(previousLikes, previousLiked, previousDisliked);
      }
    } catch (e) {
      _rollback(previousLikes, previousLiked, previousDisliked);
    }
  }

  void _rollback(int likes, bool liked, bool disliked) {
    setState(() {
      _likesCount = likes;
      _isLiked = liked;
      _isDisliked = disliked;
    });
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final date = DateFormat("MMM d, yyyy").format(widget.article.created);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.article.thumbnail,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildCategoryBadge(widget.article.category),
                  )
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.kPrimaryNavy,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.south_west, color: AppColors.kAccentLime, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$date • $_likesCount Likes",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildVoteIcon(Icons.thumb_up, _isLiked, () => _handleVote('like', request)),
                        const SizedBox(width: 12),
                        _buildVoteIcon(Icons.thumb_down, _isDisliked, () => _handleVote('dislike', request), isDislike: true),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoteIcon(IconData icon, bool active, VoidCallback onTap, {bool isDislike = false}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        active ? icon : (isDislike ? Icons.thumb_down_outlined : Icons.thumb_up_outlined),
        color: active ? (isDislike ? Colors.redAccent : AppColors.kAccentLime) : Colors.grey,
        size: 20,
      ),
    );
  }
}