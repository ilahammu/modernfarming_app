// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:monitoring_kambing/app/global_component/custom_button.dart';
// import 'package:monitoring_kambing/app/global_component/custom_card.dart';
// import 'package:monitoring_kambing/app/global_component/custom_datatable.dart';
// import 'package:monitoring_kambing/app/global_component/custom_pagination.dart';

// import '../controllers/camera_controller.dart';

// class CameraView extends GetView<CameraController> {
//   @override
//   final CameraController controller = Get.put(CameraController());

//   CameraView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 78, 79, 79),
//         title: Text(
//           "Computer Vision",
//           style: GoogleFonts.ramabhadra(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//         return Container(
//           color: const Color(0xFFD9D9D9),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const CustomCard(
//                           isColumn: false,
//                           width: 200,
//                           height: 40,
//                           single_text: "LAST FETCHED IMAGE",
//                         ),
//                         CustomButton(
//                           onPressed: () {
//                             controller.fetchDataTable(controller.currentPage);
//                           },
//                           text: "Refresh Data",
//                           bgColor: const Color.fromARGB(255, 10, 182, 0),
//                           fgColor: Colors.white,
//                           textColor: Colors.white,
//                           width: 120,
//                           height: 40,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Container(
//                       width: 200,
//                       height: 200,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(5),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black,
//                             blurRadius: 0.1,
//                             spreadRadius: 0.1,
//                             offset: Offset(1, 1),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.image_not_supported_outlined,
//                         size: 100,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Obx(
//                       () {
//                         if (controller.listDataTable.isNotEmpty) {
//                           return Column(
//                             children: [
//                               CustomPagination(
//                                 currentPage: controller.currentPage,
//                                 totalPage: controller.totalPage,
//                                 onNext: controller.currentPage <
//                                         controller.totalPage
//                                     ? () {
//                                         controller.fetchDataTable(
//                                             controller.currentPage + 1);
//                                       }
//                                     : null,
//                                 onPrevious: controller.currentPage > 1
//                                     ? () {
//                                         controller.fetchDataTable(
//                                             controller.currentPage - 1);
//                                       }
//                                     : null,
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               CustomDataTable(
//                                   columnHeaders: controller.listColumnDataTable,
//                                   dataList: controller.listDataTable)
//                             ],
//                           );
//                         } else {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                       },
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
