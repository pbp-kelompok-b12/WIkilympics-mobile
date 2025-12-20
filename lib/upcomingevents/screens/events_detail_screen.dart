import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wikilympics/upcomingevents/models/events_entry.dart';



class EventDetailScreen extends StatelessWidget {
  final EventEntry event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF03045E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Upcoming Events",
          style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF03045E)
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            Image.network(
              event.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 280,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Event
                  Text(
                    event.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001D3D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // General Info Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF03045E), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "General Info",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFF03045E),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _infoRow(Icons.person_outline, "Organizer", event.organizer),
                        _infoRow(Icons.location_on_outlined, "Location", event.location),
                        _infoRow(Icons.calendar_today_outlined, "Date", DateFormat('dd MMMM yyyy').format(event.date)),
                        _infoRow(Icons.sports_outlined, "Sports", event.sportBranch),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03045E),
                      border: Border.all(color: const Color(0xFFD9E74C), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: GoogleFonts.poppins(
                            color: Color(0xFFD9E74C),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF03045E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(0xFF03045E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}