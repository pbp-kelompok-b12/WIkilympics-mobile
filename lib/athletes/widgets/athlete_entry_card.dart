// widgets/athlete_entry_card.dart
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
    const Color accentColor = Color(0xFFD2F665);

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
              // IMAGE SECTION
              Container(
                height: 200,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    // Athlete Photo
                    athlete.fields.athletePhoto.isNotEmpty
                        ? Image.network(
                            athlete.fields.athletePhoto,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Country Badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: darkCardColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor, width: 1),
                        ),
                        child: Text(
                          athlete.fields.country.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Name Overlay
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            athlete.fields.athleteName.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            athlete.fields.sport,
                            style: GoogleFonts.poppins(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // INFO SECTION
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: darkCardColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.person,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Biography Preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BIOGRAPHY",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            athlete.fields.biography.length > 100
                                ? "${athlete.fields.biography.substring(0, 100)}..."
                                : athlete.fields.biography,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: accentColor,
                      size: 20,
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF162235),
      child: const Center(
        child: Icon(Icons.person, size: 80, color: Colors.white30),
      ),
    );
  }
}
