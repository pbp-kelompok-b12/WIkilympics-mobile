// models/athlete_entry.dart
import 'dart:convert';

List<AthleteEntry> athleteEntryFromJson(String str) => List<AthleteEntry>.from(
  json.decode(str).map((x) => AthleteEntry.fromJson(x)),
);

String athleteEntryToJson(List<AthleteEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AthleteEntry {
  String pk;
  Fields fields;

  AthleteEntry({required this.pk, required this.fields});

  factory AthleteEntry.fromJson(Map<String, dynamic> json) =>
      AthleteEntry(pk: json["pk"], fields: Fields.fromJson(json["fields"]));

  Map<String, dynamic> toJson() => {"pk": pk, "fields": fields.toJson()};
}

class Fields {
  String athleteName;
  String athletePhoto;
  String country;
  String sport;
  String biography;

  Fields({
    required this.athleteName,
    required this.athletePhoto,
    required this.country,
    required this.sport,
    required this.biography,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    athleteName: json["athlete_name"],
    athletePhoto: json["athlete_photo"] ?? "",
    country: json["country"],
    sport: json["sport"],
    biography: json["biography"],
  );

  Map<String, dynamic> toJson() => {
    "athlete_name": athleteName,
    "athlete_photo": athletePhoto,
    "country": country,
    "sport": sport,
    "biography": biography,
  };
}
