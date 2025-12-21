import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/upcomingevents/models/events_entry.dart';
import 'package:wikilympics/upcomingevents/widgets/events_card.dart';
import 'package:wikilympics/upcomingevents/screens/add_event_screen.dart';
import 'package:wikilympics/upcomingevents/screens/events_detail_screen.dart';
import 'package:wikilympics/upcomingevents/screens/edit_event_screen.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});
  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  String _searchQuery = "";

  Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
    final response = await request.get('https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//upcoming_event/json/');
    List<EventEntry> events = [];
    for (var item in response) {
      events.add(EventEntry.fromJson(item));
    }
    return events;
  }

  void _deleteEvent(CookieRequest request, int id) async {
    final response = await request.post(
      'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//upcoming_event/delete-event-flutter/$id/',
      {},
    );

    if (mounted) {
      if (response['status'] == 'success' || response['success'] == true) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Event deleted successfully!", style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete event: ${response['message']}", style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isAdmin = request.jsonData['is_superuser'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      appBar: AppBar(
        title: Image.asset('assets/wikilympics_banner.png', height: 60, fit: BoxFit.contain),
        backgroundColor: AppColors.kBgGrey,
        iconTheme: IconThemeData(color: AppColors.kPrimaryNavy),
        elevation: 0,
      ),

      //  drawer navigasi
      drawer: const LeftDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  style: GoogleFonts.montserrat(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search events by name or sports...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: const Color(0xFF03045E)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Upcoming Events',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001D3D),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EventEntry>>(
              future: fetchEvents(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Upcoming Events found.', style: GoogleFonts.poppins()));
                } else {
                  var filteredData = snapshot.data!.where((event) =>
                  event.name.toLowerCase().contains(_searchQuery) ||
                      event.sportBranch.toLowerCase().contains(_searchQuery)).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(24.0),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final event = filteredData[index];
                      return EventsCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                          );
                        },
                        onEdit: isAdmin
                            ? () async {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditEventScreen(event: event)),
                          );
                          if (refresh == true) setState(() {});
                        }
                            : null,
                        onDelete: isAdmin
                            ? () => _showDeleteDialog(request, event)
                            : null,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventScreen()));
          if (refresh == true) setState(() {});
        },
        backgroundColor: const Color(0xFF03045E),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  void _showDeleteDialog(CookieRequest request, EventEntry event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF03045E))),
        content: Text("Are you sure you want to delete ${event.name}?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(request, event.id);
            },
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}