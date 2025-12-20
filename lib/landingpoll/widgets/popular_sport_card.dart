import 'package:flutter/material.dart';

class PopularSportCard extends StatefulWidget {
  final int rank;
  final String sportName;
  final String firstYear;
  final String imageUrl;
<<<<<<< HEAD
  final String description; // Data tambahan untuk view detail
  final String origin;      // Data tambahan untuk view detail
  final String type;        // Data tambahan untuk view detail
=======
  final String flagUrl;
  final String description;
  final String origin;
  final String type;
  final VoidCallback onDetailTap;
>>>>>>> d0a06c3df570a9d9c7cbf61eb05c3164b7f53676

  const PopularSportCard({
    super.key,
    required this.rank,
    required this.sportName,
    required this.firstYear,
    required this.imageUrl,
    required this.description,
    required this.origin,
    required this.type,
  });

  @override
  State<PopularSportCard> createState() => _PopularSportCardState();
}

class _PopularSportCardState extends State<PopularSportCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // GRADIENT BACKGROUND BIAR LEBIH MEWAH
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF062B4A), // Warna dasar
            const Color(0xFF0A3D66), // Sedikit lebih terang
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // BAGIAN ATAS (HEADER - SELALU MUNCUL)
          // ============================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. RANKING NUMBER (Besar & Tegas)
              Text(
                widget.rank.toString(),
                style: const TextStyle(
                  fontSize: 42,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Arial', // Atau font bawaan yg tegas
                ),
              ),
              const SizedBox(width: 14),

              // 2. TEXT INFO (Nama & Tahun)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      widget.sportName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Est. ${widget.firstYear}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFC8DB2C), // Warna Lime Aksen
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 3. GAMBAR THUMBNAIL
              Hero(
                tag: 'sport_img_${widget.rank}', // Efek transisi halus (opsional)
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

<<<<<<< HEAD
          // ============================================
          // BAGIAN BAWAH (EXPANDABLE DETAIL)
          // ============================================
=======
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetails(),
          ),
>>>>>>> d0a06c3df570a9d9c7cbf61eb05c3164b7f53676

          // Menggunakan AnimatedCrossFade untuk transisi muncul/hilang
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0), // Saat tertutup (kosong)
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GARIS PEMBATAS TIPIS
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                  const SizedBox(height: 8),

                  // TAGS (Country & Type)
                  Row(
                    children: [
                      _buildTag(Icons.public, widget.origin),
                      const SizedBox(width: 8),
                      _buildTag(Icons.category, widget.type),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DESKRIPSI
                  Text(
                    "Description",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

<<<<<<< HEAD
          // ============================================
          // TOMBOL EXPAND / COLLAPSE (PANAH)
          // ============================================
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleExpand,
            child: Row(
              children: [
                // Garis dekorasi
                Container(
                  width: 30,
                  height: 2,
                  color: _isExpanded ? const Color(0xFFC8DB2C) : Colors.white24,
                ),
                const SizedBox(width: 8),

                // Icon Animasi Berputar
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0, // Putar 180 derajat saat expand
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    // Saat tertutup panah serong (ajakan klik), saat terbuka panah atas (tutup)
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.open_in_new_rounded,
                    color: _isExpanded ? const Color(0xFFC8DB2C) : Colors.white70,
                    size: 24,
                  ),
                ),

                // Teks hint kecil
                if (!_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "See Details",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                    ),
                  ),
              ],
=======
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
>>>>>>> d0a06c3df570a9d9c7cbf61eb05c3164b7f53676
            ),
          )
        ],
      ),
    );
  }

  // Widget Helper untuk membuat Tag kecil
  Widget _buildTag(IconData icon, String text) {
    // Format text agar rapi (misal: "sports.sports" -> "Sports")
    String cleanText = text.split('.').last.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFC8DB2C)),
          const SizedBox(width: 6),
          Text(
            cleanText,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}