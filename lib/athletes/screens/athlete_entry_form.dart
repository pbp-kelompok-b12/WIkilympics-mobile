import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/athletes/models/athlete_entry.dart';

class AthleteEntryFormPage extends StatefulWidget {
  final AthleteEntry? athleteEntry;
  const AthleteEntryFormPage({super.key, this.athleteEntry});

  @override
  State<AthleteEntryFormPage> createState() => _AthleteEntryFormPageState();
}

class _AthleteEntryFormPageState extends State<AthleteEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _athleteName = "";
  String _country = "";
  String _sport = "";
  String _biography = "";
  String _athletePhoto = "";
  List<String> _sportOptions = [];
  List<String> _countryOptions = [];
  bool _loadingOptions = true;
  final Color kPrimaryNavy = const Color(0xFF03045E);
  final Color kAccentLime = const Color(0xFFD9E74C);
  final Color kBgGrey = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    if (widget.athleteEntry != null) {
      final f = widget.athleteEntry!.fields;
      _athleteName = f.athleteName;
      _country = f.country;
      _sport = f.sport;
      _biography = f.biography;
      _athletePhoto = f.athletePhoto;
    }
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/athletes/flutter/',
      );
      Set<String> sportSet = {};
      Set<String> countrySet = {};

      for (var d in response) {
        if (d != null) {
          final athlete = AthleteEntry.fromJson(d);
          if (athlete.fields.sport.isNotEmpty)
            sportSet.add(athlete.fields.sport);
          if (athlete.fields.country.isNotEmpty)
            countrySet.add(athlete.fields.country);
        }
      }

      if (widget.athleteEntry != null) {
        final f = widget.athleteEntry!.fields;
        sportSet.add(f.sport);
        countrySet.add(f.country);
      }

      if (mounted) {
        setState(() {
          _sportOptions = sportSet.toList()..sort();
          _countryOptions = countrySet.toList()..sort();
          _loadingOptions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) return "URL is not valid!";
    return null;
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
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

  Widget _buildDropdownFormField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryNavy, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryNavy),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Text(
                    isLoading ? "Loading..." : hint,
                    style: GoogleFonts.poppins(
                      color: isLoading ? Colors.grey : Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading ? null : onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _createFormData() {
    return {
      "athlete_name": _athleteName,
      "country": _country,
      "sport": _sport,
      "biography": _biography,
      "athlete_photo": _athletePhoto,
    };
  }

  Future<void> _submitForm(BuildContext context, bool isEdit) async {
    final request = context.read<CookieRequest>();
    try {
      Map<String, dynamic> response;
      if (isEdit) {
        response = await request.postJson(
          'http://127.0.0.1:8000/athletes/flutter/${widget.athleteEntry!.pk}/edit/',
          _createFormData(),
        );
      } else {
        response = await request.postJson(
          'http://127.0.0.1:8000/athletes/flutter/create/',
          _createFormData(),
        );
      }

      if (context.mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? "Athlete updated!" : "Athlete added!"),
              backgroundColor: kAccentLime,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: kPrimaryNavy,
                onPressed: () {},
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to save athlete."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.athleteEntry != null;

    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      isEdit ? "Edit Athlete" : "Add New Athlete",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    initialValue: _athleteName,
                    decoration: _buildInputDecoration(
                      "Athlete Name",
                      Icons.person,
                    ),
                    style: GoogleFonts.poppins(color: kPrimaryNavy),
                    onChanged: (value) => _athleteName = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Athlete name cannot be empty!"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField(
                    hint: "Select Country",
                    icon: Icons.flag,
                    value: _country.isNotEmpty ? _country : null,
                    options: _countryOptions,
                    isLoading: _loadingOptions,
                    onChanged: (val) => setState(() => _country = val ?? ""),
                    validator: (value) =>
                        value == null ? "Please select country!" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField(
                    hint: "Select Sport",
                    icon: Icons.sports,
                    value: _sport.isNotEmpty ? _sport : null,
                    options: _sportOptions,
                    isLoading: _loadingOptions,
                    onChanged: (val) => setState(() => _sport = val ?? ""),
                    validator: (value) =>
                        value == null ? "Please select sport!" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _biography,
                    maxLines: 5,
                    decoration:
                        _buildInputDecoration(
                          "Biography",
                          Icons.description,
                        ).copyWith(
                          alignLabelWithHint: true,
                          prefixIcon: Container(
                            height: 100,
                            width: 40,
                            alignment: Alignment.topCenter,
                            child: Icon(Icons.description, color: kPrimaryNavy),
                          ),
                        ),
                    style: GoogleFonts.poppins(color: kPrimaryNavy),
                    onChanged: (value) => _biography = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Biography cannot be empty!"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _athletePhoto,
                    decoration: _buildInputDecoration(
                      "Athlete Photo URL (Optional)",
                      Icons.image,
                    ),
                    style: GoogleFonts.poppins(color: kPrimaryNavy),
                    onChanged: (value) => _athletePhoto = value,
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 32),
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
                            await _submitForm(context, isEdit);
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
