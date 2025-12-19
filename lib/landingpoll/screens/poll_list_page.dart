import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/landingpoll/models/poll_model.dart';
import 'package:wikilympics/landingpoll/screens/poll_form_page.dart';
import 'package:wikilympics/landingpoll/widgets/poll_service.dart';

class PollListPage extends StatefulWidget {
  const PollListPage({super.key});

  @override
  State<PollListPage> createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage> {
  bool _isAdmin = false;
  late Future<List<PollQuestion>> _pollFuture;

  // --- WARNA TEMA WIKILYMPICS ---
  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kAccentLime = const Color(0xFFC8DB2C);
  final Color kBgGrey = const Color(0xFFF8F9FA);
  final Color kBarGrey = const Color(0xFFE9ECEF);

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _pollFuture = PollService.fetchPolls(request);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      try {
        final response = await request.get("http://127.0.0.1:8000/auth/status/");
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      } catch (e) {
        // silent error
      }
    }
  }

  void _refreshList() {
    final request = context.read<CookieRequest>();
    setState(() {
      _pollFuture = PollService.fetchPolls(request);
    });
  }

  // Helper: Hitung Total Vote untuk Persentase
  int _getTotalVotes(PollQuestion poll) {
    int total = 0;
    for (var opt in poll.options) {
      total += opt.votes;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kPrimaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/wikilympics_banner.png', // Pastikan asset ada
          height: 32,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      // Tombol Tambah (FAB)
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: kAccentLime,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PollFormPage()),
          );
          _refreshList();
        },
        icon: Icon(Icons.add, color: kPrimaryNavy),
        label: Text(
            "New Poll",
            style: GoogleFonts.poppins(
                color: kPrimaryNavy,
                fontWeight: FontWeight.bold
            )
        ),
      )
          : null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER TITLE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Manage Polls",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Create, edit, or remove polls",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: FutureBuilder<List<PollQuestion>>(
              future: _pollFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No polls active right now.",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final poll = snapshot.data![index];
                    final int totalVotes = _getTotalVotes(poll);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Card: Question & Actions
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    poll.questionText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kPrimaryNavy,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (_isAdmin)
                                  Row(
                                    children: [
                                      // Edit
                                      _actionButton(
                                          icon: Icons.edit_rounded,
                                          color: Colors.amber[700]!,
                                          bg: Colors.amber[50]!,
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PollFormPage(poll: poll),
                                              ),
                                            );
                                            _refreshList();
                                          }
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete
                                      _actionButton(
                                          icon: Icons.delete_rounded,
                                          color: Colors.red[600]!,
                                          bg: Colors.red[50]!,
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: const Text("Delete Poll"),
                                                content: const Text("Are you sure you want to remove this poll permanently?"),
                                                actions: [
                                                  TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text("Cancel")),
                                                  TextButton(onPressed: ()=>Navigator.pop(context,true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              try {
                                                final response = await request.post(
                                                    'http://127.0.0.1:8000/landingpoll/delete/${poll.id}/',
                                                    {});
                                                if (response['status'] == 'success') {
                                                  _refreshList();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Poll deleted")),
                                                  );
                                                }
                                              } catch (e) { /* handle error */ }
                                            }
                                          }
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),

                          // Garis Pemisah Tipis
                          Divider(height: 1, color: Colors.grey[100]),

                          // 2. List Opsi dengan Progress Bar
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: poll.options.map((o) {
                                // Hitung persentase
                                double percent = totalVotes == 0 ? 0 : (o.votes / totalVotes);
                                String percentText = "${(percent * 100).toStringAsFixed(0)}%";

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Label Opsi & Persentase
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            o.optionText,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            "$percentText (${o.votes})",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: kPrimaryNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Bar Visualisasi
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: percent,
                                          backgroundColor: kBarGrey,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            // Highlight warna Lime jika vote tertinggi (opsional), atau Navy standar
                                              percent > 0.5 ? kAccentLime : const Color(0xFF4C6EF5)
                                          ),
                                          minHeight: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kecil untuk Tombol Edit/Delete
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}