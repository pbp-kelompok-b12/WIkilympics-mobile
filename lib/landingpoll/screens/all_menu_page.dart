import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllMenuPage extends StatelessWidget {
  const AllMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Menu",
          style: GoogleFonts.poppins(
            color: const Color(0xFF01203F),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF01203F)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          _item(context, "Athletes Module", Icons.person, () {}),
          _item(context, "Sports Module", Icons.sports_soccer, () {}),
          _item(context, "Events Module", Icons.event, () {}),
          _item(context, "Articles Module", Icons.article, () {}),
          _item(context, "Review Module", Icons.rate_review, () {}),

        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: const Color(0xFF01203F)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF01203F),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}