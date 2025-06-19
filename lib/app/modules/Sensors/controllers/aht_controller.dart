import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model_month.dart';
import 'package:monitoring_kambing/app/data/datatable_model_week.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import package dotenv

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
  var isLoading = true.obs; // Tambahkan indikator loading

  // --- Tambahkan variabel untuk base URL dan endpoint dari .env ---
  late String _baseUrl;
  late String _chipEndpoint;
  late String _ahtEndpoint;
  late String _ahtDailyEndpoint;
  late String _ahtWeeklyEndpoint;
  late String _ahtMonthlyEndpoint;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi variabel dari .env
    _baseUrl = dotenv.env['BASE_URL']!;
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT']!;
    _ahtEndpoint = dotenv.env['AHT_ENDPOINT']!;
    _ahtDailyEndpoint = dotenv.env['AHT_DAILY_ENDPOINT']!;
    _ahtWeeklyEndpoint = dotenv.env['AHT_WEEKLY_ENDPOINT']!;
    _ahtMonthlyEndpoint = dotenv.env['AHT_MONTHLY_ENDPOINT']!;

    tanggalLahirController = TextEditingController();
    fetchSheepData();
    fetchListDomba();
    fetchIndeksData();
    // fetch data
    fetchDailyData(DateTime.now());
    fetchWeeklyData(DateTime.now());
    fetchMonthlyData(DateTime.now());
    fetchDataTable(currentPage);
    timer = Timer.periodic(const Duration(seconds: 5),
        (Timer t) => fetchIndeksData()); // Gunakan const Duration
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
        // --- Gunakan variabel dari .env di sini ---
        final response = await _http.get(
          '$_baseUrl$_chipEndpoint',
          query: {'page': page.toString()},
        );

        if (response.statusCode == 200) {
          final data = response.body['data']['rows'];
          print("Data received: ${data.length} items"); // Debugging log

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
      // --- Gunakan variabel dari .env di sini ---
      final response = await _http.get('$_baseUrl$_chipEndpoint');
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
        print("Sheep list: $sheepList");
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      print("Error fetching sheep list: $e");
      throw Exception('Failed to fetch sheep list: $e');
    }
  }

  Future<void> fetchDailyData(DateTime selectedDate) async {
    try {
      print('Fetching daily data...');
      final String formattedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate);
      final String chipId = selectedSheep.value ?? '';
      // --- Gunakan variabel dari .env di sini ---
      final String url = '$_baseUrl$_ahtDailyEndpoint/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body['data'];
        print('Decoded data: $data');

        if (data == null || data.isEmpty) {
          // Tambah pengecekan null
          print('No data returned');
          listDataTable.clear(); // Bersihkan list jika tidak ada data
          dataList.clear(); // Bersihkan chart data jika tidak ada data
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
            createdAt: DateTime.parse(item['createdAt'])
                .add(const Duration(hours: 7)), // Gunakan const Duration
          );

          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu'].toString(),
            'Kelembaban (%)': item['kelembapan']
                .toString(), // Perbaikan typo: 'kelembabpan' menjadi 'kelembapan'
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
      // --- Gunakan variabel dari .env di sini ---
      final String url = '$_baseUrl$_ahtWeeklyEndpoint/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final List<dynamic> dataListResponse =
            data['data']; // Perbaiki nama variabel
        print('Decoded data: $dataListResponse');

        if (dataListResponse == null || dataListResponse.isEmpty) {
          // Tambah pengecekan null
          print('No data returned');
          listDataTableWeek.clear(); // Bersihkan list jika tidak ada data
          this.dataList.clear(); // Bersihkan chart data jika tidak ada data
          return; // Exit if no data
        }

        listDataTableWeek.clear();
        this.dataList.clear();

        // Ensure we have exactly 7 data points, centered around the selected date
        final List<ChartModel> limitedWeeklyData = [];
        for (var item in dataListResponse) {
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
        dataList.refresh(); // Refresh chart data
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
      // --- Gunakan variabel dari .env di sini ---
      final String url = '$_baseUrl$_ahtMonthlyEndpoint/$formattedDate/$chipId';
      print(url);
      final response = await _http.get(url);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Asumsi monthlyDataResponseFromJson sudah ada dan sesuai
        final data = monthlyDataResponseFromJson(response.bodyString!);
        print('Decoded data: $data');

        if (data.averageValues.isEmpty) {
          print('No average values returned');
          listDataTableMonth.clear(); // Bersihkan list jika tidak ada data
          dataList.clear(); // Bersihkan chart data jika tidak ada data
          return; // Exit if no average values
        }

        listDataTableMonth.clear();
        dataList.clear();

        for (var item in data.averageValues) {
          print('Processing item: $item');
          final avgSuhu = item.avgSuhu;
          final avgKelembapan = item.avgKelembapan;

          final chartModel = ChartModel(
            id: item.week
                .toString(), // Asumsi 'week' adalah ID yang relevan untuk monthly data
            suhu: avgSuhu,
            kelembaban: avgKelembapan,
            chipId: chipId,
            createdAt: selectedDate, // Atau gunakan item.createdAt jika ada
          );

          listDataTableMonth.add(DataTableModelMonth({
            chartModel.id.toString():
                avgSuhu, // Anda bisa sesuaikan ini jika ingin menampilkan kedua suhu dan kelembaban di tabel
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
      if (selectedSheep.value == null || selectedDate.value == null) {
        print(
            "No sheep or date selected for environment index data."); // Tambah log
        return; // Check if no sheep or date is selected
      }

      final String timeRange = selectedTimeRange.value ?? 'Daily';

      if (timeRange == 'Daily') {
        await fetchDailyData(selectedDate.value!);
      } else if (timeRange == 'Weekly') {
        await fetchWeeklyData(selectedDate.value!);
      } else if (timeRange == 'Monthly') {
        // Perbaikan: sebelumnya ada dua 'Weekly'
        await fetchMonthlyData(selectedDate.value!);
      }
    } catch (e) {
      print('Error in fetchIndeksData: $e'); // Perbaiki log
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataTable(int page) async {
    try {
      // --- Gunakan variabel dari .env di sini ---
      final response = await _http
          .get('$_baseUrl$_ahtEndpoint', query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          final createdAt = DateTime.parse(item['createdAt'])
              .add(const Duration(hours: 7)); // Gunakan const Duration
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'].toString(),
            'Suhu °C': item['suhu']?.toString(),
            'Kelembaban (%)': item['kelembapan']?.toString(),
            'Created At': DateFormat('yyyy-MM-dd HH:mm')
                .format(createdAt), // Format tanggal untuk tampilan
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
    listDataTableMonth.clear(); // Perbaikan: tambahkan ()
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
