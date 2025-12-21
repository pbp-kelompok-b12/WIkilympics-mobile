import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/article/models/article_entry.dart';

class TrendingCard extends StatelessWidget {
  final ArticleEntry article;
  final VoidCallback onTap;

  const TrendingCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  article.thumbnail.isNotEmpty 
                      ? article.thumbnail 
                      : 'https://via.placeholder.com/600x300',
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay yang lebih halus
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1), // Atas terang
                        Colors.black.withOpacity(0.85), // Bawah gelap untuk teks
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label Kategori (Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E74C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.category.replaceAll("_", " ").toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF03045E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Judul (Dibuat Bold dan Putih)
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(offset: const Offset(0, 1), blurRadius: 2, color: Colors.black45)
                        ],
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