import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/upcomingevents/models/events_entry.dart';
import 'package:wikilympics/upcomingevents/screens/edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventEntry event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventEntry _event;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _checkAdminStatus();
  }

  // Cek status admin untuk menampilkan tombol edit/delete
  void _checkAdminStatus() {
    final request = context.read<CookieRequest>();
    setState(() {
      _isAdmin = request.jsonData['is_superuser'] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimaryNavy,

      // Tombol Edit
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditEventScreen(event:_event),
            ),
          );
          if (result != null && result is EventEntry) {
            setState(() {
              _event = result;
            });
          }
        },
        backgroundColor: AppColors.kAccentLime,
        icon: const Icon(Icons.edit, color: AppColors.kPrimaryNavy),
        label: Text("EDIT EVENT",
            style: GoogleFonts.poppins(color: AppColors.kPrimaryNavy, fontWeight: FontWeight.bold)),
      )
          : null,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
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

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _event.imageUrl,
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
                      _event.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1.1,
                          shadows: [const Shadow(color: Colors.black, blurRadius: 10)]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ringkasan Info
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
                            Text(
                              "ORGANIZER",
                              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _event.organizer,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      _buildVerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat("DATE", DateFormat('dd MMM').format(_event.date), Icons.calendar_month),
                      ),
                      _buildVerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: _buildSimpleStat("SPORT", _event.sportBranch, Icons.sports_basketball),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Deskripsi & Detail Lokasi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionHeader("DESCRIPTION"),
                  const SizedBox(height: 15),
                  Text(
                    _event.description,
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.8),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 35),

                  // Detail Lokasi Box
                  _buildSectionHeader("EVENT'S LOCATION"),
                  const SizedBox(height: 15),
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
                            const Icon(Icons.location_on, color: AppColors.kAccentLime, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "ADDRESS",
                              style: GoogleFonts.poppins(color: AppColors.kAccentLime, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _event.location,
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
}