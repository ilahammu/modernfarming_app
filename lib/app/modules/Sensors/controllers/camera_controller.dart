// import 'package:get/get.dart';
// import 'package:monitoring_kambing/app/data/datatable_model.dart';

// class CameraController extends GetxController {
//   int currentPage = 1;
//   int totalPage = 1;
//   final GetConnect _http = GetConnect();

//   final listColumnDataTable = [
//     'CHIP-ID',
//     'Nama Domba',
//     'Jenis Kelamin',
//     'Panjang',
//     'Tinggi',
//     'Created At',
//     'Updated At',
//   ].obs;

//   final listDataTable = <DataTableModel>[].obs;

//   void fetchDataTable(int page) async {
//     try {
//       final response = await _http.get("http://localhost:3000/api/v2/kamera",
//           query: {'page': page.toString()});
//       if (response.statusCode == 200) {
//         final data = response.body;

//         listDataTable.clear();
//         for (var item in data['data']['rows']) {
//           listDataTable.add(DataTableModel({
//             'CHIP-ID': item['chip_id'],
//             'Nama Domba': item['nama_domba'],
//             'Jenis Kelamin': item['jenis_kelamin'],
//             'Panjang': item['panjang'].toString(),
//             'Tinggi': item['tinggi'].toString(),
//             'Created At': item['createdAt'],
//             'Updated At': item['updatedAt'],
//           }));
//         }
//         currentPage = page;
//         totalPage = data['pagination']['totalPage'];
//       } else {
//         throw Exception(" Failed to fetch Data");
//       }
//     } catch (e) {
//       throw Exception(" Failed to calling Data");
//     }
//   }

//   @override
//   void onInit() {
//     fetchDataTable(currentPage);
//     super.onInit();
//   }
// }
