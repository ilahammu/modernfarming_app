import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_kambing/app/global_component/custom_button.dart';
import 'package:monitoring_kambing/app/global_component/custom_datatable.dart';
import 'package:monitoring_kambing/app/global_component/custom_datefield.dart';
import 'package:monitoring_kambing/app/global_component/custom_dropdown_kelamin.dart';
import 'package:monitoring_kambing/app/global_component/custom_textfield.dart';
import 'package:monitoring_kambing/app/global_component/custom_pagination.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/data_kambing_controller.dart';

class DataKambingView extends GetView<DataKambingController> {
  final _formKey = GlobalKey<FormState>();

  @override
  final DataKambingController controller = Get.put(DataKambingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Tambah Data Domba",
          style: GoogleFonts.ramabhadra(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomButton(
              onPressed: () {
                controller.fetchDataTable(controller.currentPage);
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
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFD9D9D9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 990,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 189, 186, 186),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width: 100,
                                        child: myTextFormField(
                                          "CHIP ID",
                                          "CHIP ID",
                                          controller.chipIdController,
                                          TextInputType.name,
                                          false,
                                          false,
                                          controller.chipIDValidator,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: CustomButton(
                                        onPressed: () {
                                          controller.fetchChipId();
                                        },
                                        text: "Fetch ID",
                                        bgColor: const Color.fromARGB(
                                            255, 5, 116, 180),
                                        fgColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        textColor: Colors.white,
                                        width: 100,
                                        height: 30,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 170,
                                  height: 60,
                                  child: myTextFormField(
                                    "SHEEP NAME",
                                    "SHEEP NAME",
                                    controller.namaDombaController,
                                    TextInputType.name,
                                    false,
                                    true,
                                    controller.namaDombaValidator,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "BIRTH DATE",
                                  style: GoogleFonts.ramabhadra(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomDateField(
                                  hintText: "Birth Date",
                                  controller: controller.tanggalLahirController,
                                  onDateSelected: (date) {
                                    controller.updateSelectedDate(date);
                                  },
                                  isEnabled: true,
                                  width: 150,
                                  height: 30,
                                  validator: controller.tanggalLahirValidator,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Gender",
                                  style: GoogleFonts.ramabhadra(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomDropdownKelamin(
                                  selectedValue:
                                      controller.selectedJenisKelamin,
                                  onChanged: (String? newValue) {
                                    controller
                                        .handlerDropdownJenisKelamin(newValue);
                                  },
                                  items: controller.listDropdownJenisKelamin,
                                  hintText: 'Choose Gender',
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 150,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Create confirm dialog
                                        Get.defaultDialog(
                                          title: "Confirmation",
                                          content: Text(
                                            "Are you sure want to add this data?",
                                            style: GoogleFonts.ramabhadra(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          textConfirm: "Yes",
                                          textCancel: "No",
                                          confirmTextColor: Colors.white,
                                          buttonColor:
                                              Color.fromARGB(255, 1, 1, 23),
                                          cancelTextColor:
                                              Color.fromARGB(255, 0, 0, 0),
                                          onConfirm: () {
                                            controller.postData();
                                            Get.back();
                                          },
                                          onCancel: () {
                                            Get.back();
                                          },
                                        );
                                      } else {
                                        Get.snackbar(
                                          "Error",
                                          "Please fill all the fields",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          const Color.fromARGB(255, 10, 182, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text("Submit",
                                        style: GoogleFonts.ramabhadra(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
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
                            columnHeaders: controller.listColumnDataTable,
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
              const SizedBox(
                height: 20,
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
      ),
    );
  }

  Widget myTextFormField(
    String label,
    String hintText,
    TextEditingController controller,
    TextInputType keyboardType,
    bool obscureText,
    bool isEnabled,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.ramabhadra(
              color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        CustomTextField(
          isEnabled: isEnabled,
          validator: validator,
          hintText: hintText,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
        )
      ],
    );
  }
}
