import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/Razan/Screens/forum_entry_card.dart';

import 'package:wikilympics/Razan/models/discussion_entry.dart';

class ForumListPage extends StatefulWidget {
  const ForumListPage({super.key});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  Future<List<ForumEntry>> fetchForums(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/forum_section/forums/json-for/');
    
    List<ForumEntry> listForums = [];
    for (var d in response) {
      if (d != null) {
        listForums.add(ForumEntry.fromJson(d));
      }
    }
    return listForums;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 91, 209),
      appBar: AppBar(
        title: const Text('Forums'),
      ),
      body: FutureBuilder(
        future: fetchForums(request),
        builder: (context, AsyncSnapshot<List<ForumEntry>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No forums available."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final forum = snapshot.data![index];
                return ForumEntryCard(
                  forum: forum,
                  onTap: () {
                   
                    print("Tapped on forum: ${forum.fields.topic}");
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}