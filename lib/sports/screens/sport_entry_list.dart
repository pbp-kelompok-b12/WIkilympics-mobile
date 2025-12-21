import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/sports/widgets/sport_entry_card.dart';
import 'package:wikilympics/sports/widgets/filter_sport.dart';
import 'package:wikilympics/sports/screens/sport_entry_form.dart';
import 'package:wikilympics/sports/screens/sport_entry_detail.dart';

class SportEntryListPage extends StatefulWidget {
  const SportEntryListPage({super.key});

  @override
  State<SportEntryListPage> createState() => _SportEntryListPageState();
}

class _SportEntryListPageState extends State<SportEntryListPage> {
  bool _isAdmin = false;

  String _searchQuery = "";
  List<String> _selectedSportTypes = [];
  List<String> _selectedParticipations = [];

  final List<String> _typeOptions = [
    'Water',
    'Strength',
    'Athletic',
    'Racket',
    'Ball',
    'Combat',
    'Target'
  ];
  final List<String> _partOptions = ['Team', 'Individual', 'Both'];

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
        final response =
            await request.get("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/status/");
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
        });
      } catch (e) {}
    }
  }

  Future<List<SportEntry>> fetchSports(CookieRequest request) async {
    final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//sports/json/');
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

  List<SportEntry> _applyFilters(List<SportEntry> allSports) {
    return allSports.where((sport) {
      final name = sport.fields.sportName.toLowerCase();
      if (!name.contains(_searchQuery)) return false;

      String rawType =
          sport.fields.sportType.toString().split('.').last.toUpperCase();
      String rawPart = sport.fields.participationStructure
          .toString()
          .split('.')
          .last
          .toUpperCase();

      if (_selectedSportTypes.isNotEmpty) {
        bool typeMatch = _selectedSportTypes.any((selected) =>
            rawType.contains(selected.toUpperCase()) ||
            selected.toUpperCase() == rawType);
        if (!typeMatch) return false;
      }

      if (_selectedParticipations.isNotEmpty) {
        bool partMatch = _selectedParticipations
            .any((selected) => rawPart == selected.toUpperCase());
        if (!partMatch) return false;
      }

      return true;
    }).toList();
  }

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
      backgroundColor: AppColors.kBgGrey,
    
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SportEntryFormPage()),
                );
                _refreshSports();
              },
              label: Text("ADD SPORT",
                  style: GoogleFonts.poppins(
                      color: AppColors.kSecondaryNavy, fontWeight: FontWeight.bold)),
              icon: Icon(Icons.add, color: AppColors.kSecondaryNavy),
              backgroundColor: AppColors.kAccentLime,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 7),
            decoration: BoxDecoration(
              color: AppColors.kBgGrey,
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
                            prefixIcon: Icon(Icons.search, color: AppColors.kSecondaryNavy),
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
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.kSecondaryNavy,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.kSecondaryNavy.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Center (
                            child: Icon(Icons.tune, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Olympic Sports",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kSecondaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
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
                                  style: GoogleFonts.poppins(
                                      color: AppColors.kSecondaryNavy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: AppColors.kSecondaryNavy),
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
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[600])),
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SportDetailPage(sport: filteredList[index]),
                            ),
                          );
                          _refreshSports();
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
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}