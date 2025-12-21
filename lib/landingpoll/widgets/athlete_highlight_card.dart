import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AthleteHighlightCard extends StatefulWidget {
  final int rank;
  final String athleteName;
  final String sportName;
  final String country;
  final String imageUrl;
  final VoidCallback? onTap;

  const AthleteHighlightCard({
    super.key,
    required this.rank,
    required this.athleteName,
    required this.sportName,
    required this.country,
    required this.imageUrl,
    this.onTap,
  });

  @override
  State<AthleteHighlightCard> createState() => _AthleteHighlightCardState();
}

class _AthleteHighlightCardState extends State<AthleteHighlightCard> {
  bool isExpanded = false; // Untuk fitur 'More Details' seperti di Sports

  @override
  Widget build(BuildContext context) {
    const Color kNavyColor = Color(0xFF0F1929);
    const Color kLimeColor = Color(0xFFD2F665);
    const Color kDarkBlue = Color(0xFF162235);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: kNavyColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Rank Number
                Text(
                  widget.rank.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: kLimeColor,
                  ),
                ),
                const SizedBox(width: 20),
                // Athlete Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.athleteName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Sport Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.sportName,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Country Row
                      Row(
                        children: [
                          const Icon(Icons.flag, size: 16, color: kLimeColor),
                          const SizedBox(width: 6),
                          Text(
                            widget.country.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: kLimeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Athlete Image Circle (Top Right)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Colors.white24, size: 40),
                    )
                        : const Icon(Icons.person, color: Colors.white24, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Button More Details (Nyeseuaiin gaya Sports)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: widget.onTap, // Langsung navigasi ke Detail
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: kDarkBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.keyboard_arrow_right, color: Colors.white54, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "VIEW FULL PROFILE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}