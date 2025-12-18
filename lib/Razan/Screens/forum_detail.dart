import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/Razan/models/discussion_entry.dart';
import 'package:wikilympics/Razan/Screens/discussion_entry_card.dart';
import 'package:wikilympics/Razan/Screens/add_discussion.dart';


class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;
  const ForumDetailPage({super.key, required this.forum});
  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  Future<List<DiscussionEntry>> fetchDiscussions(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/forum_section/forums/json-dis/');

    List<DiscussionEntry> listDiscussions = [];
    for (var d in response) {
      if (d != null) {
        DiscussionEntry discussion = DiscussionEntry.fromJson(d);
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
        title: Text(widget.forum.fields.topic), 
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDiscussionPage(forum: widget.forum),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}