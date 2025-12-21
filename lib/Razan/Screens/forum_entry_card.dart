import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikilympics/Razan/models/forum_entry.dart';
import 'package:wikilympics/Razan/Screens/add_forum.dart';
import 'package:wikilympics/app_colors.dart';

class ForumEntryCard extends StatefulWidget {
  final ForumEntry forum;
  final VoidCallback onTap;
  final VoidCallback? onDeleted;
  
  const ForumEntryCard({
    super.key,
    required this.forum,
    required this.onTap,
    this.onDeleted,
  });

  @override
  State<ForumEntryCard> createState() => _ForumEntryCardState();
}

class _ForumEntryCardState extends State<ForumEntryCard> {
  bool _canDelete = false;

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
      _canDelete = (currentUserId == widget.forum.fields.name) || isSuperuser;
    });
  }

  Future<void> _editForum() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddForumPage(forum: widget.forum),
      ),
    );
    if (result == true) {
      widget.onDeleted?.call();
    }
  }

  Future<void> _deleteForum() async {
    final request = context.read<CookieRequest>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Forum"),
        content: const Text("Are you sure you want to delete this forum? All discussions in this forum will also be deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {           
                final prefs = await SharedPreferences.getInstance();
                final currentUserId = prefs.getInt('user_id') ?? 0;
                final isSuperuser = prefs.getBool('is_superuser') ?? false;
                
                final response = await request.post(
                  'https://razan-muhammad-wikilympics.pbp.cs.ui.ac.id//forum_section/forum/${widget.forum.pk}/delete/',
                  {
                    '_method': 'DELETE',
                    'user_id': currentUserId.toString(),
                    'is_superuser': isSuperuser.toString(),
                  },
                );
                
                if (mounted) {
                  if (response is Map && response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Forum deleted successfully!")),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail (Left side)
                if (widget.forum.fields.thumbnail.isNotEmpty && widget.forum.fields.thumbnail != "null")
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ThumbnailImage(url: widget.forum.fields.thumbnail),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.forum, color: Colors.indigo, size: 40),
                  ),
                
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.forum.fields.topic,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF03045e),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.forum.fields.description,
                        style: TextStyle(color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.forum.fields.dateCreated.year}-${widget.forum.fields.dateCreated.month}-${widget.forum.fields.dateCreated.day}",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_canDelete)
                  Tooltip(
                    message: "Edit forum",
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: _editForum,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                if (_canDelete)
                  Tooltip(
                    message: "Delete forum",
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: _deleteForum,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  )
                else
                  Tooltip(
                    message: "You don't have permission to delete this forum",
                    child: Icon(Icons.delete, color: Colors.grey.shade300, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  final String url;

  const _ThumbnailImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      cacheHeight: 80,
      cacheWidth: 80,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          color: AppColors.kAccentLime,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                'Failed to load',
                style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          width: 80,
          height: 80,
          color: AppColors.kAccentLime,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}
