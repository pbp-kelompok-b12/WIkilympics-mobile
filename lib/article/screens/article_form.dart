import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/article/models/article_entry.dart';

class ArticleFormPage extends StatefulWidget {
  final ArticleEntry? article;
  const ArticleFormPage({super.key, this.article});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String _category = "football";
  String _thumbnail = "";

  final List<String> _categories = [
    'athletics', 'archery', 'artistic_gymnastics', 'artistic_swimming',
    'badminton', 'baseball_softball', 'basketball', 'beach_volleyball',
    'boxing', 'canoe_slalom', 'cycling_road', 'diving', 'fencing',
    'football', 'handball', 'hockey', 'judo', 'karate', 'marathon_swimming',
    'rowing', 'rhythmic_gymnastics', 'sailing', 'shooting', 'swimming',
    'table_tennis', 'taekwondo', 'trampoline_gymnastics', 'triathlon',
    'water_polo', 'weightlifting', 'wrestling',
  ];

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _title = widget.article!.title;
      _content = widget.article!.content;
      _category = widget.article!.category;
      _thumbnail = widget.article!.thumbnail;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.kBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Back",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        titleSpacing: 0,
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
                  
                  // === JUDUL ===
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      widget.article == null ? "Add Article" : "Edit Article",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.kSecondaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 1. Title
                  TextFormField(
                    initialValue: _title,
                    decoration: _buildInputDecoration("Article Title", Icons.title),
                    style: TextStyle(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _title = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Title cannot be empty" : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Category
                  DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration("Category", Icons.category_rounded),
                    value: _category,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.kSecondaryNavy),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: AppColors.kSecondaryNavy, fontSize: 14),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.replaceAll("_", " ").toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 16),

                  // 3. Thumbnail
                  TextFormField(
                    initialValue: _thumbnail,
                    decoration: _buildInputDecoration("Thumbnail URL", Icons.link_rounded),
                    style: TextStyle(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _thumbnail = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Thumbnail URL cannot be empty";
                      }

                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasAbsolutePath) {
                        return "Please enter a valid URL";
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 16),

                  // 4. Content
                  TextFormField(
                    initialValue: _content,
                    maxLines: 10,
                    decoration: _buildInputDecoration("Content", Icons.article_rounded).copyWith(
                       alignLabelWithHint: true,
                       hintText: "Content",
                       prefixIcon: Container(
                        height: 200, 
                        width: 40, 
                        alignment: Alignment.topCenter, 
                        child: Transform.translate(
                          offset: const Offset(0, -20), 
                          child: Icon(Icons.article_rounded, color: AppColors.kSecondaryNavy),
                        ),
                       ),
                    ),
                    style: TextStyle(color: AppColors.kSecondaryNavy),
                    onChanged: (value) => _content = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Content cannot be empty" : null,
                  ),
                  const SizedBox(height: 32),

                  // 5. Save Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 100,
                      height: 40,
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
                            final String url = widget.article == null
                              ? "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/article/create-flutter/"
                              : "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id/article/edit-flutter/${widget.article!.id}/";

                            final response = await request.postJson(
                              url,
                              jsonEncode({
                                "title": _title,
                                "content": _content,
                                "category": _category,
                                "thumbnail": _thumbnail,
                              }),
                            );

                            if (context.mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Article saved successfully!",
                                        style: TextStyle(color: AppColors.kSecondaryNavy, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: AppColors.kAccentLime,
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(label: 'OK', textColor: AppColors.kSecondaryNavy, onPressed: (){}),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Failed to save article.")),
                                  );
                                }
                            }
                          }
                        },
                        child: const Text(
                          "SAVE",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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