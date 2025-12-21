// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
  String id;
  String title;
  String content;
  String category;
  DateTime created;
  String thumbnail;
  int likes;
  bool isLiked;
  bool isDisliked;
  String? sportId;

  ArticleEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.created,
    required this.thumbnail,
    required this.likes,
    required this.isLiked,
    required this.isDisliked,
    this.sportId,
  });

  factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    category: json["category"],
    created: DateTime.parse(json["created"]),
    thumbnail: json["thumbnail"] ?? "",
    likes: json["likes"] ?? 0,
    isLiked: json["is_liked"] ?? false,
    isDisliked: json["is_disliked"] ?? false,
    sportId: json["sport_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "category": category,
    "created": created.toIso8601String(),
    "thumbnail": thumbnail,
    "likes": likes,
    "is_liked": isLiked,
    "is_disliked": isDisliked,
    "sport_id": sportId,
  };
}
