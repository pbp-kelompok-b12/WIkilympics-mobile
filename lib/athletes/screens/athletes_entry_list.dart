// screens/athlete_entry_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/athletes/models/athlete_entry.dart';
import 'package:wikilympics/athletes/widgets/athlete_entry_card.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_form.dart';
import 'package:wikilympics/athletes/screens/athlete_entry_detail.dart';

class AthleteEntryListPage extends StatefulWidget {
  const AthleteEntryListPage({super.key});

  @override
  State<AthleteEntryListPage> createState() => _AthleteEntryListPageState();
}

class _AthleteEntryListPageState extends State<AthleteEntryListPage> {
  // Color Palette
  final Color kPrimaryBlue = const Color(0xFF1E3CC8);
  final Color kAccentYellow = const Color(0xFFFFD700);
  final Color kBgWhite = const Color(0xFFF9F9F9);
  final Color kDarkNavy = const Color(0xFF0B162C);

  // State Variables
  bool _isAdmin = false;
  String _searchQuery = "";
  String _selectedSport = "";
  String _selectedCountry = "";
  List<String> _sportOptions = [];
  List<String> _countryOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
      _loadFilterOptions();
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
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _loadFilterOptions() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/athletes/json/',
      );

      Set<String> sports = {};
      Set<String> countries = {};

      for (var item in response) {
        var athlete = AthleteEntry.fromJson(item);
        sports.add(athlete.fields.sport);
        countries.add(athlete.fields.country);
      }

      setState(() {
        _sportOptions = sports.toList()..sort();
        _countryOptions = countries.toList()..sort();
      });
    } catch (e) {
      print("Error loading filter options: $e");
    }
  }

  Future<List<AthleteEntry>> fetchAthletes(CookieRequest request) async {
    try {
      print("Fetching athletes from Django...");
      final response = await request.get(
        'http://127.0.0.1:8000/athletes/flutter/',
      );

      print("Response type: ${response.runtimeType}");
      print("Response: $response");

      if (response is List) {
        print("Response is a list with ${response.length} items");
        if (response.isNotEmpty) {
          print("First item: ${response.first}");
        }

        List<AthleteEntry> listAthletes = [];
        for (var d in response) {
          if (d != null) {
            try {
              listAthletes.add(AthleteEntry.fromJson(d));
            } catch (e) {
              print("Error parsing athlete: $e");
              print("Problematic data: $d");
            }
          }
        }
        print("Successfully parsed ${listAthletes.length} athletes");
        return listAthletes;
      } else {
        print("Unexpected response format: $response");
        return [];
      }
    } catch (e) {
      print("Error fetching athletes: $e");
      return [];
    }
  }

  void _refreshAthletes() {
    setState(() {});
  }

  // Filter Logic
  List<AthleteEntry> _applyFilters(List<AthleteEntry> allAthletes) {
    return allAthletes.where((athlete) {
      final name = athlete.fields.athleteName.toLowerCase();
      final sport = athlete.fields.sport.toLowerCase();
      final country = athlete.fields.country.toLowerCase();

      if (_searchQuery.isNotEmpty && !name.contains(_searchQuery)) {
        return false;
      }

      if (_selectedSport.isNotEmpty && sport != _selectedSport.toLowerCase()) {
        return false;
      }

      if (_selectedCountry.isNotEmpty &&
          country != _selectedCountry.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgWhite,
      appBar: AppBar(
        title: Image.asset(
          'assets/wikilympics_banner.png',
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) => Text(
            "WikiLympics Athletes",
            style: GoogleFonts.poppins(
              color: kPrimaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: kBgWhite,
        iconTheme: IconThemeData(color: kPrimaryBlue),
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
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.add, color: kPrimaryBlue),
              backgroundColor: kAccentYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 7),
            decoration: BoxDecoration(
              color: kBgWhite,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
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
                      prefixIcon: Icon(Icons.search, color: kPrimaryBlue),
                      hintText: "Search athletes...",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Filters Row
                Row(
                  children: [
                    // Sport Filter
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedSport.isEmpty ? null : _selectedSport,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: kPrimaryBlue,
                          ),
                          hint: Text(
                            "All Sports",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: "",
                              child: Text("All Sports"),
                            ),
                            ..._sportOptions.map(
                              (sport) => DropdownMenuItem(
                                value: sport,
                                child: Text(sport),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSport = value ?? "";
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Country Filter
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCountry.isEmpty
                              ? null
                              : _selectedCountry,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: kPrimaryBlue,
                          ),
                          hint: Text(
                            "All Countries",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: "",
                              child: Text("All Countries"),
                            ),
                            ..._countryOptions.map(
                              (country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value ?? "";
                            });
                          },
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
                    "Olympic Athletes",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Active Filters
                if (_selectedSport.isNotEmpty || _selectedCountry.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedSport.isNotEmpty)
                            _buildChip(
                              "Sport: $_selectedSport",
                              Colors.blue.shade50,
                            ),
                          if (_selectedCountry.isNotEmpty)
                            _buildChip(
                              "Country: $_selectedCountry",
                              Colors.orange.shade50,
                            ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedSport = "";
                              _selectedCountry = "";
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Clear Filters",
                                style: GoogleFonts.poppins(
                                  color: kPrimaryBlue,
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

          // List Content
          Expanded(
            child: FutureBuilder<List<AthleteEntry>>(
              future: fetchAthletes(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          'No athletes yet.',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: kPrimaryBlue,
                          ),
                        ),
                        if (_isAdmin)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AthleteEntryFormPage(),
                                  ),
                                );
                                _refreshAthletes();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccentYellow,
                                foregroundColor: kPrimaryBlue,
                              ),
                              child: Text(
                                "Add First Athlete",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSport = "";
                                _selectedCountry = "";
                                _searchQuery = "";
                              });
                            },
                            child: Text(
                              "Clear All Filters",
                              style: GoogleFonts.poppins(),
                            ),
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
