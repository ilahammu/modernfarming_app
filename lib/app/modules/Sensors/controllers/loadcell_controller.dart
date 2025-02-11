import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model_month.dart';
import 'package:monitoring_kambing/app/data/datatable_model_week.dart';

class LoadcellController extends GetxController {
  Timer? timer;
  int totalPage = 1;
  int currentPage = 1;

  final GetConnect _http = GetConnect();
  final listColumnTable = [
    'CHIP-ID',
    'Sheep Name',
    'Sex',
    'Weight (KG)',
    'Created At',
  ].obs;

  // Meemilih domba sesuoi tanggal
  late TextEditingController tanggalLahirController;

  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  String? tanggalLahirValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Tanggal Lahir Tidak Boleh Kosong";
    } else {
      return null;
    }
  }

  // list of data table,sheep,and ist for dropdown
  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<DataTableModelMonth> listDataTableMonth =
      <DataTableModelMonth>[].obs;
  final RxList<DataTableModelWeek> listDataTableWeek =
      <DataTableModelWeek>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;

  // for pick sheep and range time
  final Rx<String?> selectedSheep = Rx<String?>(null);
  final Rx<String?> selectedTimeRange = Rx<String?>(null);

  // Membuat variabel sheepList yang berisi list dari Map<String, String>
  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;

  var selectedHistory = "Current".obs;
  var isFetching = false.obs;
  var isLoading = true.obs;

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  void handlerDropdownSheep(String? sheep) {
    selectedSheep.value = sheep!;
    if (selectedTimeRange.value != null && selectedDate.value != null) {
      fetchLoadcellData(); // Fetch data when a sheep is selected
    }
  }

  void handlerDropdownTimeRange(String? range) {
    selectedTimeRange.value = range;
    if (selectedSheep.value != null && selectedDate.value != null) {
      fetchLoadcellData();
    }
  }

  void handlerDropdownHistory(String? history) {
    selectedHistory.value = history!;
  }

  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
    if (selectedSheep.value != null && selectedTimeRange.value != null) {
      fetchLoadcellData();
    }
  }

  Future<void> fetchSheepData() async {
    isLoading.value = true;
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
          throw Exception("Failed to load sheep data");
        }
      }

      sheepList.assignAll(allSheep); // Perbarui daftar dropdown
      sheepList.refresh(); // Paksa UI diperbarui

      // Hanya set default jika belum ada yang dipilih sebelumnya
      if (selectedSheep.value == null && allSheep.isNotEmpty) {
        selectedSheep.value = null; // Pastikan tetap null agar hint muncul
      }
    } catch (e) {
      print("Error fetching sheep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchListDomba() async {
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
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
        print("Sheep list: $sheepList");
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      throw Exception('Failed to fetch sheep list: $e');
    }
  }

  Future<void> fetchDailyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/loadcellbadan/daily/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];

        if (data.isEmpty) {
          return; // Exit if no data
        }

        listDataTable.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['id'].toString(), // Handle id as String
            berat: item['berat'] is double
                ? item['berat']
                : double.tryParse(item['berat'].toString()) ?? 0.0,
            chipId: item['chip_id'].toString(),
            createdAt:
                DateTime.parse(item['createdAt']).add(Duration(hours: 7)),
          );

          // Add to DataTable with formatted time in GMT+7
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Weight (KG)': item['berat'].toString(),
            'Created At':
                DateFormat('yyyy-MM-dd HH:mm').format(chartModel.createdAt),
          }));

          dataList.add(chartModel);
        }

        dataList.refresh();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchWeeklyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/loadcellbadan/weekly/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final List<dynamic> dataList = data['data'];

        if (dataList.isEmpty) {
          return; // Exit if no data
        }

        listDataTableWeek.clear();
        this.dataList.clear();

        // Ensure we have exactly 7 data points, centered around the selected date
        final List<ChartModel> limitedWeeklyData = [];
        for (var item in dataList) {
          final chartModel = ChartModel(
            id: item['date'], // Handle id as String
            berat: item['averageBerat'] is double
                ? item['averageBerat']
                : double.tryParse(item['averageBerat'].toString()) ?? 0.0,
            chipId: chipId,
            createdAt: DateTime.parse(item['date']),
          );
          limitedWeeklyData.add(chartModel);
        }

        // Update the data list for the chart
        this.dataList.addAll(limitedWeeklyData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchMonthlyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          'http://localhost:3000/api/loadcellbadan/monthly/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = monthlyDataResponseFromJson(response.bodyString!);

        if (data.averageValues.isEmpty) {
          return; // Exit if no average values
        }

        listDataTableMonth.clear();
        dataList.clear();

        for (var item in data.averageValues) {
          final avgBerat = item.avgBerat;

          final chartModel = ChartModel(
            id: item.week.toString(),
            berat: avgBerat,
            chipId: chipId,
            createdAt: selectedDate,
          );

          listDataTableMonth.add(DataTableModelMonth({
            chartModel.id.toString(): avgBerat,
          }));

          dataList.add(chartModel);
        }

        dataList.refresh();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data');
    }
  }

  void fetchLoadcellData() async {
    try {
      if (selectedSheep.value == null || selectedDate.value == null)
        return; // Check if no sheep or date is selected

      final String timeRange = selectedTimeRange.value ?? 'Daily';

      if (timeRange == 'Daily') {
        await fetchDailyData(selectedDate.value!);
      } else if (timeRange == 'Weekly') {
        await fetchWeeklyData(selectedDate.value!);
      } else if (timeRange == 'Monthly') {
        await fetchMonthlyData(selectedDate.value!);
      }
    } catch (e) {
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get(
          'http://localhost:3000/api/loadcellbadan',
          query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        listDataTable.clear();
        for (var item in data) {
          final createdAt =
              DateTime.parse(item['createdAt']).add(Duration(hours: 7));
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Sheep Name': item['nama_domba'].toString(),
            'Sex': item['jenis_kelamin'].toString(),
            'Weight (KG)': item['berat'].toString(),
            'Created At': DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
          }));
        }
        currentPage = page;
        totalPage = response.body['pagination']['totalPages'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void onInit() {
    super.onInit();
    tanggalLahirController = TextEditingController();
    fetchSheepData();
    fetchLoadcellData();
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchListDomba();
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
    listDataTableMonth.clear();
    dataList.clear();
    fetchSheepData();
    fetchLoadcellData();
    // fetch data
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    // fetch list domba dan data
    fetchListDomba();
    fetchDataTable(currentPage);
  }
}

extension on Map<String, dynamic> {}
