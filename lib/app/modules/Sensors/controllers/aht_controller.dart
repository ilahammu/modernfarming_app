import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<DataTableModelMonth> listDataTableMonth =
      <DataTableModelMonth>[].obs;
  final RxList<DataTableModelWeek> listDataTableWeek =
      <DataTableModelWeek>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;

  final RxList<ChartModel> suhuList = <ChartModel>[].obs;
  final RxList<ChartModel> kelembapanList = <ChartModel>[].obs;

  final Rx<String?> selectedSheep = Rx<String?>(null);
  final Rx<String?> selectedTimeRange = Rx<String?>(null);

  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;

  var selectedHistory = "Current".obs;
  var isFetching = false.obs;
  var isLoading = true.obs;

  late String _baseUrl;
  late String _chipEndpoint;
  late String _ahtEndpoint;
  late String _ahtDailyEndpoint;
  late String _ahtWeeklyEndpoint;
  late String _ahtMonthlyEndpoint;

  @override
  void onInit() {
    super.onInit();

    _baseUrl = dotenv.env['BASE_URL'] ?? 'https://modernfarming-api.vercel.app';
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT'] ?? '/api/chip';
    _ahtEndpoint = dotenv.env['AHT_ENDPOINT'] ?? '/api/aht';
    _ahtDailyEndpoint = dotenv.env['AHT_DAILY_ENDPOINT'] ?? '/api/aht/daily';
    _ahtWeeklyEndpoint = dotenv.env['AHT_WEEKLY_ENDPOINT'] ?? '/api/aht/weekly';
    _ahtMonthlyEndpoint =
        dotenv.env['AHT_MONTHLY_ENDPOINT'] ?? '/api/aht/monthly';

    tanggalLahirController = TextEditingController();
    fetchSheepData();
    fetchListDomba();
    fetchIndeksData();
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchDataTable(currentPage);

    timer ??= Timer.periodic(
      const Duration(seconds: 5),
      (Timer t) => fetchIndeksData(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    tanggalLahirController.dispose();
    super.dispose();
  }

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  void handlerDropdownSheep(String? sheep) {
    if (sheep != null && sheep.isNotEmpty) {
      selectedSheep.value = sheep;
      if (selectedTimeRange.value != null && selectedDate.value != null) {
        fetchIndeksData();
      }
    } else {
      print("Invalid sheep selected: $sheep");
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

  Future<void> fetchSheepData() async {
    isLoading.value = true;
    try {
      int page = 1;
      final Set<String> seenChipIds = {};
      final List<Map<String, String>> allSheep = [];

      while (true) {
        final response = await _http.get(
          '$_baseUrl$_chipEndpoint',
          query: {'page': page.toString()},
        );

        if (response.statusCode == 200) {
          final data = response.body['data']['rows'];
          for (var item in data) {
            final chipId = item['id']?.toString();
            if (chipId != null &&
                chipId.isNotEmpty &&
                !seenChipIds.contains(chipId)) {
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
          throw Exception("Failed to load sheep data");
        }
      }

      sheepList.assignAll(allSheep);
      sheepList.refresh();

      if (selectedSheep.value == null && allSheep.isNotEmpty) {
        selectedSheep.value = null;
      }
    } catch (e) {
      print("Error fetching sheep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchListDomba() async {
    try {
      final response = await _http.get('$_baseUrl$_chipEndpoint');
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        final Set<String> seenChipIds = {};
        sheepList.clear();
        for (var item in data) {
          final chipId = item['id']?.toString();
          if (chipId != null &&
              chipId.isNotEmpty &&
              !seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId,
            });
          }
        }
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      print("Error fetching sheep list: $e");
    }
  }

  Future<void> fetchDailyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url = '$_baseUrl$_ahtDailyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data.isEmpty) return;

        listDataTable.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['id'].toString(),
            suhu: double.tryParse(item['suhu'].toString()) ?? 0.0,
            kelembaban: double.tryParse(item['kelembapan'].toString()) ?? 0.0,
            chipId: item['chip_id'],
            createdAt:
                DateTime.parse(item['createdAt']).add(const Duration(hours: 7)),
          );

          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu'].toString(),
            'Kelembaban (%)': item['kelembapan'].toString(),
            'Created At':
                DateFormat('yyyy-MM-dd HH:mm').format(chartModel.createdAt),
          }));

          dataList.add(chartModel);
        }
        dataList.refresh();
      } else {
        throw Exception('Failed to load daily data');
      }
    } catch (e) {
      print('Error fetching daily data: $e');
    }
  }

  Future<void> fetchWeeklyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url = '$_baseUrl$_ahtWeeklyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data.isEmpty) return;

        listDataTableWeek.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['date'],
            suhu: double.tryParse(item['averageSuhu'].toString()) ?? 0.0,
            kelembaban:
                double.tryParse(item['averageKelembapan'].toString()) ?? 0.0,
            chipId: chipId,
            createdAt: DateTime.parse(item['date']),
          );
          dataList.add(chartModel);
        }
        dataList.refresh();
      } else {
        throw Exception('Failed to load weekly data');
      }
    } catch (e) {
      print('Error fetching weekly data: $e');
    }
  }

  Future<void> fetchMonthlyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url = '$_baseUrl$_ahtMonthlyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['averageValues'];
        if (data == null || data.isEmpty) return;

        listDataTableMonth.clear();
        dataList.clear();

        for (var item in data) {
          final avgSuhu = double.tryParse(item['avgSuhu'].toString()) ?? 0.0;
          final avgKelembapan =
              double.tryParse(item['avgKelembapan'].toString()) ?? 0.0;

          final chartModel = ChartModel(
            id: item['week'].toString(),
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
        throw Exception('Failed to load monthly data');
      }
    } catch (e) {
      print('Error fetching monthly data: $e');
    }
  }

  void fetchIndeksData() async {
    try {
      if (selectedSheep.value == null || selectedDate.value == null) return;

      final String timeRange = selectedTimeRange.value ?? 'Daily';

      if (timeRange == 'Daily') {
        await fetchDailyData(selectedDate.value!);
      } else if (timeRange == 'Weekly') {
        await fetchWeeklyData(selectedDate.value!);
      } else if (timeRange == 'Monthly') {
        await fetchMonthlyData(selectedDate.value!);
      }
    } catch (e) {
      print('Error fetching Indeks data: $e');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get(
        '$_baseUrl$_ahtEndpoint',
        query: {'page': page.toString()},
      );
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu']?.toString(),
            'Kelembaban (%)': item['kelembapan']?.toString(),
            'Created At': item['createdAt']?.toString(),
          }));
        }
        currentPage = page;
        totalPage = data['pagination']['totalPages'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data table: $e');
    }
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
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchListDomba();
    fetchDataTable(currentPage);
  }
}
