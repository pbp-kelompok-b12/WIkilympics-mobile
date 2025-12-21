import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikilympics/app_colors.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';

class AddForumPage extends StatefulWidget {
  final ForumEntry? forum;
  const AddForumPage({super.key, this.forum});

  @override
  State<AddForumPage> createState() => _AddForumPageState();
}

class _AddForumPageState extends State<AddForumPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.forum != null) {
      _topicController.text = widget.forum!.fields.topic;
      _descriptionController.text = widget.forum!.fields.description;
      _thumbnailController.text = widget.forum!.fields.thumbnail;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _submitForum(CookieRequest request) async {
    if (_topicController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Topic and description are required")),
      );
      return;
    }

    // Validate thumbnail URL if provided
    String thumbnailUrl = _thumbnailController.text.trim();
    if (thumbnailUrl.isNotEmpty) {
      // Add http:// if URL doesn't have a scheme
      if (!thumbnailUrl.startsWith('http://') && !thumbnailUrl.startsWith('https://')) {
        thumbnailUrl = 'https://$thumbnailUrl';
      }
      
      // Basic URL validation
      try {
        Uri.parse(thumbnailUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid image URL (e.g., https://example.com/image.jpg)")),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Get user_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Not Authenticated"),
              content: const Text("You must be logged in to create forums."),
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

      final endpoint = widget.forum != null
          ? 'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//forum_section/forum/${widget.forum!.pk}/edit/'
          : 'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//forum_section/forum/add/';
      
      final response = await request.post(
        endpoint,
        {
          'topic': _topicController.text,
          'description': _descriptionController.text,
          'thumbnail': thumbnailUrl,
          'user_id': userId.toString(),
        },
      );

      if (context.mounted) {
        setState(() => _isLoading = false);
        
        if (response is Map) {
          if (response['status'] == 'success') {
            final message = widget.forum != null ? "Forum updated successfully!" : "Forum created successfully!";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
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
        title: Text(widget.forum != null ? "Edit Forum" : "Create Forum"),
        backgroundColor: const Color(0xFF3f5f90),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const LeftDrawer(),
      body: Container(
        color: const Color(0xFFF5F7FB),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create a New Forum",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Topic field
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: "Topic",
                  hintText: "Enter forum topic",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Enter forum description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Thumbnail URL field (optional)
              TextField(
                controller: _thumbnailController,
                decoration: InputDecoration(
                  labelText: "Thumbnail URL (Optional)",
                  hintText: "https://example.com/image.jpg",
                  helperText: "Use a direct image URL (http:// or https://). URLs without a scheme will get https:// added automatically.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kAccentLime,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _submitForum(request),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create Forum"),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
