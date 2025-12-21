import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Forum & Review",
          style: GoogleFonts.poppins(
            color: AppColors.kPrimaryNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.kPrimaryNavy),
      ),
      body: Center(
        child: Text(
          "Halaman Forum & Review\n(isi dengan modul Razzan)",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.kPrimaryNavy,
          ),
        ),
      ),
    );
  }
}