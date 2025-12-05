import 'package:flutter/material.dart';
import 'package:wikilympics/models/article/article_entry.dart';
import 'package:intl/intl.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleEntry article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final formattedDate = DateFormat('dd MMMM yyyy').format(article.created);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Article", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.thumbnail,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 250, 
                color: Colors.grey, 
                child: const Center(child: Text("Image Error"))
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1929),
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // General info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0F1929), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "General Info",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F1929),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.category, "Category: ${article.category}"),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.calendar_today, "Publish Date: $formattedDate"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1929), 
                      borderRadius: BorderRadius.circular(20),
                      // Efek glow kuning sedikit di bawah (opsional sesuai screenshot)
                      boxShadow: [
                         BoxShadow(color: const Color(0xFFD2F665).withOpacity(0.3), offset: Offset(0,4), blurRadius: 0)
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            color: Color(0xFFD2F665),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris info icon + text
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFA63535)), // Merah bata seperti di screenshot
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F1929),
            ),
          ),
        ),
      ],
    );
  }
}