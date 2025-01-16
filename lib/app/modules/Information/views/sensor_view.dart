import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_kambing/app/global_component/custom_page2.dart';
import 'package:monitoring_kambing/app/modules/Information/controllers/sensor_controler.dart';
import 'package:url_launcher/url_launcher.dart';

class SensorView extends GetView<SensorController> {
  @override
  final SensorController controller = Get.put(SensorController());

  SensorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Information Sensor",
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
            Obx(() {
              if (controller.sensorList.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.sensorList.length,
                  itemBuilder: (context, index) {
                    final sensoran = controller.sensorList[index];
                    return GestureDetector(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(11.0), // Menambahkan margin
                        child: CustomPagee(
                          width: double.infinity,
                          height: 150, // Adjusted for horizontal layout
                          imageUrl: sensoran['imageUrl']!,
                          nama_sensor: sensoran['nama_sensor']!,
                          penjelasan: sensoran['penjelasan']!,
                          isOdd:
                              index % 2 == 0, // Determine layout based on index
                        ),
                      ),
                    );
                  },
                );
              }
            }),
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
