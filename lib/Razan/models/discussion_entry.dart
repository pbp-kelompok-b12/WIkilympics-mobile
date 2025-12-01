// To parse this JSON data, do
//
//     final discussionEntry = discussionEntryFromJson(jsonString);

import 'dart:convert';

List<DiscussionEntry> discussionEntryFromJson(String str) => List<DiscussionEntry>.from(json.decode(str).map((x) => DiscussionEntry.fromJson(x)));

String discussionEntryToJson(List<DiscussionEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiscussionEntry {
    String model;
    int pk;
    Fields fields;

    DiscussionEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory DiscussionEntry.fromJson(Map<String, dynamic> json) => DiscussionEntry(
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
    int username;
    int forum;
    String discuss;
    DateTime dateCreated;

    Fields({
        required this.username,
        required this.forum,
        required this.discuss,
        required this.dateCreated,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        username: json["username"],
        forum: json["forum"],
        discuss: json["discuss"],
        dateCreated: DateTime.parse(json["date_created"]),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "forum": forum,
        "discuss": discuss,
        "date_created": dateCreated.toIso8601String(),
    };
}
