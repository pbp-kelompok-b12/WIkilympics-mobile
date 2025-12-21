import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/sports/models/sport_entry.dart';

class SportEntryFormPage extends StatefulWidget {
  final SportEntry? sportEntry;

  const SportEntryFormPage({super.key, this.sportEntry});

  @override
  State<SportEntryFormPage> createState() => _SportEntryFormPageState();
}

class _SportEntryFormPageState extends State<SportEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

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

  final List<String> _sportTypes = [
    'water_sport',
    'strength_sport',
    'athletic_sport',
    'racket_sport',
    'ball_sport',
    'combat_sport',
    'target_sport'
  ];

  final List<String> _participations = ['both', 'individual', 'team'];

  @override
  void initState() {
    super.initState();
    if (widget.sportEntry != null) {
      final f = widget.sportEntry!.fields;
      _sportName = f.sportName;
      _countryOfOrigin = f.countryOfOrigin;
      _firstYearPlayed = f.firstYearPlayed.toString();
      _equipment = f.equipment;
      _sportImg = f.sportImg;
      _countryFlagImg = f.countryFlagImg;
      _sportDescription = f.sportDescription;
      _historyDescription = f.historyDescription;

      String typeRaw = f.sportType.toString().split('.').last.toLowerCase();
      if (_sportTypes.contains(typeRaw)) {
        _sportType = typeRaw;
      } else if (_sportTypes.contains("${typeRaw}_sport")) {
        _sportType = "${typeRaw}_sport";
      }

      String partRaw = f.participationStructure.toString().split('.').last.toLowerCase();
      if (_participations.contains(partRaw)) {
        _participation = partRaw;
      }
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) {
      return "URL is not valid!";
    }
    return null;
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.kSecondaryNavy),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.kSecondaryNavy, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.kSecondaryNavy, width: 2.0),
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
          child: Icon(icon, color: AppColors.kSecondaryNavy),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.sportEntry != null;

    return Scaffold(
      backgroundColor: AppColors.kBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.kBgGrey,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      isEdit ? "Edit Sport" : "Add New Sport",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kSecondaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    initialValue: _sportName,
                    decoration: _buildInputDecoration("Sport Name", Icons.sports_soccer),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _sportName = value,
                    validator: (value) {
                        if (value == null || value.isEmpty) return "Name cannot be empty!";
                        if (value.length > 255) return "Name cannot exceed 255 characters!";
                        return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration("Type", Icons.category),
                          value: _sportType,
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.kSecondaryNavy),
                          isExpanded: true,
                          items: _sportTypes
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t.replaceAll("_", " ").toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _sportType = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration("Partic.", Icons.groups),
                          value: _participation,
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.kSecondaryNavy),
                          isExpanded: true,
                          items: _participations
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p.toUpperCase(),
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _participation = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _countryOfOrigin,
                    decoration: _buildInputDecoration("Country of Origin", Icons.public),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _countryOfOrigin = value,
                    validator: (value) {
                        if (value == null || value.isEmpty) return "Country cannot be empty!";
                        if (value.length > 255) return "Country cannot exceed 255 characters!";
                        return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _firstYearPlayed,
                    decoration: _buildInputDecoration(
                        "First Year Played (e.g., 1890)", Icons.calendar_month),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _firstYearPlayed = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Year cannot be empty!";
                      }

                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return "Year must be a valid number!";
                      }
                      if (parsed <= 0) {
                        return "Year must be > 0!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _equipment,
                    decoration: _buildInputDecoration("Equipment", Icons.fitness_center),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _equipment = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Equipment cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _sportImg,
                          decoration: _buildInputDecoration("Sport Img URL", Icons.image),
                          style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                          onChanged: (value) => _sportImg = value,
                          validator: _validateUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _countryFlagImg,
                          decoration: _buildInputDecoration("Flag Img URL", Icons.flag),
                          style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                          onChanged: (value) => _countryFlagImg = value,
                          validator: _validateUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _sportDescription,
                    maxLines: 4,
                    decoration: _buildMultilineDecoration("Sport Description", Icons.description),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _sportDescription = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Description cannot be empty!" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _historyDescription,
                    maxLines: 4,
                    decoration: _buildMultilineDecoration("History Description", Icons.history_edu),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _historyDescription = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "History cannot be empty!" : null,
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kAccentLime,
                          foregroundColor: AppColors.kSecondaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String url;
                            if (isEdit) {
                              url =
                                  "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/sports/edit-flutter/${widget.sportEntry!.pk}/";
                            } else {
                              url = "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/sports/create-flutter/";
                            }

                            final response = await request.postJson(
                              url,
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
                                    content: Text(isEdit ? "Data updated!" : "Sport added!"),
                                    backgroundColor: AppColors.kAccentLime,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                        label: 'OK',
                                        textColor: AppColors.kSecondaryNavy,
                                        onPressed: () {}),
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
                          children: [
                            Text(
                              isEdit ? "UPDATE" : "SAVE",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.check_circle_outline, size: 18)
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