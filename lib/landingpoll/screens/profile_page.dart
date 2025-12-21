import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/landingpoll/screens/menu.dart';
import 'package:wikilympics/screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passwordController = TextEditingController();
  final String baseUrl = "https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth";
  bool _isObscure = true; 

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: !request.loggedIn 
            ? _buildGuestContent(AppColors.kSecondaryNavy) 
            : _buildProfileContent(request, AppColors.kSecondaryNavy, AppColors.kAccentLime),
        ),
      ),
    );
  }

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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
          obscureText: _isObscure, 
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

            final response = await request.post("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/edit-profile/", {
              'password': _passwordController.text,
            });

            if (response['status'] == 'success') {
              if (context.mounted) {
                _passwordController.clear(); 
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
        
        ListTile(
          onTap: () async {
            final response = await request.logout("https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//auth/logout/");
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
      ],
    );
  }
}