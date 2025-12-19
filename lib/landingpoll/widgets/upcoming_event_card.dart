import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingEventCard extends StatelessWidget {
  final Widget image;
  final String title;
  final String author;
  final String date;
  final VoidCallback? onTap;

  const UpcomingEventCard({
    super.key,
    required this.image,
    required this.title,
    required this.author,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE (Tetap sesuai kode kamu)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 75,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: image,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 2. TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Event
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF01203F),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author & Date (INI BAGIAN YANG DIPERBAIKI)
                  Row(
                    children: [
                      // Bungkus Author dengan Flexible agar tidak nabrak kanan
                      Flexible(
                        child: Text(
                          "By $author",
                          maxLines: 1, // Batasi 1 baris
                          overflow: TextOverflow.ellipsis, // Kalo panjang jadi "..."
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Separator (Icon)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 4, color: Colors.grey),
                      ),

                      // Date (Tidak perlu Flexible, karena kita mau tanggal selalu terlihat)
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}