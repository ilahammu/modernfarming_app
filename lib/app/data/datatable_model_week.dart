import 'dart:convert';

class DataTableModelWeek {
  final Map<String, dynamic> data;
  DataTableModelWeek(this.data);
}

WeeklyDataResponse weeklyDataResponseFromJson(String str) =>
    WeeklyDataResponse.fromJson(json.decode(str));

String weeklyDataResponseToJson(WeeklyDataResponse data) =>
    json.encode(data.toJson());

class WeeklyDataResponse {
  WeeklyDataResponse({
    required this.averageValues,
  });

  List<AverageValue> averageValues;

  factory WeeklyDataResponse.fromJson(Map<String, dynamic> json) =>
      WeeklyDataResponse(
        averageValues: List<AverageValue>.from(
            json["averageValues"].map((x) => AverageValue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "averageValues":
            List<dynamic>.from(averageValues.map((x) => x.toJson())),
      };
}

class AverageValue {
  AverageValue({
    required this.date,
    required this.avgBerat,
  });

  String date;
  double avgBerat;

  factory AverageValue.fromJson(Map<String, dynamic> json) => AverageValue(
        date: json["date"],
        avgBerat: json["avgBerat"]?.toDouble() ?? 0.0, // Handle null case
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "avgBerat": avgBerat,
      };
}
