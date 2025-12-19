import 'package:flutter/material.dart';
// import 'package:wikilympics/landingpoll/screens/menu.dart'; // DIKOMEN - belum butuh
// import 'package:wikilympics/article/screens/article_list.dart'; // DIKOMEN - belum butuh
// import 'package:wikilympics/sports/screens/sport_entry_list.dart'; // DIKOMEN - belum butuh

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// IMPORT ATHLETES YANG DIPERLUKAN
import 'package:wikilympics/athletes/screens/athletes_entry_list.dart'; // INI HARUS ADA

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF01203F)),
            child: Column(
              children: [
                Text(
                  'WIkilympics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Seluruh berita olahraga terkini di sini!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // === HOME - DIKOMEN DULU ===
          /*
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          */

          // === SPORTS - DIKOMEN DULU ===
          /*
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Sports'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SportEntryListPage()),
              );
            },
          ),
          */

          // === ATHLETES - INI SAJA YANG AKTIF ===
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Athletes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AthleteEntryListPage()),
              );
            },
          ),

          // === UPCOMING EVENTS - DIKOMEN ===
          /*
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Upcoming Events'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          */

          // === ARTICLES - DIKOMEN DULU ===
          /*
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Articles'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ArticleListPage()),
              );
            },
          ),
          */

          // === FORUM - DIKOMEN ===
          /*
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Forum & Reviews'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          */
          const Divider(),

          // === LOGOUT - TETAP AKTIF (tapi perlu MyHomePage) ===
          /*
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final response = await request.logout(
                "http://127.0.0.1:8000/auth/logout/",
              );
              String message = response["message"];
              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$message See you again, $uname.")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
          ),
          */

          // === TEMPORARY SIMPLE LOGOUT ===
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout (Test)'),
            onTap: () async {
              // Simple logout tanpa navigasi ke MyHomePage
              final response = await request.logout(
                "http://127.0.0.1:8000/auth/logout/",
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response['status']
                          ? "Logged out successfully"
                          : "Logout failed: ${response['message']}",
                    ),
                  ),
                );
                // Tetap di halaman yang sama
              }
            },
          ),
        ],
      ),
    );
  }
}
