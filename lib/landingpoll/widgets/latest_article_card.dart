import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/app_colors.dart';

class LatestArticleCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String date;
  final VoidCallback? onTap;

  const LatestArticleCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final Color AppColors.kPrimaryNavy = const Color(0xFF01203F);
    // final Color AppColors.kAccentLime = const Color(0xFFC8DB2C);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: AppColors.kPrimaryNavy,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.kPrimaryNavy,
                      child: Icon(Icons.broken_image, color: Colors.white24, size: 50),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.kPrimaryNavy.withOpacity(0.4),
                          AppColors.kPrimaryNavy.withOpacity(0.95),
                        ],
                        stops: const [0.3, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.kAccentLime.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                    ),
                    child: Text(
                      author.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kPrimaryNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.kAccentLime),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Text(
                            "Read More",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.kAccentLime,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.kAccentLime, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}