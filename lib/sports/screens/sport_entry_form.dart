import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class SportEntryFormPage extends StatefulWidget {
  const SportEntryFormPage({super.key});

  @override
  State<SportEntryFormPage> createState() => _SportEntryFormPageState();
}

class _SportEntryFormPageState extends State<SportEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  // === FORM FIELDS ===
  String _sportName = "";
  String _sportType = "ball_sport";
  String _participation = "team";
  String _countryOfOrigin = "";
  String _firstYearPlayed = "";
  String _equipment = "";
  String _sportImg = "";
  String _countryFlagImg = "";
  String _sportDescription = "";
  String _historyDescription = "";

  // === COLOR PALETTE ===
  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kAccentLime = const Color(0xFFD9E74C);
  final Color kBgGrey = const Color(0xFFF9F9F9);

  final List<String> _sportTypes = [
    'water_sport', 'strength_sport', 'athletic_sport',
    'racket_sport', 'ball_sport', 'combat_sport', 'target_sport'
  ];

  final List<String> _participations = [
    'both', 'individual', 'team'
  ];

  // === VALIDATOR HELPER (UPDATED) ===
  // Menggunakan logika Uri.tryParse sesuai request
  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return "URL cannot be empty!";
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath || !(uri.isScheme("http") || uri.isScheme("https"))) {
      return "URL is not valid!";
    }

    return null;
  }

  // === STYLE HELPER ===
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(icon, color: kPrimaryNavy),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kPrimaryNavy, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kPrimaryNavy, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  InputDecoration _buildMultilineDecoration(String hint, IconData icon) {
    return _buildInputDecoration(hint, icon).copyWith(
      alignLabelWithHint: true,
      prefixIcon: Container(
        height: 100,
        width: 40,
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: Icon(icon, color: kPrimaryNavy),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
//         title: const Text(
//           "Back",
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//         titleSpacing: 0,
        backgroundColor: kBgGrey,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // === HEADER ===
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Add New Sport",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 1. Sport Name
                  TextFormField(
                    decoration: _buildInputDecoration("Sport Name", Icons.sports_soccer),
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _sportName = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Name cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Row (Type & Participation)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration("Type", Icons.category),
                          value: _sportType,
                          icon: Icon(Icons.arrow_drop_down, color: kPrimaryNavy),
                          isExpanded: true,
                          items: _sportTypes.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.replaceAll("_", " ").toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )).toList(),
                          onChanged: (val) => setState(() => _sportType = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration("Partic.", Icons.groups),
                          value: _participation,
                          icon: Icon(Icons.arrow_drop_down, color: kPrimaryNavy),
                          isExpanded: true,
                          items: _participations.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          )).toList(),
                          onChanged: (val) => setState(() => _participation = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Country of Origin
                  TextFormField(
                    decoration: _buildInputDecoration("Country of Origin", Icons.public),
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _countryOfOrigin = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Country cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),

                  // 4. First Year Played (Number) - UPDATED VALIDATION
                  TextFormField(
                    decoration: _buildInputDecoration("First Year Played (e.g., 1890)", Icons.calendar_month),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _firstYearPlayed = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Year cannot be empty!";
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return "Year must be a valid number!";
                      }
                      if (parsed <= 0) { // Validasi tidak boleh 0 atau negatif
                        return "Year must be greater than 0!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                   // 5. Equipment
                  TextFormField(
                    decoration: _buildInputDecoration("Equipment", Icons.fitness_center),
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _equipment = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Equipment cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),

                  // 6. Image URLs (Row) - UPDATED WITH URI VALIDATION
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: _buildInputDecoration("Sport Img URL", Icons.image),
                          style: TextStyle(color: kPrimaryNavy),
                          onChanged: (value) => _sportImg = value,
                          validator: _validateUrl, // Panggil fungsi helper baru
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: _buildInputDecoration("Flag Img URL", Icons.flag),
                          style: TextStyle(color: kPrimaryNavy),
                          onChanged: (value) => _countryFlagImg = value,
                          validator: _validateUrl, // Panggil fungsi helper baru
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. Sport Description (Multiline)
                  TextFormField(
                    maxLines: 4,
                    decoration: _buildMultilineDecoration("Sport Description", Icons.description),
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _sportDescription = value,
                    validator: (value) => (value == null || value.isEmpty) ? "Description cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),

                  // 8. History Description (Multiline)
                  TextFormField(
                    maxLines: 4,
                    decoration: _buildMultilineDecoration("History Description", Icons.history_edu),
                    style: TextStyle(color: kPrimaryNavy),
                    onChanged: (value) => _historyDescription = value,
                    validator: (value) => (value == null || value.isEmpty) ? "History cannot be empty!" : null,
                  ),
                  const SizedBox(height: 32),

                  // === SUBMIT BUTTON ===
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentLime,
                          foregroundColor: kPrimaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Kirim ke Django
                            final response = await request.postJson(
                              "http://127.0.0.1:8000/sports/create-flutter/",
                              jsonEncode({
                                "sport_name": _sportName,
                                "sport_img": _sportImg,
                                "sport_description": _sportDescription,
                                "participation_structure": _participation,
                                "sport_type": _sportType,
                                "country_of_origin": _countryOfOrigin,
                                "country_flag_img": _countryFlagImg,
                                "first_year_played": int.parse(_firstYearPlayed),
                                "history_description": _historyDescription,
                                "equipment": _equipment,
                              }),
                            );

                            if (context.mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Sport added successfully!"),
                                      backgroundColor: kAccentLime,
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'OK',
                                        textColor: kPrimaryNavy,
                                        onPressed: (){}
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Failed to save sport."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                             Text(
                              "SAVE",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.check_circle_outline, size: 18)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}