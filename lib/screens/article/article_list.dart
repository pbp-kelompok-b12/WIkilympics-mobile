// import 'package:flutter/material.dart';
// import 'package:wikilympics/models/article/article_entry.dart';
// import 'package:wikilympics/widgets/left_drawer.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:wikilympics/screens/article/article_detail.dart';
// import 'package:wikilympics/widgets/article/article_card.dart';

// class ArticleListPage extends StatefulWidget {
//   const ArticleListPage({super.key});

//   @override
//   State<ArticleListPage> createState() => _ArticleListPageState();
// }

// class _ArticleListPageState extends State<ArticleListPage> {
//   Future<List<ArticleEntry>> fetchArticles(CookieRequest request) async {
//     final response = await request.get('http://127.0.0.1:8000/article/json/');

//     List<ArticleEntry> listArticles = [];
//     for (var d in response) {
//       if (d != null) {
//         listArticles.add(ArticleEntry.fromJson(d));
//       }
//     }
//     return listArticles;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Articles"),
//       ),
//       drawer: const LeftDrawer(),
//       body: FutureBuilder(
//         future: fetchArticles(request),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (snapshot.data == null) {
//             return const Center(child: CircularProgressIndicator());
//           } else {
//             if (!snapshot.hasData) {
//               return Column(
//                 children: [
//                   Text(
//                     'No articles yet.',
//                     style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),
//                   ),
//                   SizedBox(height: 8),
//                 ],
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (_, index) => ArticleCard(
//                   article: snapshot.data![index],
//                   onTap: () {
//                     // Navigate to news detail page
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ArticleDetailPage(
//                           article: snapshot.data![index],
//                         ),
//                       ),
//                     );

//                     // Show a snackbar when product card is clicked
//                     ScaffoldMessenger.of(context)
//                       ..hideCurrentSnackBar()
//                       ..showSnackBar(
//                         SnackBar(
//                           content: Text("You clicked on ${snapshot.data![index].title}"),
//                         ),
//                       );
//                   },
//                 ),
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:wikilympics/models/article/article_entry.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/screens/article/article_detail.dart';
import 'package:wikilympics/widgets/article/article_card.dart';
import 'package:wikilympics/screens/article/article_form.dart'; 

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final Color kPrimaryNavy = const Color(0xFF0F1929);
  final Color kAccentLime = const Color(0xFFD2F665);

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
    setState(() {
      // Memanggil setState akan memicu FutureBuilder untuk memuat ulang
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "WIKILYMPICS", 
      //     style: TextStyle(
      //       color: Colors.white, 
      //       fontWeight: FontWeight.w900,
      //       letterSpacing: 2.0,
      //     )
      //   ),
      //   backgroundColor: kPrimaryNavy,
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   elevation: 0,
      // ),

      appBar: AppBar(
        title: Image.asset(
          'assets/wikilympics_banner.png', 
          height: 40,
          fit: BoxFit.contain,
        ),
        // centerTitle: true, 
        
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kPrimaryNavy),
        elevation: 0,
      ),

      drawer: const LeftDrawer(),
      
      // Button add article
      floatingActionButton: FloatingActionButton.extended(
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
      ),
      
      // --- Body List Artikel ---
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
                    const SizedBox(height: 8),
                    const Text('Be the first one to write!', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 80), // Padding bawah agar tidak tertutup FAB
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => ArticleCard(
                  article: snapshot.data![index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(
                          article: snapshot.data![index],
                        ),
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("You clicked on ${snapshot.data![index].title}"),
                        ),
                      );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}