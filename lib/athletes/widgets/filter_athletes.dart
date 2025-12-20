// lib/athletes/widgets/athlete_filter.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AthleteFilter extends StatefulWidget {
  final List<String> sports;
  final List<String> countries;
  final Function(String?, String?) onFilterChanged;

  const AthleteFilter({
    super.key,
    required this.sports,
    required this.countries,
    required this.onFilterChanged,
  });

  @override
  State<AthleteFilter> createState() => _AthleteFilterState();
}

class _AthleteFilterState extends State<AthleteFilter> {
  String? _selectedSport;
  String? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Athletes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF03045E),
            ),
          ),

          const SizedBox(height: 16),

          // Sport Filter
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Sport',
              labelStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.sports),
            ),
            value: _selectedSport,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Sports')),
              ...widget.sports.map((sport) {
                return DropdownMenuItem(value: sport, child: Text(sport));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSport = value;
              });
              widget.onFilterChanged(_selectedSport, _selectedCountry);
            },
          ),

          const SizedBox(height: 16),

          // Country Filter
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Country',
              labelStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.flag),
            ),
            value: _selectedCountry,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Countries')),
              ...widget.countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
              widget.onFilterChanged(_selectedSport, _selectedCountry);
            },
          ),

          const SizedBox(height: 16),

          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSport = null;
                  _selectedCountry = null;
                });
                widget.onFilterChanged(null, null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear Filters',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
