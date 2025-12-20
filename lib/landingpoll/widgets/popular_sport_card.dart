import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopularSportCard extends StatefulWidget {
  final int rank;
  final String sportName;
  final String firstYear;
  final String imageUrl;
  final String flagUrl;
  final String description;
  final String origin;
  final String type;
  final VoidCallback onDetailTap;

  const PopularSportCard({
    super.key,
    required this.rank,
    required this.sportName,
    required this.firstYear,
    required this.imageUrl,
    required this.flagUrl,
    required this.description,
    required this.origin,
    required this.type,
    required this.onDetailTap,
  });

  @override
  State<PopularSportCard> createState() => _PopularSportCardState();
}

class _PopularSportCardState extends State<PopularSportCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.rank.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFC8DB2C).withOpacity(0.9),
                  height: 1,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sportName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildSmallBadge("Est. ${widget.firstYear}"),
                        const SizedBox(width: 8),
                        _buildCountryBadge(widget.origin, widget.flagUrl),
                      ],
                    ),
                  ],
                ),
              ),
              Hero(
                tag: 'sport_img_${widget.rank}',
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetails(),
          ),

          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isExpanded ? "LESS INFO" : "MORE DETAILS",
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.category_outlined, "Type", widget.type),
          const SizedBox(height: 12),
          Text(
            "Overview",
            style: GoogleFonts.poppins(color: const Color(0xFFC8DB2C), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            widget.description,
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onDetailTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text("VIEW FULL SPORT PROFILE"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8DB2C),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
    );
  }

  Widget _buildCountryBadge(String name, String flagUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFC8DB2C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8DB2C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(flagUrl, width: 16, height: 11, fit: BoxFit.cover),
          ),
          const SizedBox(width: 6),
          Text(name.toUpperCase(), style: GoogleFonts.poppins(color: const Color(0xFFC8DB2C), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text("$label: ", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        Text(value.split('.').last.replaceAll('_', ' ').toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}