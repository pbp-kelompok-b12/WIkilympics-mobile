import 'package:flutter/material.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/screens/login.dart';

class MyHomePage extends StatelessWidget {
    const MyHomePage({super.key});

    @override
    Widget build(BuildContext context) {
        // Scaffold menyediakan struktur dasar halaman dengan AppBar dan body.
        return Scaffold(
            // AppBar adalah bagian atas halaman yang menampilkan judul.
            appBar: AppBar(
                // Judul aplikasi "Football News" dengan teks putih dan tebal.
                title: const Text(
                    'Football News',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                // Warna latar belakang AppBar diambil dari skema warna tema aplikasi.
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .primary,

                // 👉 Tambahan tombol di pojok kanan
                actions: [
                    TextButton(
                        onPressed: () {
                            // TODO: arahkan ke halaman login
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
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

            ),


            drawer: const LeftDrawer(),
        );
    }
}