import 'package:flutter/material.dart';
import 'package:wikilympics/article/models/article_entry.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/article/screens/article_detail.dart';
import 'package:wikilympics/article/widgets/article_card.dart';
import 'package:wikilympics/article/screens/article_form.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/screens/login.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final Color kPrimaryNavy = const Color(0xFF03045E); // Saya update ke Navy yang benar
  final Color kAccentLime = const Color(0xFFD9E74C);
  final Color kBgGrey = const Color(0xFFF9F9F9);

  String _selectedCategory = "All Categories";
  bool _isAdmin = false;

  final List<String> _categories = [
    'All Categories',
    'athletics', 'archery', 'artistic_gymnastics', 'artistic_swimming',
    'badminton', 'baseball_softball', 'basketball', 'beach_volleyball',
    'boxing', 'canoe_slalom', 'cycling_road', 'diving', 'fencing',
    'football', 'handball', 'hockey', 'judo', 'karate', 'marathon_swimming',
    'rowing', 'rhythmic_gymnastics', 'sailing', 'shooting', 'swimming',
    'table_tennis', 'taekwondo', 'trampoline_gymnastics', 'triathlon',
    'water_polo', 'weightlifting', 'wrestling',
  ];

  @override
  void initState() {
    super.initState();
    // Cek status admin saat halaman dimuat
    // Gunakan addPostFrameCallback karena butuh context/provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
    });
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    
    if (request.loggedIn) {
      final response = await request.get("http://127.0.0.1:8000/auth/status/");
      
      setState(() {
        _isAdmin = response['is_superuser'] ?? false;
      });
    }
  }

  Future<List<ArticleEntry>> fetchArticles(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/article/json/');

    List<ArticleEntry> listArticles = [];
    for (var d in response) {
      if (d != null) {
        listArticles.add(ArticleEntry.fromJson(d));
      }
    }
    return listArticles;
  }
  
  void _refreshArticles() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        title: Image.asset(
          'assets/wikilympics_banner.png', 
          height: 60,
          fit: BoxFit.contain,
        ),
        backgroundColor: kBgGrey,
        iconTheme: IconThemeData(color: kPrimaryNavy),
        elevation: 0,
      ),

      drawer: const LeftDrawer(),
      
      // Button add article
      floatingActionButton: _isAdmin 
        ? FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArticleFormPage()),
            );
            
            _refreshArticles();
          },
          label: Text("ADD ARTICLE", style: TextStyle(color: kPrimaryNavy, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.add, color: kPrimaryNavy),
          backgroundColor: kAccentLime,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        )
        : null,
      
      body: FutureBuilder(
        future: fetchArticles(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No articles yet.',
                      style: TextStyle(fontSize: 20, color: kPrimaryNavy),
                    ),
                  ],
                ),
              );
            } else {
              List<ArticleEntry> allArticles = snapshot.data!;
              List<ArticleEntry> filteredArticles;

              if (_selectedCategory == "All Categories") {
                filteredArticles = allArticles;
              } else {
                filteredArticles = allArticles
                    .where((article) => article.category == _selectedCategory)
                    .toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === HEADER (Dropdown & Title) ===
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kBgGrey, // Background Abu-abu
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Dropdown Search Bar
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _categories.contains(_selectedCategory)
                                  ? _selectedCategory
                                  : _categories.first,
                              icon: Icon(Icons.search, color: kPrimaryNavy),
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                              items: _categories.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value == "All Categories"
                                        ? "Search by category..."
                                        : value.replaceAll("_", " ").toUpperCase(),
                                    style: TextStyle(
                                      color: value == "All Categories" ? Colors.grey : kPrimaryNavy,
                                      fontWeight: value == "All Categories" ? FontWeight.normal : FontWeight.w600
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        // === JUDUL DIGESER ===
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0), // <--- UBAH DISINI: Geser lebih banyak (12.0)
                          child: Text(
                            "Olympic Articles",
                            style: GoogleFonts.inter( 
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === LIST ARTIKEL ===
                  Expanded(
                    child: filteredArticles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  "No articles found in\n$_selectedCategory",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 80),
                            itemCount: filteredArticles.length,
                            itemBuilder: (_, index) => ArticleCard(
                              article: filteredArticles[index],
                              onTap: () {
                                if (!request.loggedIn) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Login Required'),
                                      content: const Text(
                                          'You need to be logged in to view the details. Would you like to login now?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LoginPage()),
                                            );
                                          },
                                          child: const Text('Login'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleDetailPage(
                                        article: filteredArticles[index],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}





//       // Body List Artikel
//       body: FutureBuilder(
//         future: fetchArticles(request),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (snapshot.data == null) {
//             return const Center(child: CircularProgressIndicator());
//           } else {
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'No articles yet.',
//                       style: TextStyle(fontSize: 20, color: kPrimaryNavy),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               );
//             } else {
//               List<ArticleEntry> allArticles = snapshot.data!;
//               List<ArticleEntry> filteredArticles;
              
//               if (_selectedCategory == "All Categories") {
//                 filteredArticles = allArticles;
//               } else {
//                 // Pastikan akses category sesuai modelmu (bisa .category atau .fields.category)
//                 filteredArticles = allArticles
//                     .where((article) => article.category == _selectedCategory) 
//                     .toList();
//               }

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // === HEADER (Dropdown & Title) ===
//                   Container(
//                     width: double.infinity,
//                     // PERBAIKAN: HAPUS 'const' DI SINI & GANTI WARNA JADI kBgGrey
//                     decoration: BoxDecoration( // <--- Tanpa const
//                       color: kBgGrey, // <--- Warna jadi Abu
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(24),
//                         bottomRight: Radius.circular(24),
//                       ),
//                     ),
//                     padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
                        
//                         // Dropdown Search Bar
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.white, // Input field tetap putih agar kontras
//                             borderRadius: BorderRadius.circular(30),
//                             border: Border.all(color: Colors.grey.shade300),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: _categories.contains(_selectedCategory) 
//                                   ? _selectedCategory 
//                                   : _categories.first,
//                               icon: Icon(Icons.search, color: kPrimaryNavy),
//                               style: GoogleFonts.poppins(
//                                 color: Colors.black87,
//                                 fontSize: 14,
//                               ),
//                               dropdownColor: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               onChanged: (String? newValue) {
//                                 setState(() {
//                                   _selectedCategory = newValue!;
//                                 });
//                               },
//                               items: _categories.map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(
//                                     value == "All Categories" 
//                                       ? "Search by category..."
//                                       : value.replaceAll("_", " ").toUpperCase(),
//                                     style: TextStyle(
//                                       color: value == "All Categories" ? Colors.grey : kPrimaryNavy,
//                                       fontWeight: value == "All Categories" ? FontWeight.normal : FontWeight.w600
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 24),

//                         // Judul Section
//                         Text(
//                           "Olympic Articles",
//                           style: GoogleFonts.poppins(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: kPrimaryNavy,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Expanded(
//                     child: filteredArticles.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   "No articles found in\n$_selectedCategory",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(color: Colors.grey[500]),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 80),
//                             itemCount: filteredArticles.length,
//                             itemBuilder: (_, index) => ArticleCard(
//                               article: filteredArticles[index],
//                               onTap: () {
//                                 if (!request.loggedIn) {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: const Text('Login Required'),
//                                       content: const Text(
//                                           'You need to be logged in to view the details. Would you like to login now?'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () => Navigator.pop(context),
//                                           child: const Text('Cancel'),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(builder: (context) => const LoginPage()),
//                                             );
//                                           },
//                                           child: const Text('Login'),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => ArticleDetailPage(
//                                         article: filteredArticles[index],
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                   ),
//                 ],
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }