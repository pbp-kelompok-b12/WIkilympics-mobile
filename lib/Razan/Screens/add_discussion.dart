import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/widgets/left_drawer.dart';

class AddDiscussionPage extends StatefulWidget {
  final ForumEntry forum;
  const AddDiscussionPage({super.key, required this.forum});

  @override
  State<AddDiscussionPage> createState() => _AddDiscussionPageState();
}

class _AddDiscussionPageState extends State<AddDiscussionPage> {
  final TextEditingController _discussionController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _discussionController.dispose();
    super.dispose();
  }

  void _submitDiscussion(CookieRequest request) async {
    if (_discussionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a discussion")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get username from SharedPreferences stored during login
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      
      if (username == null || username.isEmpty) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Not Authenticated"),
              content: const Text("You must be logged in to post discussions."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
        return;
      }

      final response = await request.post(
        'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//forum_section/forum/add-discussion/',
        {
          'forum': widget.forum.pk.toString(),
          'discuss': _discussionController.text,
          'username': username,
        },
      );

      if (context.mounted) {
        setState(() => _isLoading = false);
        
        if (response is Map) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Discussion added successfully!")),
            );
            Navigator.pop(context, true); // Return true to refresh
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: Text("Status: ${response['status']}\nMessage: ${response['message']}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  )
                ],
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text("Invalid response format.\nResponse: $response\nType: ${response.runtimeType}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      }
      
    } catch (e) {
      print("Exception: $e");
      if (context.mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Exception: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            
            Image.asset(
              'assets/wikilympics_banner.png',
              fit: BoxFit.contain,
              height: 60,
            ),
          ],
        ),
        backgroundColor: const Color(0xFFf5f7fb),
       
      ),
      drawer: const LeftDrawer(),
      body: Container(
        color: AppColors.kBgGrey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forum: ${widget.forum.fields.topic}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _discussionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Share your thoughts...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kAccentLime,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : () => _submitDiscussion(request),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Post Discussion"),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}