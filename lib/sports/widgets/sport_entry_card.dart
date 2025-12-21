import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/sports/models/sport_entry.dart';

class SportEntryCard extends StatelessWidget {
  final SportEntry sport;
  final VoidCallback onTap;

  const SportEntryCard({
    super.key,
    required this.sport,
    required this.onTap,
  });

  String _formatSportInfo(Fields fields) {
    String category = fields.sportType
        .toString()
        .split('.')
        .last
        .replaceAll('_', ' ')
        .toUpperCase();

    String rawStructure = fields.participationStructure
        .toString()
        .split('.')
        .last
        .toUpperCase();

    String structureDesc;
    if (rawStructure == 'BOTH') {
      structureDesc = 'INDIVIDUAL & TEAM';
    } else {
      structureDesc = rawStructure;
    }

    return '$category | $structureDesc';
  }

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
              /// ================= 1. TOP SECTION (IMAGE) =================
              Container(
                height: 200,
                color: Colors.grey[200],
                child: Image.network(
                  'http://localhost:8000/sports/proxy-image/?url=${Uri.encodeComponent(sport.fields.sportImg)}',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),

              /// ================= 2. BOTTOM SECTION (INFO) =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: darkCardColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// --- Icon Panah Kuning ---
                    Transform.rotate(
                      angle: 0.785,
                      child: const Icon(
                        Icons.arrow_downward,
                        color: accentArrowColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// --- Teks ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sport Name
                          Text(
                            sport.fields.sportName.toUpperCase(),
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

                          // Info Category | Structure
                          Text(
                            _formatSportInfo(sport.fields),
                            style: GoogleFonts.poppins(
                              color: Colors.blueGrey[200],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// --- Flag Image ---
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'http://localhost:8000/sports/proxy-image/?url=${Uri.encodeComponent(sport.fields.countryFlagImg)}',
                          width: 32,
                          height: 22,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.flag, color: Colors.white, size: 20),
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