import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/sports/widgets/sport_entry_card.dart';
import 'package:wikilympics/sports/widgets/filter_sport.dart';
// IMPORT HALAMAN FORM
import 'package:wikilympics/sports/screens/sport_entry_form.dart';

class SportEntryListPage extends StatefulWidget {
  const SportEntryListPage({super.key});

  @override
  State<SportEntryListPage> createState() => _SportEntryListPageState();
}

class _SportEntryListPageState extends State<SportEntryListPage> {
  // === COLOR PALETTE ===
  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kBgGrey = const Color(0xFFF9F9F9);
  final Color kAccentLime = const Color(0xFFD9E74C); // Dibutuhkan untuk tombol

  // === ADMIN STATE ===
  bool _isAdmin = false;

  // === FILTER STATE ===
  String _searchQuery = "";
  List<String> _selectedSportTypes = [];
  List<String> _selectedParticipations = [];

  final List<String> _typeOptions = [
    'Ball', 'Target', 'Water', 'Combat', 'Athletics', 'Gymnastics'
  ];
  final List<String> _partOptions = ['Team', 'Individual', 'Both'];

  @override
  void initState() {
    super.initState();
    // Cek status admin saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  // === FUNGSI CEK ADMIN (Sama seperti Article) ===
  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();

    if (request.loggedIn) {
      // Pastikan URL auth status benar
      final response = await request.get("http://127.0.0.1:8000/auth/status/");

      setState(() {
        _isAdmin = response['is_superuser'] ?? false;
      });
    }
  }

  Future<List<SportEntry>> fetchSports(CookieRequest request) async {
    // Sesuaikan URL jika pakai Emulator Android (10.0.2.2)
    final response = await request.get('http://127.0.0.1:8000/sports/json/');
    List<SportEntry> listSports = [];
    for (var d in response) {
      if (d != null) {
        listSports.add(SportEntry.fromJson(d));
      }
    }
    return listSports;
  }

  void _refreshSports() {
    setState(() {});
  }

  // === FILTER LOGIC ===
  List<SportEntry> _applyFilters(List<SportEntry> allSports) {
    return allSports.where((sport) {
      // 1. Search Query
      final name = sport.fields.sportName.toLowerCase();
      if (!name.contains(_searchQuery)) return false;

      String rawType = sport.fields.sportType.toString().split('.').last.toUpperCase();
      String rawPart = sport.fields.participationStructure.toString().split('.').last.toUpperCase();

      // 2. Filter Sport Type
      if (_selectedSportTypes.isNotEmpty) {
        bool typeMatch = _selectedSportTypes.any((selected) =>
            rawType.contains(selected.toUpperCase()) ||
            selected.toUpperCase() == rawType);
        if (!typeMatch) return false;
      }

      // 3. Filter Participation
      if (_selectedParticipations.isNotEmpty) {
        bool partMatch = _selectedParticipations
            .any((selected) => rawPart == selected.toUpperCase());
        if (!partMatch) return false;
      }

      return true;
    }).toList();
  }

  // === SHOW MODAL ===
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSportSheet(
        initialTypes: _selectedSportTypes,
        initialParts: _selectedParticipations,
        typeOptions: _typeOptions,
        partOptions: _partOptions,
        onApply: (types, parts) {
          setState(() {
            _selectedSportTypes = types;
            _selectedParticipations = parts;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        title: Image.asset(
          'assets/wikilympics_banner.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        backgroundColor: kBgGrey,
        iconTheme: IconThemeData(color: kPrimaryNavy),
        elevation: 0,
      ),
      drawer: const LeftDrawer(),

      // === FLOATING ACTION BUTTON (Hanya Admin) ===
      floatingActionButton: _isAdmin
        ? FloatingActionButton.extended(
            onPressed: () async {
              // Navigasi ke Form Page
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SportEntryFormPage()),
              );
              // Refresh halaman setelah kembali dari form
              _refreshSports();
            },
            label: Text("ADD SPORT", style: TextStyle(color: kPrimaryNavy, fontWeight: FontWeight.bold)),
            icon: Icon(Icons.add, color: kPrimaryNavy),
            backgroundColor: kAccentLime,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )
        : null, // Jika bukan admin, tombol tidak muncul

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER SECTION ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 7),
            decoration: BoxDecoration(
              color: kBgGrey,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.toLowerCase()),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: kPrimaryNavy),
                            hintText: "Search sports...",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.black87, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Filter Button
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: kPrimaryNavy,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: kPrimaryNavy.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "FILTERS",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // Title
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Olympic Sports",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Active Chips
                if (_selectedSportTypes.isNotEmpty ||
                    _selectedParticipations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._selectedSportTypes
                              .map((e) => _buildChip(e, Colors.blue.shade50)),
                          ..._selectedParticipations
                              .map((e) => _buildChip(e, Colors.orange.shade50)),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedSportTypes.clear();
                              _selectedParticipations.clear();
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Clear All",
                                  style: TextStyle(
                                      color: kPrimaryNavy, fontSize: 12)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // === LIST CONTENT ===
          Expanded(
            child: FutureBuilder<List<SportEntry>>(
              future: fetchSports(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No sports yet.',
                          style: TextStyle(fontSize: 20, color: kPrimaryNavy),
                        ),
                      ],
                    ),
                  );
                } else {
                  final filteredList = _applyFilters(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text("No sports match your filters.",
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 0, left: 20, right: 20, bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return SportEntryCard(
                        sport: filteredList[index],
                        onTap: () {
                          // Handle Navigation or Detail here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Clicked: ${filteredList[index].fields.sportName}")),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}