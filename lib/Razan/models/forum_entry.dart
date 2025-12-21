// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) => List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
    String model;
    int pk;
    Fields fields;


    ForumEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int name;
    String topic;
    String description;
    DateTime dateCreated;
    String thumbnail;

    Fields({
        required this.name,
        required this.topic,
        required this.description,
        required this.dateCreated,
        required this.thumbnail,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        topic: json["topic"],
        description: json["description"],
        dateCreated: DateTime.parse(json["date_created"]),
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "topic": topic,
        "description": description,
        "date_created": dateCreated.toIso8601String(),
        "thumbnail": thumbnail,
    };
}
