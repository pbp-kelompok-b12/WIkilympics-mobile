// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:wikilympics/models/article/article_entry.dart';

// class ArticleCard extends StatelessWidget {
//   final ArticleEntry article;
//   final VoidCallback onTap;

//   const ArticleCard({
//     super.key,
//     required this.article,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final date = DateFormat("MMM. d, yyyy").format(article.created);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Thumbnail with Like/Dislike buttons ---
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: Image.network(
//                     'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(article.thumbnail)}',
//                     width: double.infinity,
//                     height: 220,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stack) => Container(
//                       height: 220,
//                       color: Colors.grey[300],
//                       child: const Center(child: Icon(Icons.broken_image)),
//                     ),
//                   ),
//                 ),

//                 // --- Floating Like/Dislike ---
//                 Positioned(
//                   right: 12,
//                   bottom: 12,
//                   child: Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.45),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         // Like icon + count
//                         Icon(Icons.thumb_up_alt_outlined,
//                             size: 18, color: Colors.white),
//                         const SizedBox(width: 6),
//                         Text(
//                           article.likes.toString(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(width: 10),

//                         // Dislike icon
//                         Icon(Icons.thumb_down_alt_outlined,
//                             size: 18, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             const SizedBox(height: 12),

//             // --- Title ---
//             Text(
//               article.title,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 height: 1.2,
//               ),
//             ),
//             const SizedBox(height: 10),

//             // --- Date Only ---
//             Text(
//               date,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF64748B),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




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