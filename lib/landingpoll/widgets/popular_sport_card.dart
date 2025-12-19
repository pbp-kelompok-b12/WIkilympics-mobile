import 'package:flutter/material.dart';

class PopularSportCard extends StatelessWidget {
  final int rank;
  final String sportName;
  final String firstYear;
  final String imageUrl;
  final VoidCallback? onTap;

  const PopularSportCard({
    super.key,
    required this.rank,
    required this.sportName,
    required this.firstYear,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        height: 140, // Memberikan tinggi pasti agar layout konsisten
        decoration: BoxDecoration(
          color: const Color(0xFF062B4A),
          borderRadius: BorderRadius.circular(24), // Radius sedikit lebih besar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ===== LEFT SIDE =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar panah mentok bawah
                children: [
                  // BAGIAN ATAS: Rank + Info di dalam Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Rata atas
                    children: [
                      // Rank (Angka)
                      Text(
                        rank.toString(),
                        style: const TextStyle(
                          fontSize: 36, // Ukuran font
                          height: 1.0, // Mengurangi jarak vertikal font
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12), // Jarak antara Angka dan Teks

                      // Info (Judul & Tahun)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sportName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5, // Sedikit renggang biar elegan
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              firstYear,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white54, // Warna lebih redup
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // BAGIAN BAWAH: Garis & Panah
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, // Garis lebih pendek sedikit agar manis
                        height: 2,
                        color: Colors.white30, // Transparansi garis
                      ),
                      const SizedBox(height: 8),
                      // Ikon Panah Diagonal (Pojok Kiri Bawah)
                      const Icon(
                        Icons.south_west, // Ganti ke panah diagonal
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(width: 16), // Jarak ke Gambar

            // ===== RIGHT SIDE IMAGE =====
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 90, // Sedikit lebih lebar
                height: double.infinity, // Mengikuti tinggi parent
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: double.infinity,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image, color: Colors.white54),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}