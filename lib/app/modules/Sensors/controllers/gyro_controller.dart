import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';

class GyroController extends GetxController {
  Timer? timer;
  int totalPage = 1;
  int currentPage = 1;

  final GetConnect _http = GetConnect();
  final listColumnTable = [
    'CHIP-ID',
    'Sheep Name',
    'Gender',
    'X',
    'Y',
    'Z',
    'Distance',
    'Created At',
  ].obs;

  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;
  final Rx<String?> selectedSheep = Rx<String?>(null);
  final List<String> listDomba = <String>[].obs;
  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;
  // Chart data
  final RxList<FlSpot> accXData = <FlSpot>[].obs;
  final RxList<FlSpot> accYData = <FlSpot>[].obs;
  final RxList<FlSpot> accZData = <FlSpot>[].obs;
  final RxList<FlSpot> distanceData = <FlSpot>[].obs;
  // Chart axis limits
  final Rx<double> minX = 0.0.obs;
  final Rx<double> maxX = 0.0.obs;
  final Rx<double> minY = 0.0.obs;
  final Rx<double> maxY = 0.0.obs;
  var selectedHistory = "Current".obs;
  var isFetching = false.obs;

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  var isLoading = true.obs;

  void handlerDropdownSheep(String? sheep) {
    selectedSheep.value = sheep!;
    fetchGyroData(); // Fetch data when a sheep is selected
  }

  void handlerDropdownHistory(String? history) {
    selectedHistory.value = history!;
  }

  RxList<ChartModel> chartData = <ChartModel>[].obs;

  void updateChartData(List<ChartModel> newData) {
    chartData.value = newData;
  }

  // Fetch data for the dropdown
  Future<void> fetchSheepData() async {
    isLoading.value = true;
    try {
      int page = 1;
      final Set<String> seenChipIds = {};
      final List<Map<String, String>> allSheep = [];

      while (true) {
        final response = await _http.get(
          'https://l7xgct6c-3000.asse.devtunnels.ms/api/chip',
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
      final response =
          await _http.get('https://l7xgct6c-3000.asse.devtunnels.ms/api/chip');
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

  void fetchGyroData() async {
    try {
      if (selectedSheep.value == null) {
        print('No sheep selected');
        return;
      }

      print('Fetching data for sheep: ${selectedSheep.value}');
      final response = await _http.get(
        'https://l7xgct6c-3000.asse.devtunnels.ms/api/mpu/graph',
        query: {'chip_id': selectedSheep.value},
      );

      print('Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body;
        dataList.clear();
        List<FlSpot> newAccXData = [];
        List<FlSpot> newAccYData = [];
        List<FlSpot> newAccZData = [];
        List<FlSpot> newDistanceData = [];

        double minXValue = double.infinity;
        double maxXValue = double.negativeInfinity;
        double minYValue = double.infinity;
        double maxYValue = double.negativeInfinity;

        for (var item in data['data']['rows']) {
          final chartModel = ChartModel(
            id: item['id'].toString(), // Ensure id is treated as String
            chipId: item['chip_id'].toString(),
            acc_x: item['acc_x']?.toDouble() ?? 0,
            acc_y: item['acc_y']?.toDouble() ?? 0,
            acc_z: item['acc_z']?.toDouble() ?? 0,
            tinggi: item['tinggi']?.toDouble() ?? 0,
            createdAt: item['createdAt'] != null
                ? DateTime.parse(item['createdAt'])
                : DateTime.now(),
          );

          dataList.add(chartModel);

          double xValue =
              chartModel.createdAt.millisecondsSinceEpoch.toDouble();
          newAccXData.add(FlSpot(xValue, chartModel.acc_x ?? 0));
          newAccYData.add(FlSpot(xValue, chartModel.acc_y ?? 0));
          newAccZData.add(FlSpot(xValue, chartModel.acc_z ?? 0));
          newDistanceData.add(FlSpot(xValue, chartModel.tinggi ?? 0));

          // Update min and max values
          minXValue = xValue < minXValue ? xValue : minXValue;
          maxXValue = xValue > maxXValue ? xValue : maxXValue;
          minYValue = [
            chartModel.acc_x ?? 0,
            chartModel.acc_y ?? 0,
            chartModel.acc_z ?? 0,
            chartModel.tinggi ?? 0,
            minYValue
          ].reduce((a, b) => a < b ? a : b);
          maxYValue = [
            chartModel.acc_x ?? 0,
            chartModel.acc_y ?? 0,
            chartModel.acc_z ?? 0,
            chartModel.tinggi ?? 0,
            maxYValue
          ].reduce((a, b) => a > b ? a : b);
        }

        // Sort the data by x-value (timestamp)
        newAccXData.sort((a, b) => a.x.compareTo(b.x));
        newAccYData.sort((a, b) => a.x.compareTo(b.x));
        newAccZData.sort((a, b) => a.x.compareTo(b.x));
        newDistanceData.sort((a, b) => a.x.compareTo(b.x));

        if (newAccXData.length > 20) {
          newAccXData = newAccXData.sublist(newAccXData.length - 20);
          newAccYData = newAccYData.sublist(newAccYData.length - 20);
          newAccZData = newAccZData.sublist(newAccZData.length - 20);
          newDistanceData =
              newDistanceData.sublist(newDistanceData.length - 20);
        }
        // Update all reactive variables at once
        accXData.value = newAccXData;
        accYData.value = newAccYData;
        accZData.value = newAccZData;
        distanceData.value = newDistanceData;
        minX.value = minXValue;
        maxX.value = maxXValue;
        minY.value = minYValue;
        maxY.value = maxYValue;

        print(
            'Data fetched and processed for chart: ${newAccXData.length} items');
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Failed to fetch data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get(
          'https://l7xgct6c-3000.asse.devtunnels.ms/api/mpu',
          query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'],
            'Sheep Name': item['nama_domba'],
            'Gender': item['jenis_kelamin'],
            'X': item['acc_x'].toString(),
            'Y': item['acc_y'].toString(),
            'Z': item['acc_z'].toString(),
            'Distance': item['tinggi'].toString(),
            'Created At': item['createdAt'],
          }));
        }
        currentPage = page;
        totalPage = data['pagination']['totalPages'];
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
    fetchSheepData();
    fetchGyroData();
    fetchListDomba();
    fetchDataTable(currentPage);
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => fetchGyroData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
