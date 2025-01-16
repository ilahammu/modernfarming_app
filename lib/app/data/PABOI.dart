// import 'dart:async';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:get/get.dart';
// import 'package:monitoring_kambing/app/data/chart_model.dart';
// import 'package:monitoring_kambing/app/data/datatable_model.dart';

// class GyroController extends GetxController {
//   Timer? timer;
//   int totalPage = 1;
//   int currentPage = 1;

//   final GetConnect _http = GetConnect();
//   final listColumnTable = [
//     'CHIP-ID',
//     'Nama Domba',
//     'Jenis Kelamin',
//     'Rate Roll',
//     'Rate Pitch',
//     'Rate Yaw',
//     'Angle Roll',
//     'Angle Pitch',
//     'Jarak',
//     'Created At',
//   ].obs;

//   final RxList<DataTableModel> listDataTable = <DataTableModel>[].obs;
//   final RxList<ChartModel> dataList = <ChartModel>[].obs;
//   final Rx<String?> selectedSheep = Rx<String?>(null);
//   final List<String> listDomba = <String>[].obs;
//   final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;
//   final RxList<FlSpot> gyroXData = <FlSpot>[].obs;
//   final RxList<FlSpot> gyroYData = <FlSpot>[].obs;
//   final RxList<FlSpot> gyroZData = <FlSpot>[].obs;
//   final RxList<FlSpot> angleRollData = <FlSpot>[].obs;
//   final RxList<FlSpot> anglePitchData = <FlSpot>[].obs;
//   final Rx<double> minX = 0.0.obs;
//   final Rx<double> maxX = 0.0.obs;
//   final Rx<double> minY = 0.0.obs;
//   final Rx<double> maxY = 0.0.obs;
//   var selectedHistory = "Current".obs;
//   var isFetching = false.obs;

//   void handlerSwitch(bool value) {
//     isFetching.value = value;
//   }

//   void handlerDropdownSheep(String? sheep) {
//     selectedSheep.value = sheep!;
//     fetchGyroData(); // Fetch data when a sheep is selected
//   }

//   void handlerDropdownHistory(String? history) {
//     selectedHistory.value = history!;
//   }

//   RxList<ChartModel> chartData = <ChartModel>[].obs;

//   void updateChartData(List<ChartModel> newData) {
//     chartData.value = newData;
//   }

//   // Fetch data for the dropdown
//   void fetchSheepData() async {
//     try {
//       int page = 1;
//       final Set<String> seenChipIds = {};
//       final List<Map<String, String>> allSheep = [];

//       while (true) {
//         final response = await _http.get(
//           'http://localhost:3000/api/v2/chip',
//           query: {'page': page.toString()},
//         );

//         if (response.statusCode == 200) {
//           final data = response.body['data']['rows'];
//           for (var item in data) {
//             final chipId = item['id'].toString();

//             if (!seenChipIds.contains(chipId)) {
//               seenChipIds.add(chipId);
//               allSheep.add({
//                 'nama_domba': item['nama_domba'].toString(),
//                 'chip_id': chipId,
//               });
//             }
//           }

//           final totalPages = response.body['pagination']['totalPages'];
//           if (page >= totalPages) break;
//           page++;
//         } else {
//           throw Exception('Failed to load sheep data');
//         }
//       }

//       sheepList.value = allSheep;
//     } catch (e) {
//       throw Exception('Failed to fetch sheep data: $e');
//     }
//   }

//   void fetchGyroData() async {
//     try {
//       if (selectedSheep.value == null) {
//         print('No sheep selected');
//         return;
//       }

//       print('Fetching data for sheep: ${selectedSheep.value}');
//       final response = await _http.get(
//         'http://localhost:3000/api/v2/mpu/graph',
//         query: {'chip_id': selectedSheep.value},
//       );

//       print('Response data: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = response.body;
//         dataList.clear();
//         List<FlSpot> newGyroXData = [];
//         List<FlSpot> newGyroYData = [];
//         List<FlSpot> newGyroZData = [];
//         List<FlSpot> newAngleRollData = [];
//         List<FlSpot> newAnglePitchData = [];

//         double minXValue = double.infinity;
//         double maxXValue = double.negativeInfinity;
//         double minYValue = double.infinity;
//         double maxYValue = double.negativeInfinity;

//         for (var item in data['data']['rows']) {
//           final chartModel = ChartModel(
//             id: item['id'] ?? 0,
//             chipId: item['id'].toString(),
//             rate_roll: item['rate_roll']?.toDouble() ?? 0,
//             rate_pitch: item['rate_pitch']?.toDouble() ?? 0,
//             rate_yaw: item['rate_yaw']?.toDouble() ?? 0,
//             angle_roll: item['angle_roll']?.toDouble() ?? 0,
//             angle_pitch: item['angle_pitch']?.toDouble() ?? 0,
//             createdAt: item['createdAt'] != null
//                 ? DateTime.parse(item['createdAt'])
//                 : DateTime.now(),
//           );

//           dataList.add(chartModel);

//           double xValue =
//               chartModel.createdAt.millisecondsSinceEpoch.toDouble();
//           newGyroXData.add(FlSpot(xValue, chartModel.rate_roll ?? 0));
//           newGyroYData.add(FlSpot(xValue, chartModel.rate_pitch ?? 0));
//           newGyroZData.add(FlSpot(xValue, chartModel.rate_yaw ?? 0));
//           newAngleRollData.add(FlSpot(xValue, chartModel.angle_roll ?? 0));
//           newAnglePitchData.add(FlSpot(xValue, chartModel.angle_pitch ?? 0));

//           // Update min and max values
//           minXValue = xValue < minXValue ? xValue : minXValue;
//           maxXValue = xValue > maxXValue ? xValue : maxXValue;
//           minYValue = [
//             chartModel.rate_roll ?? 0,
//             chartModel.rate_pitch ?? 0,
//             chartModel.rate_yaw ?? 0,
//             chartModel.angle_roll ?? 0,
//             chartModel.angle_pitch ?? 0,
//             minYValue
//           ].reduce((a, b) => a < b ? a : b);
//           maxYValue = [
//             chartModel.rate_roll ?? 0,
//             chartModel.rate_pitch ?? 0,
//             chartModel.rate_yaw ?? 0,
//             chartModel.angle_roll ?? 0,
//             chartModel.angle_pitch ?? 0,
//             maxYValue
//           ].reduce((a, b) => a > b ? a : b);
//         }

//         // Sort the data by x-value (timestamp)
//         newGyroXData.sort((a, b) => a.x.compareTo(b.x));
//         newGyroYData.sort((a, b) => a.x.compareTo(b.x));
//         newGyroZData.sort((a, b) => a.x.compareTo(b.x));
//         newAngleRollData.sort((a, b) => a.x.compareTo(b.x));
//         newAnglePitchData.sort((a, b) => a.x.compareTo(b.x));

//         if (newGyroXData.length > 20) {
//           newGyroXData = newGyroXData.sublist(newGyroXData.length - 20);
//           newGyroYData = newGyroYData.sublist(newGyroYData.length - 20);
//           newGyroZData = newGyroZData.sublist(newGyroZData.length - 20);
//           newAngleRollData =
//               newAngleRollData.sublist(newAngleRollData.length - 20);
//           newAnglePitchData =
//               newAnglePitchData.sublist(newAnglePitchData.length - 20);
//         }
//         // Update all reactive variables at once
//         gyroXData.value = newGyroXData;
//         gyroYData.value = newGyroYData;
//         gyroZData.value = newGyroZData;
//         angleRollData.value = newAngleRollData;
//         anglePitchData.value = newAnglePitchData;
//         minX.value = minXValue;
//         maxX.value = maxXValue;
//         minY.value = minYValue;
//         maxY.value = maxYValue;

//         print(
//             'Data fetched and processed for chart: ${newGyroXData.length} items');
//       } else {
//         print('Failed to load data: ${response.statusCode}');
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Failed to fetch data: $e');
//       throw Exception('Failed to fetch data');
//     }
//   }

//   void fetchListDomba() async {
//     try {
//       final response = await _http.get('http://localhost:3000/api/v2/chip');
//       if (response.statusCode == 200) {
//         final data = response.body['data']['rows'];
//         final Set<String> seenChipIds = {};
//         sheepList.clear();
//         for (var item in data) {
//           final chipId = item['chip_id'].toString();
//           if (!seenChipIds.contains(chipId)) {
//             seenChipIds.add(chipId);
//             sheepList.add({
//               'nama_domba': item['nama_domba'].toString(),
//               'chip_id': chipId
//             });
//           }
//         }
//         // Sort the list in ascending order
//         sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
//       } else {
//         throw Exception('Failed to load sheep list');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch sheep list: $e');
//     }
//   }

//   void fetchDataTable(int page) async {
//     try {
//       final response = await _http.get('http://localhost:3000/api/v2/mpu',
//           query: {'page': page.toString()});
//       if (response.statusCode == 200) {
//         final data = response.body;
//         listDataTable.clear();
//         for (var item in data['data']['rows']) {
//           listDataTable.add(DataTableModel({
//             'CHIP-ID': item['chip_id'],
//             'Nama Domba': item['nama_domba'],
//             'Jenis Kelamin': item['jenis_kelamin'],
//             'Rate Roll': item['rate_roll'].toString(),
//             'Rate Pitch': item['rate_pitch'].toString(),
//             'Rate Yaw': item['rate_yaw'].toString(),
//             'Angle Roll': item['angle_roll'].toString(),
//             'Angle Pitch': item['angle_pitch'].toString(),
//             'Jarak': item['tinggi'].toString(),
//             'Created At': item['createdAt'],
//           }));
//         }
//         currentPage = page;
//         totalPage = data['pagination']['totalPages'];
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch data');
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchSheepData();
//     fetchGyroData();
//     fetchListDomba();
//     fetchDataTable(currentPage);
//   }
// }
