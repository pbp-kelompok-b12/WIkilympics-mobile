import 'package:flutter/material.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Tambah ini
import 'package:provider/provider.dart'; // Tambah ini

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil state request. Gunakan 'watch' agar UI refresh saat status login berubah
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Football News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        // 2. Logika Tampilan Tombol
        actions: [
          // Jika User SUDAH Login
          if (request.loggedIn) ...[
            Center(
              child: Text(
                "Hi, ${request.jsonData['username'] ?? 'User'}", // Menampilkan nama user (opsional)
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                // Logika Logout
                final response = await request.logout(
                  "http://localhost:8000/auth/logout/" // Sesuaikan URL logout Django kamu
                );
                
                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$message Sampai jumpa, $uname."),
                    ));
                    // Tidak perlu navigasi, karena UI akan auto-refresh (tombol jadi Sign In lagi)
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                    ));
                  }
                }
              },
              tooltip: "Logout",
            )
          ]
          // Jika User BELUM Login
          else ...[
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: Text(
          request.loggedIn 
              ? "Kamu sudah login!" 
              : "Silakan login untuk akses fitur.",
        ),
      ),
    );
  }
}