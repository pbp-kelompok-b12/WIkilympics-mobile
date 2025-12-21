import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/Razan/Screens/forum_entry_card.dart';
import 'package:wikilympics/Razan/Screens/forum_detail.dart';
import 'package:wikilympics/Razan/Screens/add_forum.dart';
import 'package:wikilympics/widgets/left_drawer.dart';

class ForumListPage extends StatefulWidget {
  const ForumListPage({super.key});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<ForumEntry> _filterForums(List<ForumEntry> forums) {
    if (forums.isEmpty || _searchQuery.isEmpty) {
      return forums;
    }
    return forums.where((forum) {
      return forum.fields.topic.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/wikilympics_banner.png',
          fit: BoxFit.contain,
          height: 60,
        ),
        centerTitle: false,
      ),
      drawer: const LeftDrawer(),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forums',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF03045e),),
                ),
                const SizedBox(height: 12),
                TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search forums by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchForums(request),
              builder: (context, AsyncSnapshot<List<ForumEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No forums available."));
                } else {
                  final filteredForums = _filterForums(snapshot.data ?? []);
                  if (filteredForums.isEmpty) {
                    return const Center(child: Text("No forums match your search."));
                  }
                  return ListView.builder(
                    itemCount: filteredForums.length,
                    itemBuilder: (context, index) {
                      final forum = filteredForums[index];
                      return ForumEntryCard(
                        forum: forum,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForumDetailPage(forum: forum),
                            ),
                          );
                        },
                        onDeleted: () {
                          setState(() {}); // refresh
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE6EC4C),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddForumPage(),
            ),
          );
          if (result == true) {
            setState(() {}); // also refresh
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}