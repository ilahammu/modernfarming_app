import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model_month.dart';
import 'package:monitoring_kambing/app/data/datatable_model_week.dart';

class WeightFoodController extends GetxController {
  Timer? timer;
  int totalPage = 1;
  int currentPage = 1;

  final GetConnect _http = GetConnect();
  final listColumnTable = [
    'CHIP-ID',
    'Sheep Name',
    'Gender',
    'Food Weight (Gram)',
    'Raw Food Weight (Gram)',
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
      fetchLoadcellPakanData();
    }
  }

  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<DataTableModelMonth> listDataTableMonth =
      <DataTableModelMonth>[].obs;
  final RxList<DataTableModelWeek> listDataTableWeek =
      <DataTableModelWeek>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;

  final Rx<String?> selectedSheep = Rx<String?>(null);
  final Rx<String?> selectedTimeRange = Rx<String?>(null);

  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;

  var selectedHistory = "Current".obs;
  var isFetching = false.obs;
  var isLoading = true.obs;

  late String _baseUrl;
  late String _chipEndpoint;
  late String _pakanEndpoint;
  late String _pakanDailyEndpoint;
  late String _pakanWeeklyEndpoint;
  late String _pakanMonthlyEndpoint;

  @override
  void onInit() {
    super.onInit();

    _baseUrl = dotenv.env['BASE_URL']!;
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT']!;
    _pakanEndpoint = dotenv.env['PAKAN_ENDPOINT']!;
    _pakanDailyEndpoint = dotenv.env['PAKAN_DAILY_ENDPOINT']!;
    _pakanWeeklyEndpoint = dotenv.env['PAKAN_WEEKLY_ENDPOINT']!;
    _pakanMonthlyEndpoint = dotenv.env['PAKAN_MONTHLY_ENDPOINT']!;

    tanggalLahirController = TextEditingController();
    fetchSheepData();
    fetchListDomba();
    fetchLoadcellPakanData();
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchDataTable(currentPage);

    timer ??= Timer.periodic(
      const Duration(seconds: 15),
      (Timer t) => fetchLoadcellPakanData(),
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
        fetchLoadcellPakanData();
      }
    } else {
      print("Invalid sheep selected: $sheep");
    }
  }

  void handlerDropdownTimeRange(String? range) {
    selectedTimeRange.value = range;
    print('Selected Time Range: $range');
    if (selectedSheep.value != null && selectedDate.value != null) {
      fetchLoadcellPakanData();
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
      final String url = '$_baseUrl$_pakanDailyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data.isEmpty) return;

        listDataTable.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['id'].toString(),
            beratPakan: item['berat_pakan'] is double
                ? item['berat_pakan']
                : double.tryParse(item['berat_pakan'].toString()) ?? 0.0,
            beratPakanmentah: item['berat_pakan_mentah'] is double
                ? item['berat_pakan_mentah']
                : double.tryParse(item['berat_pakan_mentah'].toString()) ?? 0.0,
            chipId: item['chip_id'].toString(),
            createdAt:
                DateTime.parse(item['createdAt']).add(const Duration(hours: 7)),
          );

          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Food Weight (Gram)': item['berat_pakan'].toString(),
            'Raw Food Weight (Gram)': item['berat_pakan_mentah'].toString(),
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
      final String url =
          '$_baseUrl$_pakanWeeklyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data.isEmpty) return;

        listDataTableWeek.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['date'],
            beratPakan: item['averagePakan'] is double
                ? item['averagePakan']
                : double.tryParse(item['averagePakan'].toString()) ?? 0.0,
            beratPakanmentah: item['averagePakanMentah'] is double
                ? item['averagePakanMentah']
                : double.tryParse(item['averagePakanMentah'].toString()) ?? 0.0,
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
      final String url =
          '$_baseUrl$_pakanMonthlyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['averageValues'];
        if (data == null || data.isEmpty) return;

        listDataTableMonth.clear();
        dataList.clear();

        for (var item in data) {
          final avgBeratPakan =
              double.tryParse(item['avgBeratPakan'].toString()) ?? 0.0;
          final avgBeratPakanMentah =
              double.tryParse(item['avgBeratPakanMentah'].toString()) ?? 0.0;

          final chartModel = ChartModel(
            id: item['week'].toString(),
            beratPakan: avgBeratPakan,
            beratPakanmentah: avgBeratPakanMentah,
            chipId: chipId,
            createdAt: selectedDate,
          );

          listDataTableMonth.add(DataTableModelMonth({
            chartModel.id.toString(): avgBeratPakan,
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

  void fetchLoadcellPakanData() async {
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
      print('Error fetching Loadcell Pakan data: $e');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get(
        '$_baseUrl$_pakanEndpoint',
        query: {'page': page.toString()},
      );
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          final createdAt =
              DateTime.parse(item['createdAt']).add(const Duration(hours: 7));
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Sheep Name': item['nama_domba'].toString(),
            'Gender': item['jenis_kelamin'].toString(),
            'Food Weight (Gram)': item['berat_pakan'].toString(),
            'Raw Food Weight (Gram)': item['berat_pakan_mentah'].toString(),
            'Created At': DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
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
    fetchLoadcellPakanData();
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchListDomba();
    fetchDataTable(currentPage);
  }
}
