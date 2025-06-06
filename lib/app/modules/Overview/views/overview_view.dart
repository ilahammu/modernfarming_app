import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_kambing/app/global_component/custom_button.dart';
import 'package:monitoring_kambing/app/global_component/custom_card.dart';
import 'package:monitoring_kambing/app/global_component/custom_cardNama.dart';
import 'package:monitoring_kambing/app/global_component/custom_dropdown.dart';

import '../../../global_component/datefield_analytic.dart';
import '../../../global_component/datefield_analytic2.dart';
import '../controllers/overview_controller.dart';

class OverviewView extends GetView<OverviewController> {
  @override
  final OverviewController controller = Get.put(OverviewController());

  OverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Overview",
          style: GoogleFonts.ramabhadra(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey[300]!,
                  Colors.grey[500]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 1),
                          Obx(() {
                            if (controller.isLoading.value) {
                              return CircularProgressIndicator(); // Tampilkan loading dulu
                            }

                            if (controller.sheepList.isEmpty) {
                              return Text(
                                  "Tidak ada data"); // Jika kosong, tampilkan pesan
                            }

                            return CustomDropdown(
                              selectedValue: controller.selectedSheep,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.handlerDropdownSheep(value);
                                }
                              },
                              items: controller.sheepList,
                              hintText: 'Pilih Domba',
                            );
                          }),
                          const SizedBox(width: 10),
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
                          // Tambahkan tanda strip
                          const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 34.0,
                          ),
                          CustomDateFieldDombaa(
                            hintText: "Choose date",
                            controller: controller.tanggalLahirControlleer,
                            onDateSelected: (date) {
                              controller.updateSelectedDate2(date);
                            },
                            isEnabled: true,
                            width: 150,
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CustomButton(
                          onPressed: () {
                            if (controller.selectedSheep.value != null) {
                              controller.fetchDombaData(
                                  controller.selectedSheep.value!);
                            }
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
                        const SizedBox(width: 10),
                        CustomButton(
                          onPressed: () {
                            controller.resetView();
                          },
                          text: "Reset View",
                          bgColor: Color.fromARGB(255, 255, 0, 0),
                          fgColor: Colors.white,
                          textColor: Colors.white,
                          width: 120,
                          height: 40,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Text("Please select your sheep"),
                    );
                  } else if (controller.dataList.isEmpty) {
                    return const Center(
                      child: Text("No data available"),
                    );
                  } else if (controller.selectedSheep.value != null) {
                    var domba = controller.dataList.first;
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 226, 219, 219),
                              width: 3,
                            ),
                            color: Color.fromARGB(255, 236, 236, 236),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 236, 236, 236)
                                    .withOpacity(0.1),
                                spreadRadius: 1.5,
                                blurRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              CustomCardNama(
                                single_text: domba.namaDomba,
                                width: 200,
                                height: 50,
                                isColumn: false,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(1),
                                child: Text(
                                  "DESCRIPTION",
                                  style: GoogleFonts.openSans(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Age',
                                    multiple_text2:
                                        '${domba.usia.toString()} Bulan',
                                    width: 130,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Gender',
                                    multiple_text2: domba.jenisKelamin,
                                    width: 130,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'ID',
                                    multiple_text2: domba.id,
                                    width: 400,
                                    height: 60,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(1),
                                child: Text(
                                  "MEASUREMENT DETAILS",
                                  style: GoogleFonts.openSans(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 100.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Weight',
                                    multiple_text2:
                                        '${domba.berat ?? "N/A"} KG',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Feed Weight',
                                    multiple_text2:
                                        '${domba.beratPakan ?? "N/A"} Gram',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Temperature',
                                    multiple_text2: '${domba.suhu ?? "N/A"} °C',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Humidity',
                                    multiple_text2:
                                        '${domba.kelembapan ?? "N/A"} %',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Condition',
                                    multiple_text2: domba
                                        .kondisi, // Langsung gunakan nilai dari database
                                    width: 230,
                                    height: 60,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10), // Jarak antar card
                      ],
                    );
                  } else {
                    var sortedDataList = controller.dataList.toList();
                    sortedDataList
                        .sort((a, b) => a.namaDomba.compareTo(b.namaDomba));
                    return Column(
                      children: sortedDataList.map((domba) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 226, 219, 219),
                              width: 3,
                            ),
                            color: Color.fromARGB(255, 236, 236, 236),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 236, 236, 236)
                                    .withOpacity(0.1),
                                spreadRadius: 1.5,
                                blurRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              CustomCardNama(
                                single_text: domba.namaDomba,
                                width: 200,
                                height: 50,
                                isColumn: false,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(1),
                                child: Text(
                                  "DESKRIPSI",
                                  style: GoogleFonts.openSans(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Age',
                                    multiple_text2:
                                        '${domba.usia.toString()} Bulan',
                                    width: 130,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Gender',
                                    multiple_text2: domba.jenisKelamin,
                                    width: 130,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'ID',
                                    multiple_text2: domba.id,
                                    width: 400,
                                    height: 60,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(1),
                                child: Text(
                                  "DETAIL PENGUKURAN",
                                  style: GoogleFonts.openSans(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 100.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Berat',
                                    multiple_text2:
                                        '${domba.berat ?? "N/A"} KG',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Berat Pakan',
                                    multiple_text2:
                                        '${domba.beratPakan ?? "N/A"} Gram',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Suhu',
                                    multiple_text2: '${domba.suhu ?? "N/A"} °C',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Kelembapan',
                                    multiple_text2:
                                        '${domba.kelembapan ?? "N/A"} %',
                                    width: 140,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  CustomCard(
                                    isColumn: true,
                                    multiple_text: 'Condition',
                                    multiple_text2: domba
                                        .kondisi, // Langsung gunakan nilai dari database
                                    width: 230,
                                    height: 60,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
