import 'dart:convert';

class DataTableModelMonth {
  final Map<String, dynamic> data;
  DataTableModelMonth(this.data);
}

MonthlyDataResponse monthlyDataResponseFromJson(String str) =>
    MonthlyDataResponse.fromJson(json.decode(str));

String monthlyDataResponseToJson(MonthlyDataResponse data) =>
    json.encode(data.toJson());

class MonthlyDataResponse {
  MonthlyDataResponse({
    required this.averageValues,
  });

  List<AverageValue> averageValues;

  factory MonthlyDataResponse.fromJson(Map<String, dynamic> json) =>
      MonthlyDataResponse(
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
    required this.week,
    required this.avgBerat,
    required this.avgBeratPakan,
    required this.avgSuhu,
    required this.avgKelembapan,
  });

  int week;
  double avgBerat;
  double avgBeratPakan;
  double avgSuhu;
  double avgKelembapan;

  factory AverageValue.fromJson(Map<String, dynamic> json) => AverageValue(
        week: json["week"],
        avgBerat: json["avgBerat"] is double
            ? json["avgBerat"]
            : double.tryParse(json["avgBerat"].toString()) ??
                0.0, // Handle null case
        avgBeratPakan: json["avgBeratPakan"] is double
            ? json["avgBeratPakan"]
            : double.tryParse(json["avgBeratPakan"].toString()) ??
                0.0, // Handle null case
        avgSuhu: json["avgSuhu"] is double
            ? json["avgSuhu"]
            : double.tryParse(json["avgSuhu"].toString()) ?? 0.0,
        avgKelembapan: json["avgKelembapan"] is double
            ? json["avgKelembapan"]
            : double.tryParse(json["avgKelembapan"].toString()) ??
                0.0, // Handle null case
      );

  Map<String, dynamic> toJson() => {
        "week": week,
        "avgBerat": avgBerat,
        "avgBeratPakan": avgBeratPakan,
        "avgSuhu": avgSuhu,
        "avgKelembapan": avgKelembapan,
      };
}
