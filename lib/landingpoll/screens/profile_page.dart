import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/landingpoll/screens/menu.dart'; // Ini adalah MyHomePage kamu
import 'package:wikilympics/screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passwordController = TextEditingController();
  final String baseUrl = "http://127.0.0.1:8000/auth";
  bool _isObscure = true; // Untuk toggle lihat/sembunyi password

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    const Color kNavy = Color(0xFF03045E);
    const Color kLime = Color(0xFFD9E74C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Profile", 
          style: GoogleFonts.poppins(color: kNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: kNavy),
      ),
      body: Center(
<<<<<<< HEAD
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: !request.loggedIn 
            ? _buildGuestContent(kNavy) 
            : _buildProfileContent(request, kNavy, kLime),
=======
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle,
                color: const Color(0xFF01203F), size: 90),
            const SizedBox(height: 10),

            Text(
              username,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: const Color(0xFF01203F),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                await request.logout("/auth/logout/");

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01203F),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
>>>>>>> d0a06c3df570a9d9c7cbf61eb05c3164b7f53676
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildGuestContent(Color navy) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 100, color: navy.withOpacity(0.1)),
        const SizedBox(height: 20),
        Text("No Profile Found", 
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: navy)),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: navy),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          child: const Text("Go to Login", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildProfileContent(CookieRequest request, Color navy, Color lime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: lime,
            child: Icon(Icons.person, size: 40, color: navy),
          ),
        ),
        const SizedBox(height: 30),
        
        const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        Text(request.jsonData['username'] ?? "User", 
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
        
        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 25),
        
        Text("Change Password", 
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _isObscure, // Logic lihat password
          decoration: InputDecoration(
            hintText: "Enter new password",
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
          ),
        ),
        const SizedBox(height: 20),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: lime,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () async {
            if (_passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please type a new password")));
              return;
            }

            final response = await request.post("http://127.0.0.1:8000/auth/edit-profile/", {
              'password': _passwordController.text,
            });

            if (response['status'] == 'success') {
              if (context.mounted) {
                _passwordController.clear(); // Bersihkan field setelah save
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password updated!"),
                    backgroundColor: Colors.green,
                  )
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? "Failed to update"))
                );
              }
            }
          },
          child: Text("SAVE CHANGES", style: GoogleFonts.poppins(color: navy, fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(height: 40),
        
        // LOGOUT: Balik ke MyHomePage (Landing Page)
        ListTile(
          onTap: () async {
            final response = await request.logout("http://127.0.0.1:8000/auth/logout/");
            if (response['status'] == true) {
              request.jsonData.clear(); 
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const MyHomePage()), 
                  (route) => false
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
              }
            }
          },
          leading: const Icon(Icons.logout, color: Color(0xFF03045E)),
          title: const Text("Logout", style: TextStyle(color: Color(0xFF03045E), fontWeight: FontWeight.w600)),
        ),

        // DELETE ACCOUNT
        ListTile(
          onTap: () => _confirmDelete(context, request, navy),
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text("Delete Account Permanently", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, CookieRequest request, Color navy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This will delete your account forever."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final response = await request.post("http://127.0.0.1:8000/auth/delete-account/", {});
              if (response['status'] == 'success') {
                request.jsonData.clear();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const MyHomePage()), (route) => false);
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
=======
>>>>>>> d0a06c3df570a9d9c7cbf61eb05c3164b7f53676
}