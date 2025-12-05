import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wikilympics/models/article/article_entry.dart';

class ArticleCard extends StatelessWidget {
  final ArticleEntry article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final date = DateFormat("MMM d, yyyy").format(article.created);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Decoration untuk shadow dan rounded corners
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // 1. BAGIAN GAMBAR (ATAS)
              Stack(
                children: [
                  Image.network(
                    article.thumbnail, // Langsung gunakan URL dari model
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                      );
                    },
                  ),
                ],
              ),

              // 2. BAGIAN INFO (BAWAH - DARK NAVY)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF0F1929), // Warna Navy Gelap sesuai desain
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Panah Lime
                    const Icon(
                      Icons.south_west, // Icon panah ke bawah kiri
                      color: Color(0xFFD2F665), // Warna Lime/Kuning stabilo
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    
                    // Teks Judul dan Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$date • ${article.likes} Likes",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Garis bawah tipis
                          Container(
                            height: 1,
                            width: 50,
                            color: Colors.grey[600],
                          )
                        ],
                      ),
                    ),
                    
                    // Bendera/Icon Kategori (Opsional, mengambil dari screenshot ada bendera)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                         border: Border.all(color: Colors.white24),
                         borderRadius: BorderRadius.circular(4)
                      ),
                      child: const Icon(Icons.sports_soccer, color: Colors.white, size: 16),
                    )
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