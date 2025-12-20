import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/athletes/models/athlete_entry.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_form.dart';

class AthleteDetailPage extends StatefulWidget {
  final AthleteEntry athlete;
  const AthleteDetailPage({super.key, required this.athlete});

  @override
  State<AthleteDetailPage> createState() => _AthleteDetailPageState();
}

class _AthleteDetailPageState extends State<AthleteDetailPage> {
  static const Color kNavyColor = Color(0xFF0F1929);
  static const Color kLimeColor = Color(0xFFD2F665);
  static const Color kDarkBlue = Color(0xFF162235);
  static const Color kRedAlert = Color(0xFFFF4C4C);
  static const Color kYellow = Color(0xFFFFFF00);
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
      } catch (e) {}
    }
  }

  Future<void> _refreshAthleteData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/athletes/flutter/',
      );
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
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }
    } catch (e) {}
  }

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
          ),
        ),
        content: Text(
          "Are you sure you want to delete this athlete? This action cannot be undone.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRedAlert),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await request.postJson(
        'http://127.0.0.1:8000/athletes/flutter/${_athlete.pk}/delete/',
        {},
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Athlete deleted successfully!",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: kLimeColor,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? "Failed to delete athlete.",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: kRedAlert,
            ),
          );
        }
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
              icon: const Icon(Icons.edit, color: kNavyColor),
              label: Text(
                "EDIT DATA",
                style: GoogleFonts.poppins(
                  color: kNavyColor,
                  fontWeight: FontWeight.bold,
                ),
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
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    f.athletePhoto.isNotEmpty
                        ? f.athletePhoto
                        : 'https://via.placeholder.com/400x400?text=No+Image',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: kDarkBlue),
                  ),
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
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.athleteName.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.0,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                f.sport.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF1E3CC8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              f.country,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kNavyColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: GoogleFonts.poppins(
                            color: kNavyColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInfoRow(Icons.sports, "Sport", f.sport),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.flag, "Country", f.country),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142DA0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kYellow, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Biography",
                          style: GoogleFonts.poppins(
                            color: kLimeColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          f.biography,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.justify,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFA63535), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: kNavyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
