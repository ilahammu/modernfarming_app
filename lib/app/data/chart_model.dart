class ChartModel {
  String id;
  double? berat;
  double? panjang;
  double? tinggi;
  double? suhu;
  double? kelembaban;
  double? beratPakan;
  double? acc_x;
  double? acc_y;
  double? acc_z;
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
    this.kelembaban,
    this.acc_x,
    this.acc_y,
    this.acc_z,
    this.kondisi,
    required this.createdAt,
  });
}
