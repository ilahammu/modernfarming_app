import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_kambing/app/global_component/custom_dropdown.dart';
import 'package:monitoring_kambing/app/global_component/custom_button.dart';
import 'package:monitoring_kambing/app/global_component/custom_datatable.dart';
import 'package:monitoring_kambing/app/global_component/custom_linechart.dart';
import 'package:monitoring_kambing/app/global_component/custom_pagination.dart';
import 'package:monitoring_kambing/app/global_component/datefield_analytic.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/Fakan_controller.dart';

class WeightFoodView extends GetView<WeightFoodController> {
  @override
  final WeightFoodController controller = Get.put(WeightFoodController());

  WeightFoodView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Food Weight",
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
                            hintText: 'Choose sheep',
                          ),
                          const SizedBox(width: 10), // Add spacing
                          CustomDropdown(
                            selectedValue: controller.selectedTimeRange,
                            onChanged: (value) {
                              controller.handlerDropdownTimeRange(value);
                              if (value == 'Daily') {
                                controller.fetchDailyData(
                                    controller.selectedDate.value!);
                              } else if (value == 'Weekly') {
                                controller.fetchWeeklyData(
                                    controller.selectedDate.value!);
                              } else if (value == 'Monthly') {
                                controller.fetchMonthlyData(
                                    controller.selectedDate.value!);
                              }
                            },
                            items: ['Daily', 'Weekly', 'Monthly'].obs,
                            hintText: 'Date Time',
                            isMap: false, // Specify that items are not maps
                          ),
                          const SizedBox(width: 10), // Add spacing
                          CustomDateFieldDomba(
                            hintText: "Choose date",
                            controller: controller.tanggalLahirController,
                            onDateSelected: (date) {
                              controller.updateSelectedDate(date);
                            },
                            isEnabled: true,
                            width: 150,
                            height: 30,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomButton(
                            onPressed: () {
                              controller.resetState();
                            },
                            text: "Refresh Data",
                            bgColor: Color.fromARGB(255, 10, 182, 0),
                            fgColor: Colors.white,
                            textColor: Colors.white,
                            width: 120,
                            height: 40,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            color: Color.fromARGB(255, 10, 182, 0),
                            iconSize: 30,
                            onPressed: () {
                              controller.fetchLoadcellPakanData();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() {
                    if (controller.selectedSheep.value != null &&
                        controller.selectedTimeRange.value != null &&
                        controller.selectedDate.value != null) {
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
                              'Feed Chart',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Obx(() {
                            return CustomLineChart(
                              dataList: controller.dataList,
                              dataType: controller.selectedTimeRange.value ==
                                      'Monthly'
                                  ? 'pakan'
                                  : controller.selectedTimeRange.value ==
                                          'Weekly'
                                      ? 'pakan'
                                      : 'pakan',
                            );
                          }),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Data for ${DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Choose sheep, date time, and date to see the chart',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 29, 29, 29),
                          ),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 10),
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
