import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// Import your models and widgets
import 'package:football_news/models/forum_entry.dart';
import 'package:football_news/models/discussion_entry.dart';
import 'package:football_news/widgets/discussion_entry_card.dart'; // Ensure you have this from the previous answer

class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;

  const ForumDetailPage({super.key, required this.forum});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  
  Future<List<DiscussionEntry>> fetchDiscussions(CookieRequest request) async {
    // 1. Fetch ALL discussions (or use a specific filtered endpoint if your Django has one)
    final response = await request.get('http://127.0.0.1:8000/json/discussion/');

    // 2. Decode and Filter client-side
    List<DiscussionEntry> listDiscussions = [];
    for (var d in response) {
      if (d != null) {
        DiscussionEntry discussion = DiscussionEntry.fromJson(d);
        
        // 3. CHECK: Does this discussion belong to the current forum?
        // We compare the foreign key (discussion.fields.forum) with the current forum ID (widget.forum.pk)
        if (discussion.fields.forum == widget.forum.pk) {
          listDiscussions.add(discussion);
        }
      }
    }
    return listDiscussions;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forum.fields.topic), // Show Forum Topic in App Bar
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== 1. FORUM DETAILS SECTION ==================
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.forum.fields.topic,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Created on: ${widget.forum.fields.dateCreated.toString().substring(0, 10)}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.forum.fields.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 2),
            
            // ================== 2. DISCUSSION LIST SECTION ==================
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Discussions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            FutureBuilder(
              future: fetchDiscussions(request),
              builder: (context, AsyncSnapshot<List<DiscussionEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("No discussions yet. Be the first!")),
                  );
                } else {
                  return ListView.builder(
                    // Important: shrinkWrap and physics allow ListView to exist inside SingleChildScrollView
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return DiscussionEntryCard(
                        discussion: snapshot.data![index],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      // Optional: Add a FloatingActionButton to add a new discussion to this forum
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a form to add discussion, passing widget.forum.pk
          print("Add discussion to forum ${widget.forum.pk}");
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}