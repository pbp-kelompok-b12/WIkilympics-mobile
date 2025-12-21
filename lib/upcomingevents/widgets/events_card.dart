import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/upcomingevents/models/events_entry.dart';

class EventsCard extends StatelessWidget {
  final EventEntry event;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback?  onDelete;

  const EventsCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Detail
            Positioned.fill(
              child: InkWell(
                onTap: onTap,
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade200, child: const Icon(Icons.image)),
                ),
              ),
            ),

            // Admin (Edit & Delete)
            if (onEdit != null || onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onEdit != null)
                  _adminButton(Icons.edit, Colors.blue, onEdit!),
                  const SizedBox(width: 5),
                  if (onDelete != null)
                  _adminButton(Icons.delete, Colors.red, onDelete!),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF001D3D),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_outward, color: Colors.yellow, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              event.name.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              event.sportBranch,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.flag, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget
  Widget _adminButton(IconData icon, Color color, VoidCallback pressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(6),
        icon: Icon(icon, size: 18, color: color),
        onPressed: pressed,
      ),
    );
  }
}