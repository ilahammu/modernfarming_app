import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model_month.dart';
import 'package:monitoring_kambing/app/data/datatable_model_week.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadcellController extends GetxController {
  Timer? timer;
  int totalPage = 1;
  int currentPage = 1;

  final GetConnect _http = GetConnect();
  final listColumnTable = [
    'CHIP-ID',
    'Sheep Name',
    'Gender',
    'Weight (KG)',
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

  late String _apiBaseUrl;
  late String _apiChipEndpoint;
  late String _apiLoadcellEndpoint;
  late String _apiLoadcellDailyEndpoint;
  late String _apiLoadcellWeeklyEndpoint;
  late String _apiLoadcellMonthlyEndpoint;

  @override
  void onInit() {
    super.onInit();
    _apiBaseUrl = dotenv.env['API_BASE_URL']!;
    _apiChipEndpoint = dotenv.env['API_CHIP_ENDPOINT']!;
    _apiLoadcellEndpoint = dotenv.env['API_LOADCELL_ENDPOINT']!;
    _apiLoadcellDailyEndpoint = dotenv.env['API_LOADCELL_DAILY_ENDPOINT']!;
    _apiLoadcellWeeklyEndpoint = dotenv.env['API_LOADCELL_WEEKLY_ENDPOINT']!;
    _apiLoadcellMonthlyEndpoint = dotenv.env['API_LOADCELL_MONTHLY_ENDPOINT']!;

    tanggalLahirController = TextEditingController();
    fetchSheepData();
    fetchLoadcellData();
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchListDomba();
    fetchDataTable(currentPage);

    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => fetchLoadcellData());
  }

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  void handlerDropdownSheep(String? sheep) {
    if (sheep != null && sheep.isNotEmpty) {
      selectedSheep.value = sheep;
      if (selectedTimeRange.value != null && selectedDate.value != null) {
        fetchLoadcellData();
      }
    } else {
      print("Invalid sheep selected: $sheep");
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
          '$_apiBaseUrl$_apiChipEndpoint',
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
            } else {
              print("Invalid or duplicate chip ID: $chipId");
            }
          }

          final totalPages = response.body['pagination']['totalPages'];
          if (page >= totalPages) break;
          page++;
        } else {
          print("Error fetching page $page: ${response.statusCode}");
          break;
        }
      }

      sheepList.assignAll(allSheep);
      sheepList.refresh();
    } catch (e) {
      print("Error fetching sheep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchListDomba() async {
    try {
      final response = await _http.get('$_apiBaseUrl$_apiChipEndpoint');
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        final Set<String> seenChipIds = {};
        sheepList.clear();
        for (var item in data) {
          final chipId = item['chip_id']?.toString();
          if (chipId != null &&
              chipId.isNotEmpty &&
              !seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId,
            });
          } else {
            print("Invalid or duplicate chip ID: $chipId");
          }
        }
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      print("Error fetching sheep list: $e");
      throw Exception('Failed to fetch sheep list: $e');
    }
  }

  void fetchLoadcellData() async {
    try {
      if (selectedSheep.value == null || selectedDate.value == null) {
        print("No sheep or date selected for Loadcell data.");
        return;
      }

      final String timeRange = selectedTimeRange.value ?? 'Daily';

      if (timeRange == 'Daily') {
        await fetchDailyData(selectedDate.value!);
      } else if (timeRange == 'Weekly') {
        await fetchWeeklyData(selectedDate.value!);
      } else if (timeRange == 'Monthly') {
        await fetchMonthlyData(selectedDate.value!);
      }
    } catch (e) {
      print('Error in fetchLoadcellData: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchDailyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          '$_apiBaseUrl$_apiLoadcellDailyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body['data'];

        if (data == null || data.isEmpty) {
          listDataTable.clear();
          dataList.clear();
          return;
        }

        listDataTable.clear();
        dataList.clear();

        for (var item in data) {
          final chartModel = ChartModel(
            id: item['id'].toString(),
            berat: item['berat'] is double
                ? item['berat']
                : double.tryParse(item['berat'].toString()) ?? 0.0,
            chipId: item['chip_id'].toString(),
            createdAt:
                DateTime.parse(item['createdAt']).add(const Duration(hours: 7)),
          );

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
        print('Failed to load daily data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching daily data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchWeeklyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          '$_apiBaseUrl$_apiLoadcellWeeklyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final List<dynamic> dataListResponse = data['data'];

        if (dataListResponse == null || dataListResponse.isEmpty) {
          listDataTableWeek.clear();
          this.dataList.clear();
          return;
        }

        listDataTableWeek.clear();
        this.dataList.clear();

        final List<ChartModel> limitedWeeklyData = [];
        for (var item in dataListResponse) {
          final chartModel = ChartModel(
            id: item['date'],
            berat: item['averageBerat'] is double
                ? item['averageBerat']
                : double.tryParse(item['averageBerat'].toString()) ?? 0.0,
            chipId: chipId,
            createdAt: DateTime.parse(item['date']),
          );
          limitedWeeklyData.add(chartModel);
        }

        this.dataList.addAll(limitedWeeklyData);
        dataList.refresh();
      } else {
        print('Failed to load weekly data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching weekly data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchMonthlyData(DateTime selectedDate) async {
    try {
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      final String url =
          '$_apiBaseUrl$_apiLoadcellMonthlyEndpoint/$formattedDate/$chipId';
      final response = await _http.get(url);

      if (response.statusCode == 200) {
        final data = monthlyDataResponseFromJson(response.bodyString!);

        if (data.averageValues.isEmpty) {
          listDataTableMonth.clear();
          dataList.clear();
          return;
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
        print('Failed to load monthly data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching monthly data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get('$_apiBaseUrl$_apiLoadcellEndpoint',
          query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        listDataTable.clear();
        for (var item in data) {
          final createdAt =
              DateTime.parse(item['createdAt']).add(const Duration(hours: 7));
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Sheep Name': item['nama_domba'].toString(),
            'Gender': item['jenis_kelamin'].toString(),
            'Weight (KG)': item['berat'].toString(),
            'Created At': DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
          }));
        }
        currentPage = page;
        totalPage = response.body['pagination']['totalPages'];
      } else {
        print('Failed to load table data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching table data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
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
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchListDomba();
    fetchDataTable(currentPage);
  }
}

extension on Map<String, dynamic> {}
