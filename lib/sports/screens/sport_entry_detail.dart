import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/screens/sport_entry_form.dart';

class SportDetailPage extends StatefulWidget {
  final SportEntry sport;

  const SportDetailPage({super.key, required this.sport});

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  // === COLOR PALETTE ===
  static const Color kNavyColor = Color(0xFF0F1929);
  static const Color kLimeColor = Color(0xFFD2F665);
  static const Color kDarkBlue = Color(0xFF162235);
  static const Color kRedAlert = Color(0xFFFF4C4C);

  // === STATE VARIABLES ===
  bool _isAdmin = false;
  late SportEntry _sport;

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
        final response = await request.get("http://127.0.0.1:8000/auth/status/");
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
      final response = await request.get('http://127.0.0.1:8000/sports/json/');

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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Data successfully updated!", style: GoogleFonts.poppins()),
          backgroundColor: kLimeColor,
          duration: const Duration(milliseconds: 1000),
        ));
      }
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  Future<void> _handleDelete(BuildContext context, CookieRequest request) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkBlue,
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
        'http://127.0.0.1:8000/sports/delete-flutter/${_sport.pk}/',
        {}
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Sport deleted successfully!", style: GoogleFonts.poppins()),
            backgroundColor: kLimeColor,
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

    return Scaffold(
      backgroundColor: kNavyColor,

      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SportEntryFormPage(sportEntry: _sport),
                  ),
                );
                _refreshSportData();
              },
              backgroundColor: kLimeColor,
              icon: const Icon(Icons.edit, color: kNavyColor),
              label: Text("EDIT DATA",
                style: GoogleFonts.poppins(color: kNavyColor, fontWeight: FontWeight.bold)
              ),
            )
          : null,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: kNavyColor,
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
                    backgroundColor: kRedAlert.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.white, size: 20),
                      onPressed: () => _handleDelete(context, request),
                    ),
                  ),
                )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    f.sportImg,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: kDarkBlue),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, kNavyColor],
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
                  color: kDarkBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))
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
                                  backgroundImage: NetworkImage(f.countryFlagImg),
                                  backgroundColor: kNavyColor,
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
                                const Icon(Icons.history, color: kLimeColor, size: 14),
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
                        child: _buildSimpleStat("TYPE", _formatEnum(f.sportType.toString()), Icons.grid_view),
                      ),
                      _buildVerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat("PLAYERS", _formatEnum(f.participationStructure.toString()), Icons.groups),
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
                  _buildSectionHeader("HISTORICAL CONTEXT"),
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
                        colors: [kDarkBlue, kNavyColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kLimeColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: kLimeColor.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.fitness_center, color: kLimeColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "REQUIRED EQUIPMENT",
                              style: GoogleFonts.poppins(color: kLimeColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
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

  // === HELPERS ===
  Widget _buildVerticalDivider() => Container(width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 10));

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: kLimeColor),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.poppins(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: kLimeColor, size: 18),
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
    } catch (e) { return enumString; }
  }
}