import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumReviewCard extends StatelessWidget {
  final String username;
  final String profileImage;
  final String timeAgo;
  final String title;
  final String contentImage;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onTap;

  const ForumReviewCard({
    super.key,
    required this.username,
    required this.profileImage,
    required this.timeAgo,
    required this.title,
    required this.contentImage,
    required this.likeCount,
    required this.commentCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    username,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF01203F),
                    ),
                  ),
                ),
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF01203F).withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                contentImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(Icons.favorite, size: 20, color: const Color(0xFF155F90)),
                const SizedBox(width: 6),
                Text(
                  "$likeCount",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 20),

                Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  "$commentCount",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Icon(Icons.bookmark_border, size: 22, color: Colors.grey[400]),
              ],
            )
          ],
        ),
      ),
    );
  }
}