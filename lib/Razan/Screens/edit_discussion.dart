import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikilympics/Razan/models/discussion_entry.dart';
import 'package:wikilympics/app_colors.dart';

class EditDiscussionPage extends StatefulWidget {
  final DiscussionEntry discussion;
  const EditDiscussionPage({super.key, required this.discussion});

  @override
  State<EditDiscussionPage> createState() => _EditDiscussionPageState();
}

class _EditDiscussionPageState extends State<EditDiscussionPage> {
  final TextEditingController _discussionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _discussionController.text = widget.discussion.fields.discuss;
  }

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
      // Get user_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final isSuperuser = prefs.getBool('is_superuser') ?? false;
      
      if (userId == null) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Not Authenticated"),
              content: const Text("You must be logged in to edit discussions."),
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
        'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//forum_section/discussion/${widget.discussion.pk}/edit/',
        {
          'discuss': _discussionController.text,
          'user_id': userId.toString(),
          'is_superuser': isSuperuser.toString(),
        },
      );

      if (context.mounted) {
        setState(() => _isLoading = false);
        
        if (response is Map) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Discussion updated successfully!")),
            );
            Navigator.pop(context, true);
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: Text(response['message'] ?? 'Unknown error'),
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
        backgroundColor: AppColors.kBgGrey,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kSecondaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        
        title: Row(
          children: [
            
            Image.asset(
              'assets/wikilympics_banner.png',
              fit: BoxFit.contain,
              height: 60,
            ),
          ],
        ),
      ),
     
      body: Container(
        color: const Color(0xFFF5F7FB),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Editing Discussion",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _discussionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Discussion Content",
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
                    ? const CircularProgressIndicator()
                    : const Text("Update Discussion"),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
