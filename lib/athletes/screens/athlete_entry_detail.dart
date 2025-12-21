// screens/athlete_entry_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/athletes/models/athlete_entry.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_form.dart';
import 'dart:convert';

class AthleteDetailPage extends StatefulWidget {
  final AthleteEntry athlete;

  const AthleteDetailPage({super.key, required this.athlete});

  @override
  State<AthleteDetailPage> createState() => _AthleteDetailPageState();
}

class _AthleteDetailPageState extends State<AthleteDetailPage> {
  // === COLOR PALETTE (SESUAI SPORTS) ===
  static const Color kNavyColor = Color(0xFF0F1929);
  static const Color kLimeColor = Color(0xFFD2F665);
  static const Color kDarkBlue = Color(0xFF162235);
  static const Color kRedAlert = Color(0xFFFF4C4C);

  // === STATE VARIABLES ===
  bool _isAdmin = false;
  late AthleteEntry _athlete;

  @override
  void initState() {
    super.initState();
    _athlete = widget.athlete;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      try {
        final response = await request.get(
          "http://127.0.0.1:8000/auth/status/",
        );
        if (mounted) {
          setState(() {
            _isAdmin = response['is_superuser'] ?? false;
          });
        }
      } catch (e) {
        print("Error checking admin status: $e");
      }
    }
  }

  Future<void> _refreshAthleteData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/athletes/flutter/',
      );

      if (response is List) {
        var updatedItemData;
        for (var item in response) {
          if (item['pk'] == _athlete.pk) {
            updatedItemData = item;
            break;
          }
        }

        if (updatedItemData != null && mounted) {
          setState(() {
            _athlete = AthleteEntry.fromJson(updatedItemData);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Data successfully updated!",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: kLimeColor,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      }
    } catch (e) {
      print("Error refreshing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to refresh data", style: GoogleFonts.poppins()),
          backgroundColor: kRedAlert,
        ),
      );
    }
  }

  // screens/athlete_entry_detail.dart - bagian _handleDelete
  Future<void> _handleDelete(
    BuildContext context,
    CookieRequest request,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkBlue,
        title: Text(
          "Delete Athlete",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ${_athlete.fields.athleteName}? This action cannot be undone.",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedAlert,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // TAMPILKAN LOADING
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator(color: kLimeColor)),
        );

        // DEBUG: Print URL sebelum request
        print("Attempting to delete athlete with ID: ${_athlete.pk}");
        print(
          "Delete URL: http://127.0.0.1:8000/athletes/flutter/${_athlete.pk}/delete/",
        );

        // COBA DENGAN METHOD YANG BERBEDA
        final response = await request.postJson(
          'http://127.0.0.1:8000/athletes/flutter/${_athlete.pk}/delete/',
          jsonEncode({}), // Kirim body kosong tapi JSON encoded
        );

        // DEBUG: Print response
        print("Delete response: $response");
        print("Response type: ${response.runtimeType}");

        // TUTUP LOADING
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
        }

        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${_athlete.fields.athleteName} deleted successfully!",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: kLimeColor,
                duration: const Duration(seconds: 2),
              ),
            );

            // Tunggu sebentar sebelum navigate back
            await Future.delayed(const Duration(milliseconds: 500));

            Navigator.pop(context); // Kembali ke list page
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to delete: ${response['message'] ?? 'Unknown error'}",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: kRedAlert,
              ),
            );
          }
        }
      } catch (e) {
        // TUTUP LOADING JIKA MASIH TERBUKA
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error: ${e.toString()}",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: kRedAlert,
            ),
          );
        }
        print("Delete error details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final f = _athlete.fields;

    return Scaffold(
      backgroundColor: kNavyColor,

      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AthleteEntryFormPage(athleteEntry: _athlete),
                  ),
                );
                _refreshAthleteData();
              },
              backgroundColor: kLimeColor,
              foregroundColor: kNavyColor,
              icon: const Icon(Icons.edit, size: 22),
              label: Text(
                "EDIT DATA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            )
          : null,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // === APP BAR WITH IMAGE (SESUAI SPORTS) ===
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
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
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _handleDelete(context, request),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Athlete Image
                  f.athletePhoto.isNotEmpty
                      ? Image.network(
                          f.athletePhoto,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: kDarkBlue,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: kLimeColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) => Container(
                            color: kDarkBlue,
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.white30,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: kDarkBlue,
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 150,
                              color: Colors.white30,
                            ),
                          ),
                        ),

                  // Gradient Overlay (SESUAI SPORTS)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          kNavyColor,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Athlete Name (SESUAI SPORTS)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Text(
                      f.athleteName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.0,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === BASIC INFO CARD (SESUAI SPORTS) ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: kDarkBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Country Info
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
                                  backgroundColor: kNavyColor,
                                  child: const Icon(
                                    Icons.flag,
                                    color: kLimeColor,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    f.country.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: kLimeColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Athlete",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider
                      _buildVerticalDivider(),

                      // Sport Type
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat(
                          "SPORT",
                          f.sport.toUpperCase(),
                          Icons.sports,
                        ),
                      ),

                      // Vertical Divider
                      _buildVerticalDivider(),

                      // Category
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat(
                          "CATEGORY",
                          "ATHLETE",
                          Icons.category,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // === BIOGRAPHY SECTION (SESUAI SPORTS) ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Section Header (SESUAI SPORTS)
                  _buildSectionHeader("ATHLETE BIOGRAPHY"),

                  const SizedBox(height: 15),

                  // Biography Content
                  Text(
                    f.biography,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === HELPER WIDGETS (SESUAI SPORTS) ===

  Widget _buildVerticalDivider() => Container(
    width: 1,
    color: Colors.white.withOpacity(0.1),
    margin: const EdgeInsets.symmetric(horizontal: 10),
  );

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: kLimeColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: kLimeColor, size: 18),
        const SizedBox(height: 6),
        Text(
          value.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
