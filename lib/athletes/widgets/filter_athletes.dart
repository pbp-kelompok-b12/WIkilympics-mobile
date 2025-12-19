// lib/athletes/widgets/filter_athletes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterAthleteSheet extends StatefulWidget {
  final List<String> initialSports;
  final List<String> initialCountries;
  final List<String> sportOptions;
  final List<String> countryOptions;
  final Function(List<String>, List<String>) onApply;

  const FilterAthleteSheet({
    super.key,
    required this.initialSports,
    required this.initialCountries,
    required this.sportOptions,
    required this.countryOptions,
    required this.onApply,
  });

  @override
  State<FilterAthleteSheet> createState() => _FilterAthleteSheetState();
}

class _FilterAthleteSheetState extends State<FilterAthleteSheet> {
  late List<String> _tempSports;
  late List<String> _tempCountries;

  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kAccentLime = const Color(0xFFD9E74C);
  final Color kSoftGrey = const Color(0xFFF0F0F0);

  @override
  void initState() {
    super.initState();
    _tempSports = List.from(widget.initialSports);
    _tempCountries = List.from(widget.initialCountries);
  }

  IconData _getIconForSport(String sport) {
    if (sport.toLowerCase().contains('swim')) return Icons.pool;
    if (sport.toLowerCase().contains('run')) return Icons.directions_run;
    if (sport.toLowerCase().contains('ball')) return Icons.sports_basketball;
    if (sport.toLowerCase().contains('gym')) return Icons.fitness_center;
    if (sport.toLowerCase().contains('fight')) return Icons.sports_martial_arts;
    if (sport.toLowerCase().contains('cycle')) return Icons.directions_bike;
    return Icons.sports;
  }

  IconData _getIconForCountry(String country) {
    return Icons.flag;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- HEADER MODAL ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Athletes",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // --- CONTENT SCROLLABLE ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (widget.sportOptions.isNotEmpty) ...[
                  _buildSectionTitle("Sport"),
                  const SizedBox(height: 10),
                  ...widget.sportOptions.map(
                    (opt) => _buildCustomCheckbox(
                      opt,
                      _tempSports,
                      icon: _getIconForSport(opt),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                if (widget.countryOptions.isNotEmpty) ...[
                  _buildSectionTitle("Country"),
                  const SizedBox(height: 10),
                  ...widget.countryOptions.map(
                    (opt) => _buildCustomCheckbox(
                      opt,
                      _tempCountries,
                      icon: _getIconForCountry(opt),
                    ),
                  ),
                ],

                if (widget.sportOptions.isEmpty &&
                    widget.countryOptions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No filter options available",
                        style: GoogleFonts.poppins(color: Colors.grey[500]),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // --- FOOTER BUTTONS ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _tempSports.clear();
                      _tempCountries.clear();
                    }),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Reset",
                      style: GoogleFonts.poppins(
                        color: kPrimaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSports, _tempCountries);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Apply Filters",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCustomCheckbox(
    String label,
    List<String> currentList, {
    required IconData icon,
  }) {
    final isSelected = currentList.contains(label);

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          currentList.remove(label);
        } else {
          currentList.add(label);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? kPrimaryNavy : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? kAccentLime : kSoftGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: kPrimaryNavy),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: kPrimaryNavy,
                ),
              ),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryNavy,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
