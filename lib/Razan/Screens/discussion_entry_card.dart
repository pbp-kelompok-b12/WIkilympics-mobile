import 'package:flutter/material.dart';
import 'package:wikilympics/Razan/models/discussion_entry.dart';

class DiscussionEntryCard extends StatelessWidget {
  final DiscussionEntry discussion;
  const DiscussionEntryCard({
    super.key,
    required this.discussion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blueGrey.shade100,
                  child: Icon(Icons.person, size: 20, color: Colors.blueGrey.shade700),
                ),
                const SizedBox(width: 10),
                Text(
                  discussion.fields.username, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  "${discussion.fields.dateCreated.hour}:${discussion.fields.dateCreated.minute}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              discussion.fields.discuss,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}