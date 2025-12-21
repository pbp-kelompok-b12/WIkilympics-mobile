import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/screens/sport_entry_form.dart';

class SportDetailPage extends StatefulWidget {
  final SportEntry sport;

  const SportDetailPage({super.key, required this.sport});

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  static const Color kRedAlert = Color(0xFFFF4C4C);

  bool _isAdmin = false;
  late SportEntry _sport;

  IconData _getSportIcon(String label) {
    switch (label.toLowerCase()) {
      case 'water': return Icons.pool;
      case 'strength': return Icons.fitness_center;
      case 'athletic': return Icons.directions_run;
      case 'racket': return Icons.sports_tennis;
      case 'ball': return Icons.sports_soccer;
      case 'combat': return Icons.sports_martial_arts;
      case 'target': return Icons.ads_click;
      default: return Icons.sports;
    }
  }

  IconData _getParticipationIcon(String label) {
    switch (label.toLowerCase()) {
      case 'team': return Icons.groups;
      case 'individual': return Icons.person;
      case 'both': return Icons.compare_arrows;
      default: return Icons.groups;
    }
  }

  @override
  void initState() {
    super.initState();
    _sport = widget.sport;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      try {
        final response = await request.get("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/status/");
        if (mounted) {
          setState(() {
            _isAdmin = response['is_superuser'] ?? false;
          });
        }
      } catch (e) {
      }
    }
  }

  Future<void> _refreshSportData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//sports/json/');
      var updatedItemData;

      for (var item in response) {
        if (item['pk'] == _sport.pk) {
          updatedItemData = item;
          break;
        }
      }

      if (updatedItemData != null && mounted) {
        setState(() {
          _sport = SportEntry.fromJson(updatedItemData);
        });
      }
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  Future<void> _handleDelete(BuildContext context, CookieRequest request) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.kDarkBlueDetail,
        title: Text("Delete Sport", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to delete this sport? This action cannot be undone.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRedAlert),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await request.postJson(
        'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//sports/delete-flutter/${_sport.pk}/',
        null,
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Sport deleted successfully!", style: GoogleFonts.poppins()),
            backgroundColor: AppColors.kAccentLime,
          ));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to delete sport.", style: GoogleFonts.poppins()),
            backgroundColor: kRedAlert,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final f = _sport.fields;

    String typeLabel = _formatEnum(f.sportType.toString());
    String partLabel = _formatEnum(f.participationStructure.toString());
    IconData typeIcon = _getSportIcon(typeLabel);
    IconData partIcon = _getParticipationIcon(partLabel);

    return Scaffold(
      backgroundColor: AppColors.kPrimaryNavy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.kPrimaryNavy,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
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
                              builder: (context) => SportEntryFormPage(sportEntry: _sport),
                            ),
                          );
                          _refreshSportData();
                        } else if (value == 'delete') {
                          _handleDelete(context, request);
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
                  f.sportImg.isEmpty
                      ? Container(color: AppColors.kDarkBlueDetail)
                      : Image.network(
                          f.sportImg,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(color: AppColors.kDarkBlueDetail),
                        ),
                  Image.network(
                    f.sportImg,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: AppColors.kDarkBlueDetail),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, AppColors.kPrimaryNavy],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Text(
                      f.sportName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.0,
                        shadows: [const Shadow(color: Colors.black, blurRadius: 10)]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.kDarkBlueDetail,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.kPrimaryNavy,
                                  backgroundImage: f.countryFlagImg.isNotEmpty
                                      ? NetworkImage(f.countryFlagImg)
                                      : null,
                                  child: f.countryFlagImg.isEmpty
                                      ? const Icon(Icons.flag, color: Colors.white, size: 12)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    f.countryOfOrigin.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.history, color: AppColors.kAccentLime, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  "Since ${f.firstYearPlayed}",
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      _buildVerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat("TYPE", typeLabel, typeIcon),
                      ),
                      _buildVerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat("PLAYERS", partLabel, partIcon),
                      ),
                    ],
                  ),
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
                  _buildSectionHeader("OVERVIEW"),
                  const SizedBox(height: 15),
                  Text(
                    f.sportDescription,
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.8),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 35),
                  _buildSectionHeader("HISTORY"),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.white.withOpacity(0.2), width: 2))
                    ),
                    child: Text(
                      f.historyDescription,
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.8, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.kDarkBlueDetail, AppColors.kPrimaryNavy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.kAccentLime.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.kAccentLime.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.backpack, color: AppColors.kAccentLime, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "REQUIRED EQUIPMENT",
                              style: GoogleFonts.poppins(color: AppColors.kAccentLime, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          f.equipment,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 10));

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.kAccentLime),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.poppins(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.kAccentLime, size: 18),
        const SizedBox(height: 6),
        Text(value.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
             style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatEnum(String enumString) {
    try {
      String raw = enumString.split('.').last.replaceAll('_', ' ').replaceAll(' SPORT', '');
      return raw;
    } catch (e) {
      return enumString;
    }
  }
}