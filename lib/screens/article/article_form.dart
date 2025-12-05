// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:pbp_django_auth/pbp_django_auth.dart';

// class ArticleFormPage extends StatefulWidget {
//   const ArticleFormPage({super.key});

//   @override
//   State<ArticleFormPage> createState() => _ArticleFormPageState();
// }

// class _ArticleFormPageState extends State<ArticleFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = "";
//   String _content = "";
//   String _category = "football"; // default
//   String _thumbnail = "";

//   // ==== SESUAI MODEL DJANGO ====
//   final List<String> _categories = [
//     'athletics',
//     'archery',
//     'artistic_gymnastics',
//     'artistic_swimming',
//     'badminton',
//     'baseball_softball',
//     'basketball',
//     'beach_volleyball',
//     'boxing',
//     'canoe_slalom',
//     'cycling_road',
//     'diving',
//     'fencing',
//     'football',
//     'handball',
//     'hockey',
//     'judo',
//     'karate',
//     'marathon_swimming',
//     'rowing',
//     'rhythmic_gymnastics',
//     'sailing',
//     'shooting',
//     'swimming',
//     'table_tennis',
//     'taekwondo',
//     'trampoline_gymnastics',
//     'triathlon',
//     'water_polo',
//     'weightlifting',
//     'wrestling',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Article"),
//         backgroundColor: Color(0xFF01203F),
//         foregroundColor: Colors.white,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // ===== Title =====
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: "Title",
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (value) => _title = value,
//                 validator: (value) =>
//                 (value == null || value.isEmpty) ? "Title cannot be empty" : null,
//               ),
//               const SizedBox(height: 16),

//               // ===== Content =====
//               TextFormField(
//                 maxLines: 6,
//                 decoration: const InputDecoration(
//                   labelText: "Content",
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (value) => _content = value,
//                 validator: (value) =>
//                 (value == null || value.isEmpty) ? "Content cannot be empty" : null,
//               ),
//               const SizedBox(height: 16),

//               // ===== Category =====
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: "Category",
//                   border: OutlineInputBorder(),
//                 ),
//                 value: _category,
//                 items: _categories
//                     .map((c) => DropdownMenuItem(
//                   value: c,
//                   child: Text(
//                     c.replaceAll("_", " ").toUpperCase(),
//                   ),
//                 ))
//                     .toList(),
//                 onChanged: (value) => setState(() => _category = value!),
//               ),
//               const SizedBox(height: 16),

//               // ===== Thumbnail =====
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: "Thumbnail URL",
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (value) => _thumbnail = value,
//               ),
//               const SizedBox(height: 24),

//               // ===== BUTTON SAVE =====
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF03396C),
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final response = await request.postJson(
//                       "http://10.0.2.2:8000/create-flutter/",
//                       jsonEncode({
//                         "title": _title,
//                         "content": _content,
//                         "category": _category,
//                         "thumbnail": _thumbnail,
//                       }),
//                     );

//                     if (response['status'] == 'success') {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Article saved!")),
//                       );
//                       Navigator.pop(context);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Failed to save article.")),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text("Save", style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ArticleFormPage extends StatefulWidget {
  const ArticleFormPage({super.key});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";
  String _category = "football"; // default
  String _thumbnail = "";

  final Color kPrimaryNavy = const Color(0xFF0F1929);
  final Color kAccentLime = const Color(0xFFD2F665);
  final Color kBgGrey = const Color(0xFFF5F6F8);
  
  final List<String> _categories = [
    'athletics', 'archery', 'artistic_gymnastics', 'artistic_swimming',
    'badminton', 'baseball_softball', 'basketball', 'beach_volleyball',
    'boxing', 'canoe_slalom', 'cycling_road', 'diving', 'fencing', 
    'football', 'handball', 'hockey', 'judo', 'karate', 'marathon_swimming',
    'rowing', 'rhythmic_gymnastics', 'sailing', 'shooting', 'swimming', 
    'table_tennis', 'taekwondo', 'trampoline_gymnastics', 'triathlon', 
    'water_polo', 'weightlifting', 'wrestling',
  ];

  // Helper untuk styling input field yang konsisten
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintText: "Enter $label...",
      prefixIcon: Icon(icon, color: kPrimaryNavy.withOpacity(0.7)),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Hilangkan border default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPrimaryNavy, width: 2.0), // Fokus warna Navy
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey, // Background abu-abu muda
      appBar: AppBar(
        title: const Text("Write Article", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Title =====
              TextFormField(
                decoration: _buildInputDecoration("Article Title", Icons.title_rounded),
                onChanged: (value) => _title = value,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Title cannot be empty" : null,
              ),
              const SizedBox(height: 16),

              // ===== Category (Dropdown) =====
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration("Category", Icons.category_rounded),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.replaceAll("_", " ").toUpperCase(),
                      style: TextStyle(color: kPrimaryNavy),
                    ),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              
              // ===== Thumbnail URL =====
              TextFormField(
                decoration: _buildInputDecoration("Thumbnail URL", Icons.image_rounded),
                onChanged: (value) => _thumbnail = value,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Thumbnail URL cannot be empty" : null,
              ),
              const SizedBox(height: 16),

              // ===== Content =====
              TextFormField(
                maxLines: 8,
                decoration: _buildInputDecoration("Content", Icons.notes_rounded).copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                ),
                onChanged: (value) => _content = value,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Content cannot be empty" : null,
              ),
              const SizedBox(height: 32),

              // ===== BUTTON SAVE =====
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryNavy, // Tombol Navy
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await request.postJson(
                      "http://127.0.0.1:8000/article/create-flutter/",
                      jsonEncode({
                        "title": _title,
                        "content": _content,
                        "category": _category,
                        "thumbnail": _thumbnail,
                      }),
                    );

                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Article saved!"), 
                          backgroundColor: kAccentLime,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to save article.")),
                      );
                    }
                  }
                },
                child: const Text("Publish Article", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}