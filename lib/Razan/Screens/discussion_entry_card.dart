import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikilympics/Razan/models/discussion_entry.dart';
import 'package:wikilympics/Razan/Screens/edit_discussion.dart';

class DiscussionEntryCard extends StatefulWidget {
  final DiscussionEntry discussion;
  final VoidCallback? onDeleted;
  
  const DiscussionEntryCard({
    super.key,
    required this.discussion,
    this.onDeleted,
  });

  @override
  State<DiscussionEntryCard> createState() => _DiscussionEntryCardState();
}

class _DiscussionEntryCardState extends State<DiscussionEntryCard> {
  bool _canDelete = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _checkDeletePermission();
  }

  Future<void> _checkDeletePermission() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('user_id');
    final isSuperuser = prefs.getBool('is_superuser') ?? false;
    
    setState(() {
      _canDelete = (currentUserId == widget.discussion.fields.username_id) || isSuperuser;
    });
  }

  Future<void> _editDiscussion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiscussionPage(discussion: widget.discussion),
      ),
    );
    if (result == true) {
      widget.onDeleted?.call();
    }
  }

  Future<void> _deleteDiscussion() async {
    final request = context.read<CookieRequest>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Discussion"),
        content: const Text("Are you sure you want to delete this discussion?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              setState(() => _isDeleting = true);
              
              try {
                // Get current user info from prefs to send as fallback
                final prefs = await SharedPreferences.getInstance();
                final currentUserId = prefs.getInt('user_id') ?? 0;
                final isSuperuser = prefs.getBool('is_superuser') ?? false;
                
                final response = await request.post(
                  'http://127.0.0.1:8000/forum_section/discussion/${widget.discussion.pk}/delete/',
                  {
                    '_method': 'DELETE',
                    'user_id': currentUserId.toString(),
                    'is_superuser': isSuperuser.toString(),
                  },
                );
                
                if (mounted) {
                  setState(() => _isDeleting = false);
                  
                  if (response is Map && response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Discussion deleted successfully!")),
                    );
                    widget.onDeleted?.call();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${response['message'] ?? 'Unknown error'}")),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isDeleting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Exception: $e")),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
                Expanded(
                  child: Text(
                    widget.discussion.fields.username, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      
                    ),
                  ),
                ),
                Text(
                  "${widget.discussion.fields.dateCreated.hour}:${widget.discussion.fields.dateCreated.minute}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                if (_canDelete)
                  Tooltip(
                    message: "Edit discussion",
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: _editDiscussion,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                if (_canDelete)
                  Tooltip(
                    message: "You can delete this discussion",
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: _isDeleting ? null : _deleteDiscussion,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  )
                else
                  Tooltip(
                    message: "Only creator or admin can delete",
                    child: Icon(Icons.delete, color: Colors.grey.shade300, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.discussion.fields.discuss,
              style: const TextStyle(fontSize: 15,
              color: Color(0xFF03045e),)
              ,
              
            ),
          ],
        ),
      ),
    );
  }
}