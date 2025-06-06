class ChartModel {
  String id;
  double? berat;
  double? panjang;
  double? tinggi;
  double? suhu;
  double? kelembaban;
  double? beratPakan;
  double? beratPakanmentah;
  double? mean_x;
  double? mean_y;
  double? mean_z;
  double? kondisi;
  String chipId;

  DateTime createdAt;

  ChartModel({
    required this.id,
    required this.chipId,
    this.panjang,
    this.tinggi,
    this.berat,
    this.suhu,
    this.beratPakan,
    this.beratPakanmentah,
    this.kelembaban,
    this.mean_x,
    this.mean_y,
    this.mean_z,
    this.kondisi,
    required this.createdAt,
  });
}
