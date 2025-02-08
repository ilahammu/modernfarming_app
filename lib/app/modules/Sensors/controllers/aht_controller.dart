import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model_month.dart';
import 'package:monitoring_kambing/app/data/datatable_model_week.dart';

class IndeksLingkunganController extends GetxController {
  Timer? timer;
  int totalPage = 1;
  int currentPage = 1;

  final GetConnect _http = GetConnect();
  final listColumnTable = [
    'CHIP-ID',
    'Suhu °C',
    'Kelembaban (%)',
    'Created At',
  ].obs;

  late TextEditingController tanggalLahirController;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  String? tanggalLahirValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Tanggal Lahir Tidak Boleh Kosong";
    } else {
      return null;
    }
  }

  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
    if (selectedSheep.value != null && selectedTimeRange.value != null) {
      fetchIndeksData();
    }
  }

  // Data yang tersimpan
  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<DataTableModelMonth> listDataTableMonth =
      <DataTableModelMonth>[].obs;
  final RxList<DataTableModelWeek> listDataTableWeek =
      <DataTableModelWeek>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;

  // Sensor data
  final RxList<ChartModel> suhuList = <ChartModel>[].obs;
  final RxList<ChartModel> kelembapanList = <ChartModel>[].obs;

  //selected domba dan waktu
  final Rx<String?> selectedSheep = Rx<String?>(null);
  final Rx<String?> selectedTimeRange = Rx<String?>(null);

  // Memilih Domba
  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;

  var selectedHistory = "Current".obs;
  var isFetching = false.obs;

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  void handlerDropdownSheep(String? sheep) {
    selectedSheep.value = sheep!;
    if (selectedTimeRange.value != null && selectedDate.value != null) {
      fetchIndeksData(); // Fetch data when a sheep is selected
    }
  }

  void handlerDropdownTimeRange(String? range) {
    selectedTimeRange.value = range;
    print('Selected Time Range: $range');
    if (selectedSheep.value != null && selectedDate.value != null) {
      fetchIndeksData();
    }
  }

  void handlerDropdownHistory(String? history) {
    selectedHistory.value = history!;
  }

  void fetchSheepData() async {
    try {
      int page = 1;
      final Set<String> seenChipIds = {};
      final List<Map<String, String>> allSheep = [];

      while (true) {
        final response = await _http.get(
          'http://localhost:3000/api/chip',
          query: {'page': page.toString()},
        );

        if (response.statusCode == 200) {
          final data = response.body['data']['rows'];
          for (var item in data) {
            final chipId = item['id'].toString();
            if (!seenChipIds.contains(chipId)) {
              seenChipIds.add(chipId);
              allSheep.add({
                'nama_domba': item['nama_domba'].toString(),
                'chip_id': chipId,
              });
            }
          }

          final totalPages = response.body['pagination']['totalPages'];
          if (page >= totalPages) break;
          page++;
        } else {
          throw Exception('Failed to load sheep data');
        }
      }

      sheepList.value = allSheep;
    } catch (e) {
      throw Exception('Failed to fetch sheep data: $e');
    }
  }

  Future<void> fetchDailyData(DateTime selectedDate) async {
    try {
      print('Fetching daily data...');
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/aht/daily/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body['data'];
        print('Decoded data: $data');

        if (data.isEmpty) {
          print('No data returned');
          return; // Exit if no data
        }

        listDataTable.clear();
        dataList.clear();

        for (var item in data) {
          print('Processing item: $item');
          final chartModel = ChartModel(
            id: item['id'].toString(),
            suhu: item['suhu'] is double
                ? item['suhu']
                : double.tryParse(item['suhu'].toString()) ?? 0.0,
            kelembaban: item['kelembapan'] is double
                ? item['kelembapan']
                : double.tryParse(item['kelembapan'].toString()) ?? 0.0,
            chipId: item['chip_id'],
            createdAt:
                DateTime.parse(item['createdAt']).add(Duration(hours: 7)),
          );

          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu'].toString(),
            'Kelembaban (%)': item['kelembabpn'].toString(),
            'Created At':
                DateFormat('yyyy-MM-dd HH:mm').format(chartModel.createdAt),
          }));

          dataList.add(chartModel);
        }

        dataList.refresh();
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchWeeklyData(DateTime selectedDate) async {
    try {
      print('Fetching weekly data...');
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/aht/weekly/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final List<dynamic> dataList = data['data'];
        print('Decoded data: $dataList');

        if (dataList.isEmpty) {
          print('No data returned');
          return; // Exit if no data
        }

        listDataTableWeek.clear();
        this.dataList.clear();

        // Ensure we have exactly 7 data points, centered around the selected date
        final List<ChartModel> limitedWeeklyData = [];
        for (var item in dataList) {
          final chartModel = ChartModel(
            id: item['date'], // Handle id as String
            suhu: item['averageSuhu'] is double
                ? item['averageSuhu']
                : double.tryParse(item['averageSuhu'].toString()) ?? 0.0,
            kelembaban: item['averageKelembapan'] is double
                ? item['averageKelembapan']
                : double.tryParse(item['averageKelembapan'].toString()) ?? 0.0,
            chipId: chipId,
            createdAt: DateTime.parse(item['date']),
          );
          limitedWeeklyData.add(chartModel);
        }

        // Update the data list for the chart
        this.dataList.addAll(limitedWeeklyData);
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchMonthlyData(DateTime selectedDate) async {
    try {
      print('Fetching monthly data...');
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/aht/monthly/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = monthlyDataResponseFromJson(response.bodyString!);
        print('Decoded data: $data');

        if (data.averageValues.isEmpty) {
          print('No average values returned');
          return; // Exit if no average values
        }

        listDataTableMonth.clear();
        dataList.clear();

        for (var item in data.averageValues) {
          print('Processing item: $item');
          final avgSuhu = item.avgSuhu;
          final avgKelembapan = item.avgKelembapan;

          final chartModel = ChartModel(
            id: item.week.toString(),
            suhu: avgSuhu,
            kelembaban: avgKelembapan,
            chipId: chipId,
            createdAt: selectedDate,
          );

          listDataTableMonth.add(DataTableModelMonth({
            chartModel.id.toString(): avgSuhu,
          }));

          dataList.add(chartModel);
        }

        dataList.refresh();
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  void fetchIndeksData() async {
    try {
      if (selectedSheep.value == null || selectedDate.value == null)
        return; // Check if no sheep or date is selected

      final String timeRange = selectedTimeRange.value ?? 'Per-Hari';

      if (timeRange == 'Per-Hari') {
        await fetchDailyData(selectedDate.value!);
      } else if (timeRange == 'Per-Minggu') {
        await fetchWeeklyData(selectedDate.value!);
      } else if (timeRange == 'Per-Bulan') {
        await fetchMonthlyData(selectedDate.value!);
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  void fetchListDomba() async {
    print('Jumlah domba sebelum fetch: ${sheepList.length}');
    try {
      final response = await _http.get('http://localhost:3000/api/chip');
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        final Set<String> seenChipIds = {};
        sheepList.clear();
        for (var item in data) {
          final chipId = item['chip_id'].toString();
          if (!seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId
            });
          }
        }
        // Sort the list in ascending order
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      throw Exception('Failed to fetch sheep list: $e');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get('http://localhost:3000/api/aht',
          query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu']?.toString(),
            'Kelembaban (%)': item['kelembaban']?.toString(),
            'Created At': item['createdAt']?.toString(),
          }));
        }
        currentPage = page;
        totalPage = response.body['pagination']['totalPages'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSheepData();
    fetchListDomba();
    tanggalLahirController = TextEditingController();
    fetchIndeksData();
    // fetch data
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchDataTable(currentPage);
  }

  @override
  void dispose() {
    tanggalLahirController.dispose();
    super.dispose();
  }

  void resetState() {
    selectedSheep.value = null;
    selectedTimeRange.value = null;
    selectedDate.value = null;
    tanggalLahirController.clear();
    listDataTable.clear();
    listDataTableWeek.clear();
    dataList.clear();
    fetchSheepData();
    fetchIndeksData();
    // fetch data
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());

    fetchListDomba();
    fetchDataTable(currentPage);
  }
}
