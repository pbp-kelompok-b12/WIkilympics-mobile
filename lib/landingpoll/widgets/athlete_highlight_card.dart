import 'package:flutter/material.dart';

class AthleteHighlightCard extends StatelessWidget {
  final int rank;
  final String athleteName;
  final String sportName;
  final String country;
  final VoidCallback? onTap;

  const AthleteHighlightCard({
    super.key,
    required this.rank,
    required this.athleteName,
    required this.sportName,
    required this.country,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        height: 165,
        decoration: BoxDecoration(
          color: const Color(0xFF062B4A),
          borderRadius: BorderRadius.circular(28),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rank.toString(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              athleteName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sportName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 6),
)
                            Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  country,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 40,
                        child: Divider(color: Colors.white30, thickness: 2),
                      ),
                      SizedBox(height: 6),
                      Icon(Icons.south_west, color: Colors.white, size: 20),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Container(
              width: 95,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white54,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
