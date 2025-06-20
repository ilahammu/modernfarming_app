import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    'Condition',
    'Created At',
  ].obs;

  final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
  final RxList<ChartModel> dataList = <ChartModel>[].obs;
  final Rx<String?> selectedSheep = Rx<String?>(null);
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
  var isLoading = true.obs;

  late String _baseUrl;
  late String _chipEndpoint;
  late String _mpuEndpoint;
  late String _mpuGraphEndpoint;

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  void handlerDropdownSheep(String? sheep) {
    selectedSheep.value = sheep;
    fetchGyroData();
  }

  void handlerDropdownHistory(String? history) {
    selectedHistory.value = history!;
  }

  RxList<ChartModel> chartData = <ChartModel>[].obs;

  void updateChartData(List<ChartModel> newData) {
    chartData.value = newData;
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
          final chipId = item['id'].toString();
          if (!seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId
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

  void fetchGyroData() async {
    try {
      if (selectedSheep.value == null) {
        print('No sheep selected');
        return;
      }

      final response = await _http.get(
        '$_baseUrl$_mpuGraphEndpoint',
        query: {'chip_id': selectedSheep.value},
      );

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
            id: item['id'].toString(),
            chipId: item['chip_id'].toString(),
            mean_x: item['mean_x']?.toDouble() ?? 0,
            mean_y: item['mean_y']?.toDouble() ?? 0,
            mean_z: item['mean_z']?.toDouble() ?? 0,
            createdAt: item['createdAt'] != null
                ? DateTime.parse(item['createdAt'])
                : DateTime.now(),
          );

          dataList.add(chartModel);

          double xValue =
              chartModel.createdAt.millisecondsSinceEpoch.toDouble();
          newAccXData.add(FlSpot(xValue, chartModel.mean_x ?? 0));
          newAccYData.add(FlSpot(xValue, chartModel.mean_y ?? 0));
          newAccZData.add(FlSpot(xValue, chartModel.mean_z ?? 0));

          minXValue = xValue < minXValue ? xValue : minXValue;
          maxXValue = xValue > maxXValue ? xValue : maxXValue;
          minYValue = [
            chartModel.mean_x ?? 0,
            chartModel.mean_y ?? 0,
            chartModel.mean_z ?? 0,
            minYValue
          ].reduce((a, b) => a < b ? a : b);
          maxYValue = [
            chartModel.mean_x ?? 0,
            chartModel.mean_y ?? 0,
            chartModel.mean_z ?? 0,
            maxYValue
          ].reduce((a, b) => a > b ? a : b);
        }

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

        accXData.value = newAccXData;
        accYData.value = newAccYData;
        accZData.value = newAccZData;
        distanceData.value = newDistanceData;
        minX.value = minXValue;
        maxX.value = maxXValue;
        minY.value = minYValue;
        maxY.value = maxYValue;

        fetchDataTable(currentPage);
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get(
        '$_baseUrl$_mpuEndpoint',
        query: {'page': page.toString()},
      );
      if (response.statusCode == 200) {
        final data = response.body;
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          final createdAt =
              DateTime.parse(item['createdAt']).add(Duration(hours: 7));
          listDataTable.add(DataTableModel({
            'CHIP-ID': item['chip_id'],
            'Sheep Name': item['nama_domba'],
            'Gender': item['jenis_kelamin'],
            'X': item['mean_x'].toString(),
            'Y': item['mean_y'].toString(),
            'Z': item['mean_z'].toString(),
            'Condition': item['classification'],
            'Created At': DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
          }));
        }
        listDataTable.refresh();
        currentPage = page;
        totalPage = data['pagination']['totalPages'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data table: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _baseUrl = dotenv.env['BASE_URL']!;
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT']!;
    _mpuEndpoint = dotenv.env['MPU_ENDPOINT']!;
    _mpuGraphEndpoint = dotenv.env['GRAFIK_MPU_ENDPOINT']!;

    fetchSheepData();
    fetchGyroData();
    fetchListDomba();
    fetchDataTable(currentPage);
    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => fetchGyroData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
