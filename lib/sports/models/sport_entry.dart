// To parse this JSON data, do
//
//     final sportEntry = sportEntryFromJson(jsonString);

import 'dart:convert';

List<SportEntry> sportEntryFromJson(String str) => List<SportEntry>.from(json.decode(str).map((x) => SportEntry.fromJson(x)));
String sportEntryToJson(List<SportEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SportEntry {
    Model model;
    String pk;
    Fields fields;

    SportEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory SportEntry.fromJson(Map<String, dynamic> json) => SportEntry(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String sportName;
    String sportImg;
    String sportDescription;
    ParticipationStructure participationStructure;
    SportType sportType;
    String countryOfOrigin;
    String countryFlagImg;
    int firstYearPlayed;
    String historyDescription;
    String equipment;

    Fields({
        required this.sportName,
        required this.sportImg,
        required this.sportDescription,
        required this.participationStructure,
        required this.sportType,
        required this.countryOfOrigin,
        required this.countryFlagImg,
        required this.firstYearPlayed,
        required this.historyDescription,
        required this.equipment,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        sportName: json["sport_name"],
        sportImg: json["sport_img"] ?? "",
        sportDescription: json["sport_description"],
        participationStructure: participationStructureValues.map[json["participation_structure"]]!,
        sportType: sportTypeValues.map[json["sport_type"]]!,
        countryOfOrigin: json["country_of_origin"],
        countryFlagImg: json["country_flag_img"] ?? "",
        firstYearPlayed: json["first_year_played"],
        historyDescription: json["history_description"],
        equipment: json["equipment"],
    );

    Map<String, dynamic> toJson() => {
        "sport_name": sportName,
        "sport_img": sportImg,
        "sport_description": sportDescription,
        "participation_structure": participationStructureValues.reverse[participationStructure],
        "sport_type": sportTypeValues.reverse[sportType],
        "country_of_origin": countryOfOrigin,
        "country_flag_img": countryFlagImg,
        "first_year_played": firstYearPlayed,
        "history_description": historyDescription,
        "equipment": equipment,
    };
}

enum ParticipationStructure {
    BOTH,
    INDIVIDUAL,
    TEAM
}

final participationStructureValues = EnumValues({
    "both": ParticipationStructure.BOTH,
    "individual": ParticipationStructure.INDIVIDUAL,
    "team": ParticipationStructure.TEAM
});

enum SportType {
     WATER_SPORT,
     STRENGTH_SPORT,
     ATHLETIC_SPORT,
     RACKET_SPORT,
     BALL_SPORT,
     COMBAT_SPORT,
     TARGET_SPORT,
}

final sportTypeValues = EnumValues({
     "water_sport": SportType.WATER_SPORT,
     "strength_sport": SportType.STRENGTH_SPORT,
     "athletic_sport": SportType.ATHLETIC_SPORT,
     "racket_sport": SportType.RACKET_SPORT,
     "ball_sport": SportType.BALL_SPORT,
     "combat_sport": SportType.COMBAT_SPORT,
     "target_sport": SportType.TARGET_SPORT,
});

enum Model {
    SPORTS_SPORTS
}

final modelValues = EnumValues({
    "sports.sports": Model.SPORTS_SPORTS
});

// Helper class untuk melakukan mapping dua arah antara String (JSON) dan Enum (Dart).
class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}