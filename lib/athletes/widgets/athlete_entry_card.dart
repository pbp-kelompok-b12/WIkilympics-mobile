// lib/athletes/widgets/athlete_entry_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/athletes/models/athlete_entry.dart';

class AthleteEntryCard extends StatelessWidget {
  final AthleteEntry athlete;
  final VoidCallback onTap;

  const AthleteEntryCard({
    super.key,
    required this.athlete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkCardColor = Color(0xFF0B162C);
    const Color accentArrowColor = Color(0xFFCEF250);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// === TOP SECTION (PHOTO) ===
              Container(
                height: 200,
                color: Colors.grey[200],
                child: Image.network(
                  'http://localhost:8000/athletes/proxy-image/?url=${Uri.encodeComponent(athlete.fields.athletePhoto)}',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
              ),

              /// === BOTTOM SECTION (INFO) ===
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(color: darkCardColor),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Icon Panah Kuning (sama seperti sports)
                    Transform.rotate(
                      angle: 0.785,
                      child: const Icon(
                        Icons.arrow_downward,
                        color: accentArrowColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// Teks Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Athlete Name
                          Text(
                            athlete.fields.athleteName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Sport & Country (sesuai Django)
                          Text(
                            '${athlete.fields.sport} • ${athlete.fields.country}',
                            style: GoogleFonts.poppins(
                              color: Colors.blueGrey[200],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Sport Badge (seperti badge di Django)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF00), // Kuning seperti Django
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Text(
                        athlete.fields.sport.substring(0, 3).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: const Color(
                            0xFF1E3CC8,
                          ), // Biru navy seperti Django
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
