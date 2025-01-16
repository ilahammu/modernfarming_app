import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_kambing/app/global_component/custom_page.dart';
import 'package:monitoring_kambing/app/modules/Information/controllers/team_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamView extends GetView<TeamController> {
  @override
  final TeamController controller = Get.put(TeamController());

  TeamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 78, 79, 79),
        title: Text(
          "Information Team",
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
              if (controller.teamList.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 1;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 30,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: controller.teamList.length,
                      itemBuilder: (context, index) {
                        final teamMember = controller.teamList[index];
                        return GestureDetector(
                          onTap: () {
                            // Handle the tap event here
                            Get.dialog(
                              AlertDialog(
                                title: Text(teamMember['name']!),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Text(
                                        teamMember['text']!,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text('Job Type: ${teamMember['jobType']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                                11.0), // Menambahkan margin
                            child: CustomPage(
                              width: 200,
                              height: 400,
                              imageUrl: teamMember['imageUrl']!,
                              name: teamMember['name']!,
                              jobType: teamMember['jobType']!,
                            ),
                          ),
                        );
                      },
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
