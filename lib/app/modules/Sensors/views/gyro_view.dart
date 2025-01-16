import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_kambing/app/global_component/custom_GyroLineChart2.dart';
import 'package:monitoring_kambing/app/global_component/custom_GyroLinechart.dart';
import 'package:monitoring_kambing/app/global_component/custom_button.dart';
import 'package:monitoring_kambing/app/global_component/custom_datatable.dart';
import 'package:monitoring_kambing/app/global_component/custom_dropdown.dart';
import 'package:monitoring_kambing/app/global_component/custom_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/gyro_controller.dart';

class GyroView extends GetView<GyroController> {
  @override
  final GyroController controller = Get.put(GyroController());

  GyroView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Perilaku",
          style: GoogleFonts.ramabhadra(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFD9D9D9),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          CustomDropdown(
                            selectedValue: controller.selectedSheep,
                            onChanged: (value) {
                              controller.handlerDropdownSheep(value);
                            },
                            items: controller.sheepList,
                            hintText: 'Pilih Domba',
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                      CustomButton(
                        onPressed: () {
                          controller.fetchDataTable(controller.currentPage);
                          controller.fetchSheepData();
                          controller.fetchGyroData();
                        },
                        text: "Refresh Data",
                        bgColor: const Color.fromARGB(255, 10, 182, 0),
                        fgColor: Colors.white,
                        textColor: Colors.white,
                        width: 120,
                        height: 40,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() {
                    print(
                        'Obx rebuilt. dataList length: ${controller.dataList.length}');
                    if (controller.selectedSheep.value != null) {
                      if (controller.dataList.isEmpty) {
                        return const Center(
                          child: Text(
                            'Isi data terlebih dahulu',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 132, 137, 132),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    spreadRadius: 1.5,
                                    blurRadius: 2,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Akselerasi info',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Obx(() => GyroChart(
                                          gyroXData: controller.accXData,
                                          gyroYData: controller.accYData,
                                          gyroZData: controller.accZData,
                                          minX: controller.minX.value,
                                          maxX: controller.maxX.value,
                                          minY: controller.minY.value,
                                          maxY: controller.maxY.value,
                                          xLabel: "Time",
                                          yLabel: "Rate",
                                          legends: ["X", "Y", "Z"],
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Obx(() => DistanceChart(
                                          distanceData: controller.distanceData,
                                          minX: controller.minX.value,
                                          maxX: controller.maxX.value,
                                          minY: controller.minY.value,
                                          maxY: controller.maxY.value,
                                          xLabel: "Time",
                                          yLabel: "Angle",
                                          legends: ["Jarak (cm)"],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: Text(
                          'Pilih domba untuk menampilkan grafik',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 29, 29, 29),
                          ),
                        ),
                      );
                    }
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() {
                    if (controller.listDataTable.isNotEmpty) {
                      return Column(
                        children: [
                          CustomPagination(
                            currentPage: controller.currentPage,
                            totalPage: controller.totalPage,
                            onPrevious: controller.currentPage > 1
                                ? () {
                                    controller.fetchDataTable(
                                        controller.currentPage - 1);
                                  }
                                : null,
                            onNext:
                                controller.currentPage < controller.totalPage
                                    ? () {
                                        controller.fetchDataTable(
                                            controller.currentPage + 1);
                                      }
                                    : null,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomDataTable(
                            columnHeaders: controller.listColumnTable,
                            dataList: controller.listDataTable,
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 240, 237, 237),
              padding: const EdgeInsets.symmetric(
                  vertical: 35, horizontal: 1), // Adjusted padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo_keren.png',
                      fit: BoxFit.contain,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Jl. Telekomunikasi No.1, Sukapura, Kec. ",
                    style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40257",
                    style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.youtube),
                        onPressed: () async {
                          const url = 'https://www.youtube.com/@stas_rg';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.instagram),
                        onPressed: () async {
                          const url = 'https://www.instagram.com/stas.rg/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.globe),
                        onPressed: () async {
                          const url =
                              'https://tuvv.telkomuniversity.ac.id/stas-rg/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
