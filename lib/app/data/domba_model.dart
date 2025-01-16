class DombaModels {
  final List<Baris> data;

  DombaModels({required this.data});

  factory DombaModels.fromJson(Map<String, dynamic> json) {
    var dataList = <Baris>[];
    if (json['data'] is Map<String, dynamic>) {
      dataList.add(Baris.fromJson(json['data']));
    } else if (json['data'] is List) {
      dataList = (json['data'] as List<dynamic>)
          .map((i) => Baris.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    return DombaModels(data: dataList);
  }
}

class Baris {
  final String id;
  final String namaDomba;
  final int usia;
  final String jenisKelamin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? berat;
  final double? beratPakan;
  final double? suhu;
  final double? kelembapan;
  final double? tinggi;
  final bool kondisi;

  Baris({
    required this.id,
    required this.namaDomba,
    required this.usia,
    required this.jenisKelamin,
    required this.createdAt,
    required this.updatedAt,
    this.berat,
    this.beratPakan,
    this.suhu,
    this.kelembapan,
    this.tinggi,
    required this.kondisi,
  });

  factory Baris.fromJson(Map<String, dynamic> json) {
    print('Parsing Baris from JSON: $json'); // Add this line
    return Baris(
      id: json['id'] ?? '',
      namaDomba: json['nama_domba'] ?? '',
      usia: json['usia'] ?? 0,
      jenisKelamin: json['jenis_kelamin'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      berat: (json['berat'] != null)
          ? double.tryParse(json['berat'].toString())
          : null,
      beratPakan: (json['berat_pakan'] != null)
          ? double.tryParse(json['berat_pakan'].toString())
          : null,
      suhu: (json['suhu'] != null)
          ? double.tryParse(json['suhu'].toString())
          : null,
      kelembapan: (json['kelembapan'] != null)
          ? double.tryParse(json['kelembapan'].toString())
          : null,
      tinggi: (json['tinggi'] != null)
          ? double.tryParse(json['tinggi'].toString())
          : null,
      kondisi: json['kondisi'] == 1 ||
          json['kondisi'] ==
              true, // Convert 1/true to true and 0/false to false
    );
  }
}
