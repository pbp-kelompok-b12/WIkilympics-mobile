// lib/athletes/models/athlete_entry.dart
import 'dart:convert';

List<AthleteEntry> athleteEntryFromJson(String str) => List<AthleteEntry>.from(
  json.decode(str).map((x) => AthleteEntry.fromJson(x)),
);

String athleteEntryToJson(List<AthleteEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AthleteEntry {
  int pk;
  Fields fields;

  AthleteEntry({required this.pk, required this.fields});

  factory AthleteEntry.fromJson(Map<String, dynamic> json) =>
      AthleteEntry(pk: json["pk"], fields: Fields.fromJson(json["fields"]));

  Map<String, dynamic> toJson() => {"pk": pk, "fields": fields.toJson()};
}

class Fields {
  String athleteName;
  String country;
  String sport;
  String biography;
  String athletePhoto;
  DateTime createdAt;

  Fields({
    required this.athleteName,
    required this.country,
    required this.sport,
    required this.biography,
    required this.athletePhoto,
    required this.createdAt,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    athleteName: json["athlete_name"] ?? "",
    country: json["country"] ?? "",
    sport: json["sport"] ?? "",
    biography: json["biography"] ?? "",
    athletePhoto: json["athlete_photo"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "athlete_name": athleteName,
    "country": country,
    "sport": sport,
    "biography": biography,
    "athlete_photo": athletePhoto,
    "created_at": createdAt.toIso8601String(),
  };
}
