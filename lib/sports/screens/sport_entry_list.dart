import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:wikilympics/sports/models/sport_entry.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/sports/widgets/sport_entry_card.dart';

class SportEntryListPage extends StatefulWidget {
  const SportEntryListPage({super.key});

  @override
  State<SportEntryListPage> createState() => _SportEntryListPageState();
}

class _SportEntryListPageState extends State<SportEntryListPage> {
  Future<List<SportEntry>> fetchSports(CookieRequest request) async {
    final response =
        await request.get('http://localhost:8000/sports/json/');

    List<SportEntry> listSports = [];
    for (var d in response) {
      if (d != null) {
        listSports.add(SportEntry.fromJson(d));
      }
    }

    return listSports;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Olympic Sports'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<SportEntry>>(
        future: fetchSports(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'There are no sports yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final sports = snapshot.data!;

          return ListView.builder(
            itemCount: sports.length,
            itemBuilder: (context, index) {
              return SportEntryCard(
                sport: sports[index],
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          "You clicked on ${sports[index].fields.sportName}",
                        ),
                      ),
                    );
                },
              );
            },
          );
        },
      ),
    );
  }
}