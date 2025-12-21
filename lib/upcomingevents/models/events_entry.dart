// To parse this JSON data, do
//
//     final eventEntry = eventEntryFromJson(jsonString);

import 'dart:convert';

List<EventEntry> eventEntryFromJson(String str) => List<EventEntry>.from(json.decode(str).map((x) => EventEntry.fromJson(x)));

String eventEntryToJson(List<EventEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventEntry {
  int id;
  String name;
  DateTime date;
  String location;
  String organizer;
  String sportBranch;
  String imageUrl;
  String description;

  EventEntry({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.organizer,
    required this.sportBranch,
    required this.imageUrl,
    required this.description,
  });

  factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
    id: json["id"],
    name: json["name"],
    date: DateTime.parse(json["date"]),
    location: json["location"],
    organizer: json["organizer"],
    sportBranch: json["sport_branch"],
    imageUrl: json["image_url"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "location": location,
    "organizer": organizer,
    "sport_branch": sportBranch,
    "image_url": imageUrl,
    "description": description,
  };
}
