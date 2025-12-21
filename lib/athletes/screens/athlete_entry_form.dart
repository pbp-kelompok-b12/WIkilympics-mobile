// screens/athlete_entry_form.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/athletes/models/athlete_entry.dart';

class AthleteEntryFormPage extends StatefulWidget {
  final AthleteEntry? athleteEntry;

  const AthleteEntryFormPage({super.key, this.athleteEntry});

  @override
  State<AthleteEntryFormPage> createState() => _AthleteEntryFormPageState();
}

class _AthleteEntryFormPageState extends State<AthleteEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String _athleteName = "";
  String _country = "";
  String _sport = "";
  String _biography = "";
  String _athletePhoto = "";

  // screens/athlete_entry_form.dart - bagian initState
  @override
  void initState() {
    super.initState();
    if (widget.athleteEntry != null) {
      _athleteName = widget.athleteEntry!.fields.athleteName;
      _country = widget.athleteEntry!.fields.country;
      _sport = widget.athleteEntry!.fields.sport;
      _biography = widget.athleteEntry!.fields.biography;
      _athletePhoto = widget.athleteEntry!.fields.athletePhoto;
    }
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

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) {
      return "URL is not valid!";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.athleteEntry != null;

    return Scaffold(
      backgroundColor: AppColors.kBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.kBgGrey,
        elevation: 0,
        title: Text(
          isEdit ? "Edit Athlete" : "Add New Athlete",
          style: GoogleFonts.poppins(
            color: AppColors.kSecondaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      isEdit ? "Edit Athlete" : "Add New Athlete",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kSecondaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Athlete Name
                  TextFormField(
                    initialValue: _athleteName,
                    decoration: _buildInputDecoration(
                      "Athlete Name",
                      Icons.person,
                    ),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _athleteName = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Name cannot be empty!"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Row (Country & Sport)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _country,
                          decoration: _buildInputDecoration(
                            "Country",
                            Icons.flag,
                          ),
                          style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                          onChanged: (value) => _country = value,
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Country cannot be empty!"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _sport,
                          decoration: _buildInputDecoration(
                            "Sport",
                            Icons.sports,
                          ),
                          style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                          onChanged: (value) => _sport = value,
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Sport cannot be empty!"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Athlete Photo URL
                  TextFormField(
                    initialValue: _athletePhoto,
                    decoration: _buildInputDecoration(
                      "Photo URL (optional)",
                      Icons.image,
                    ),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _athletePhoto = value,
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 16),

                  // Biography
                  TextFormField(
                    initialValue: _biography,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Biography",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        height: 100,
                        width: 40,
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: const Offset(0, 0),
                          child: Icon(Icons.description, color: AppColors.kSecondaryNavy),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
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
                    ),
                    style: GoogleFonts.poppins(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _biography = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Biography cannot be empty!"
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
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
                                  "http://localhost:8000/athletes/flutter/${widget.athleteEntry!.pk}/edit/";
                            } else {
                              url =
                                  "http://localhost:8000/athletes/flutter/create/";
                            }

                            final response = await request.postJson(
                              url,
                              jsonEncode({
                                "athlete_name": _athleteName,
                                "country": _country,
                                "sport": _sport,
                                "biography": _biography,
                                "athlete_photo": _athletePhoto,
                              }),
                            );

                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEdit
                                          ? "Athlete updated!"
                                          : "Athlete added!",
                                    ),
                                    backgroundColor: AppColors.kAccentLime,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'OK',
                                      textColor: AppColors.kSecondaryNavy,
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response['message'] ??
                                          "Failed to save athlete.",
                                    ),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.check_circle_outline, size: 18),
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
