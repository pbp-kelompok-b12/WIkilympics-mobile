// lib/athletes/screens/athletes_entry_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/athletes/models/athlete_entry.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/athletes/widgets/athlete_entry_card.dart';
import 'package:wikilympics/athletes/widgets/filter_athletes.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_form.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_detail.dart';

class AthleteEntryListPage extends StatefulWidget {
  const AthleteEntryListPage({super.key});

  @override
  State<AthleteEntryListPage> createState() => _AthleteEntryListPageState();
}

class _AthleteEntryListPageState extends State<AthleteEntryListPage> {
  // === COLOR PALETTE ===
  final Color kPrimaryNavy = const Color(0xFF03045E); // Dark Blue
  final Color kBgGrey = const Color(0xFFF9F9F9);
  final Color kAccentLime = const Color(0xFFD9E74C); // Yellow

  // === ADMIN STATE ===
  bool _isAdmin = false;

  // === FILTER STATE ===
  String _searchQuery = "";
  List<String> _selectedSports = [];
  List<String> _selectedCountries = [];

  // === DYNAMIC OPTIONS ===
  List<String> _sportOptions = [];
  List<String> _countryOptions = [];

  @override
  void initState() {
    super.initState();
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
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      } catch (e) {}
    }
  }

  Future<List<AthleteEntry>> fetchAthletes(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/athletes/json/');
    List<AthleteEntry> listAthletes = [];

    Set<String> sportSet = {};
    Set<String> countrySet = {};

    for (var d in response) {
      if (d != null) {
        final athlete = AthleteEntry.fromJson(d);
        listAthletes.add(athlete);

        // Collect unique sports
        if (athlete.fields.sport.isNotEmpty) {
          sportSet.add(athlete.fields.sport);
        }

        // Collect unique countries
        if (athlete.fields.country.isNotEmpty) {
          countrySet.add(athlete.fields.country);
        }
      }
    }

    // Update filter options
    if (mounted) {
      setState(() {
        _sportOptions = sportSet.toList()..sort();
        _countryOptions = countrySet.toList()..sort();
      });
    }

    return listAthletes;
  }

  void _refreshAthletes() {
    setState(() {});
  }

  // === FILTER LOGIC ===
  List<AthleteEntry> _applyFilters(List<AthleteEntry> allAthletes) {
    return allAthletes.where((athlete) {
      final name = athlete.fields.athleteName.toLowerCase();
      if (!name.contains(_searchQuery.toLowerCase())) return false;

      if (_selectedSports.isNotEmpty) {
        bool sportMatch = _selectedSports.any(
          (selected) =>
              athlete.fields.sport.toLowerCase() == selected.toLowerCase(),
        );
        if (!sportMatch) return false;
      }

      if (_selectedCountries.isNotEmpty) {
        bool countryMatch = _selectedCountries.any(
          (selected) =>
              athlete.fields.country.toLowerCase() == selected.toLowerCase(),
        );
        if (!countryMatch) return false;
      }

      return true;
    }).toList();
  }

  // === SHOW FILTER MODAL ===
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterAthleteSheet(
        initialSports: _selectedSports,
        initialCountries: _selectedCountries,
        sportOptions: _sportOptions,
        countryOptions: _countryOptions,
        onApply: (sports, countries) {
          setState(() {
            _selectedSports = sports;
            _selectedCountries = countries;
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
          errorBuilder: (ctx, _, __) => Text(
            "WikiLympics",
            style: GoogleFonts.poppins(
              color: kPrimaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: kBgGrey,
        iconTheme: IconThemeData(color: kPrimaryNavy),
        elevation: 0,
      ),
      drawer: const LeftDrawer(),

      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AthleteEntryFormPage(),
                  ),
                );
                _refreshAthletes();
              },
              label: Text(
                "ADD ATHLETE",
                style: GoogleFonts.poppins(
                  color: kPrimaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.add, color: kPrimaryNavy),
              backgroundColor: kAccentLime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,

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
                            hintText: "Search athletes...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 18,
                            ),
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

                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Olympic Athletes",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                if (_selectedSports.isNotEmpty || _selectedCountries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._selectedSports.map(
                            (e) => _buildChip(e, Colors.blue.shade50),
                          ),
                          ..._selectedCountries.map(
                            (e) => _buildChip(e, Colors.orange.shade50),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedSports.clear();
                              _selectedCountries.clear();
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Clear All",
                                style: GoogleFonts.poppins(
                                  color: kPrimaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // === LIST CONTENT ===
          Expanded(
            child: FutureBuilder<List<AthleteEntry>>(
              future: fetchAthletes(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No athletes found.',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: kPrimaryNavy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _refreshAthletes,
                          child: const Text('Retry'),
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
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No athletes match your filters.",
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 0,
                      left: 20,
                      right: 20,
                      bottom: 80,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return AthleteEntryCard(
                        athlete: filteredList[index],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AthleteDetailPage(
                                athlete: filteredList[index],
                              ),
                            ),
                          );
                          _refreshAthletes();
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
